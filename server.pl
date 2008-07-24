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
use IO::Socket::INET;
use English;
use Fcntl qw(F_GETFL F_SETFL FD_CLOEXEC);
use POSIX qw(dup2);
use Socket;
use IPC::Run3 'run3';

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

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
                                            LocalAddr => "127.0.0.1:9001")
    or die "Couldn't listen on apiproxy server socket.";


sub handle_request {
    my $self = shift;
    my $cgi = shift;
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
    #dup2(fileno($devnull_fh), 2) == 2 or die "dup2 of 2 failed: $!";
    dup2(fileno($app_apiproxy_fh), 3) == 3 or die "dup2 of 3 failed: $!";

    my $stderr = '';

    use IPC::Run 'start';
    start [qw(perl -I../sys-protect/blib/lib -I../sys-protect/blib/arch -MSys::Protect app.pl)],
        '<pipe', \*IN,
        '>pipe', \*OUT,
        '2>pipe', \*ERR or die "died with $?";
    {
        local $/;
        $stderr = <ERR>;
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
    # TODO(bradfitz): connect to master apiproxy server (the Python
    # process, later)
    select($socket);
    $| = 1;
    while (<$socket>) {
        print STDERR "It was said: [$_]\n";
        print $socket "You said: $_";
    }
}

package main;

AppEngine::Server->new( 9000 )->run;
