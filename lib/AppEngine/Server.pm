#!/usr/bin/perl
#
# Potential plan for apiproxy in dev environment server...
#
# server.pl (allocates listening socket for apiproxy)
#  |
#  +-- apiproxy (listening socket) for now, python server,
#  |   using mock implementations of apiproxy services from
#  |   Python Google's dev_appserver.py.  for now.  :)
#  |
#  +-+- client1 (creates socket pair, then forks apiproxy client)
#  | |
#  | +--- client1 apiproxy client (listens on socketpair for apiproxy
#  |      requests, forwards them to apiproxy (over TCP)
#  +-+- client2
#  | +--- client2 apiproxy client
#  +-+- client3
#    +--- client3 apiproxy client
#

package AppEngine::Server;
use base 'HTTP::Server::Simple::CGI';

use strict;
use warnings;

use AppEngine::AppConfig;
use IO::Socket::INET;
use English;
use Fcntl qw(F_GETFL F_SETFL FD_CLOEXEC);
use File::Spec::Functions qw(catfile);
use POSIX qw(dup2);
use Socket;
use IPC::Run 'start';
use LWP::UserAgent;
use HTTP::Request::Common;
use Data::Dumper;

our $VERSION = "0.01";

sub new {
    my $class = shift;
    my ($port, $app_dir) = @_;

    my $self  = $class->SUPER::new($port);
    $self->{pae_appdir} = $app_dir;
    $self->{app_config} = AppEngine::AppConfig->new(catfile($app_dir, 'app.yaml'));

    return ($self);
}

sub net_server { 'Net::Server::Fork' }

sub after_setup_listener {
    my $self = shift;

    warn "===> after setup listener";
}


# Make file descriptors stdin/out/err (0, 1, 2) and 3 (apiproxy
# socketpair) available in exec'd process.
$SYSTEM_FD_MAX = 3;

# lazy for now, using TCP instead of unix domain sockets:
my $apiproxy_server = IO::Socket::INET->new(Listen => 10,
                                            ReuseAddr => 1,
                                            LocalPort => "9001")
    or die "Couldn't listen on apiproxy server socket.";


sub handle_request {
    my ($self, $cgi) = @_;

    my $path = $cgi->path_info();
    my ($type, $file) = $self->{app_config}->handler_for_path($path);

    warn "Request for $path\n";

    unless ($type) {
        print "HTTP/1.0 404 Not found\r\n";
        print "Content-Type: text/plain\r\n\r\n";
        print "Not found error: $path did not match any patterns in application configuration.";
        return;
    }

    if ($type eq 'script') {
        $self->_handle_script($file);
    }
    elsif ($type eq 'static') {
        $self->_handle_static($file);
    }
}

sub _handle_static {
    my ($self, $file) = @_;
    # TODO(davidsansome)
}

sub _handle_script {
    my ($self, $script) = @_;
    my $client_socket = $self->stdio_handle;

    # setup socketpair between the untrusted app and the parent
    my $app_apiproxy_fh;
    my $parent_apiproxy_fh;
    socketpair($app_apiproxy_fh, $parent_apiproxy_fh,
               AF_UNIX, SOCK_STREAM, PF_UNSPEC) or die "socketpair: $!";

    my $app_pid = fork;
    die "Couldn't fork: $!" unless defined $app_pid;
    if ($app_pid) {
        close($client_socket);
        become_apiproxy_client($parent_apiproxy_fh);
        exit 0;
    }

    open(my $devnull_fh, "+</dev/null") or die "no dev null";

    # for now...
    my $apiproxy_socket = $devnull_fh;

    dup2(fileno($client_socket), 0) == 0 or die "dup2 of 0 failed: $!";
    dup2(fileno($client_socket), 1) == 1 or die "dup2 of 1 failed: $!";
    dup2(fileno(STDERR), 2) == 2 or die "dup2 of 2 failed: $!";
    dup2(fileno($app_apiproxy_fh), 3) == 3 or die "dup2 of 3 failed: $!";

    my $stderr = '';
    my $appdir = $self->{pae_appdir};

    $ENV{CLASS_MOP_NO_XS} = 1;
    start ["perl",
           "-Ilib",  # AppEngine::APIProxy, ::Service::Memcache, etc.
           "-Icpanlib/Class-MOP/lib",
           "-I../protobuf-perl/perl/lib",  # Perl protobuf stuff
           "-I../protobuf-perl/perl/cpanlib",
           qw(-I../sys-protect/blib/lib -I../sys-protect/blib/arch -MSys::Protect),
           "-I$appdir", "$appdir/$script"],
        '<pipe', \*IN,
        '>pipe', \*OUT,
        '2>pipe', \*ERR or die "died with $?";
    {
        local $/;
        $stderr = <ERR>;
        if (length($stderr)) {
            print STDERR "app's stderr: [$stderr]\n";
        }
    }

    my $should_send_header = 1;
    local $/ = 16384;

    while (my $buf = <OUT>) {
        if ($should_send_header && $buf =~ m'^HTTP/' && $buf =~ m/(\r?\n){2}/ ){
        }
        else {
            print $client_socket "HTTP/1.0 200 OK\r\n";    # probably OK by now
            print $client_socket "Content-Type: text/html\r\n\r\n";
        }
        $should_send_header = 0;
        print $buf;
    }
}

sub become_apiproxy_client {
    my $socket = shift;

    my $ua = LWP::UserAgent->new;

    select($socket);
    $| = 1;
    while (my $cmd = <$socket>) {
        chomp $cmd;
        unless ($cmd =~ /^apiproxy (\S+) (\S+) (\d+)/) {
            print STDERR "Unknown apiproxy line: [$cmd]\n";
            print $socket "You said: $cmd\n";
            next;
        }
        my ($service, $method, $request_length) = ($1, $2, $3);
        my $pb_request;
        my $rv = read($socket, $pb_request, $request_length);
        if ($rv != $request_length) {
            die "Failed to read entire request from app.";
        }
        my $req = POST "http://127.0.0.1:8080/do_req", [
            service => $service,
            method => $method,
            request => $pb_request, ];
        print STDERR "Sending request: ", $req->as_string, "\n";
        my $res = $ua->request($req);

        my $success = $res->is_success ? 1 : 0;
        my $body;
        if ($success) {
            if ($res->content =~ /^Response: \[(.*)\]\s*$/s) {
                $body = $1;
            } else {
                $body = $res->content;
                $success = 0;
            }
        } else {
            $body = $res->status_line;
        }
        print STDERR "Got apiproxy result (for $service, $method) of success=$success:\n";
        print STDERR Dumper($body);
        print $socket "apiresult $success ", length($body), "\n$body";
    }
}

