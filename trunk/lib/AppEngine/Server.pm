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
use base qw(HTTP::Server::Simple HTTP::Server::Simple::CGI::Environment);

use strict;
use warnings;

use AppEngine::APIProxy qw(become_apiproxy_client);
use AppEngine::AppConfig;
use Carp;
use Data::Dumper;
use English;
use Fcntl qw(F_GETFL F_SETFL FD_CLOEXEC);
use File::Spec::Functions qw(catfile canonpath);
use File::Type;
use IO::Select;
use IO::Socket::INET;
use IPC::Run 'start';
use POSIX qw(dup2);
use Socket;

our $VERSION = "0.01";

sub new {
    my $class = shift;
    my ($port, $app_dir) = @_;

    my $self  = $class->SUPER::new($port);
    $self->{pae_appdir} = $app_dir;
    $self->{app_config} = AppEngine::AppConfig->new(catfile($app_dir, 'app.yaml'));
    $self->{file_type}  = File::Type->new;

    return ($self);
}

sub net_server { 'Net::Server::Fork' }

sub accept_hook {
    my $self = shift;
    $self->setup_environment(@_);
}

sub post_setup_hook {
    my $self = shift;
    $self->setup_server_url;
}

sub setup {
    my $self = shift;
    $self->setup_environment_from_metadata(@_);
}


# Make file descriptors stdin/out/err (0, 1, 2) and 3 (apiproxy
# socketpair) available in exec'd process.
$SYSTEM_FD_MAX = 3;

# lazy for now, using TCP instead of unix domain sockets:
my $apiproxy_server = IO::Socket::INET->new(Listen => 10,
                                            ReuseAddr => 1,
                                            LocalPort => "9001")
    or die "Couldn't listen on apiproxy server socket.";


sub handler {
    my ($self) = @_;

    my $path = $ENV{PATH_INFO};
    $path =~ s/\.\.//g; # Disallow directory traversal

    my ($type, $file) = $self->{app_config}->handler_for_path($path);

    unless ($type) {
        print "HTTP/1.0 404 Not found\r\n";
        print "Content-Type: text/plain\r\n\r\n";
        print "Not found error: $path did not match any patterns in application configuration.";
        return;
    }

    $file = canonpath(catfile($self->{pae_appdir}, $file));
    warn "Request for $path to handler $file\n";

    if ($type eq 'script') {
        $self->_handle_script($file);
    } elsif ($type eq 'static') {
        $self->_handle_static($file);
    }
}

sub _handle_static {
    my ($self, $filename) = @_;

    if (-d $filename) {
        print "HTTP/1.0 403 OK\r\n";
        print "Content-Type: text-plain\r\n\r\n";

        print "Directory listings are not allowed\r\n";
    } elsif (-e $filename) {
        my $mime_type = $self->{file_type}->checktype_filename($filename);
        $mime_type ||= 'text/plain';

        print "HTTP/1.0 200 OK\r\n";
        print "Content-Type: $mime_type\r\n\r\n";

        open my $file, '<', $filename or croak "couldn't open $filename: $!";
        print while <$file>;
        close $file or croak "couldn't close $filename: $!";
    } else {
        print "HTTP/1.0 404 Not Found\r\n";
        print "Content-Type: text-plain\r\n\r\n";

        print "File not found\r\n";
    }
}

sub _handle_script {
    my ($self, $script) = @_;

    # setup socketpair between the untrusted app and the API proxy
    my $app_apiproxy_fh;
    my $parent_apiproxy_fh;
    socketpair($app_apiproxy_fh, $parent_apiproxy_fh,
               AF_UNIX, SOCK_STREAM, PF_UNSPEC) or die "socketpair: $!";

    my $child_pid = fork;
    die "Couldn't fork: $!" unless defined $child_pid;
    if ($child_pid) {
        # Parent
        close STDIN;
        close STDOUT;
        close $app_apiproxy_fh;

        become_apiproxy_client($parent_apiproxy_fh);
        exit 0;
    }

    close $parent_apiproxy_fh;

    # now setup STDOUT and STDERR pipes for the untrusted app
    pipe my $parent_stdout, my $app_stdout;
    pipe my $parent_stderr, my $app_stderr;

    my $app_pid = fork;
    die "Couldn't fork: $!" unless defined $app_pid;
    if ($app_pid) {
        # Parent
        close $app_apiproxy_fh;
        close $app_stdout;
        close $app_stderr;

        my ($buf_stdout, $buf_stderr);
        my $sel = IO::Select->new($parent_stdout, $parent_stderr);

        READ_LOOP:
        while (my @ready = $sel->can_read) {
            foreach my $fh (@ready) {
                local $/ = undef; # Read as much as we can each time
                my $data = <$fh>;
                last READ_LOOP unless defined $data; # EOF

                if ($fh == $parent_stdout) {
                    $buf_stdout .= $data;
                } elsif ($fh == $parent_stderr) {
                    print STDERR $data;
                    $buf_stderr .= $data;
                }
            }
        }

        # Wait for the app to close
        waitpid $app_pid, 0;

        if ($?) {
            # App exited with a non-zero return code - show error page
            print "HTTP/1.0 500 Internal Server Error\r\n";
            print "Content-Type: text/plain\r\n\r\n";

            print $buf_stderr;
        }
        else {
            # App finished - show output
            print "HTTP/1.0 200 OK\r\n";

            print $buf_stdout;
        }

        exit 0;
    }

    close $parent_stdout;
    close $parent_stderr;

    dup2(fileno(STDIN), 0) == 0 or die "dup2 of 0 failed: $!";
    dup2(fileno($app_stdout), 1) == 1 or die "dup2 of 1 failed: $!";
    dup2(fileno($app_stderr), 2) == 2 or die "dup2 of 2 failed: $!";
    dup2(fileno($app_apiproxy_fh), 3) == 3 or die "dup2 of 3 failed: $!";

    my $appdir = $self->{pae_appdir};

    $ENV{CLASS_MOP_NO_XS} = 1;

    # TODO(davidsansome): the python SDK actually checks this now - find a 
    # workaround?
    #$ENV{APPLICATION_ID} = $self->{app_config}->app_name;
    $ENV{APPLICATION_ID} = 'apiproxy-python';

    exec "perl",
         "-Ilib",  # AppEngine::APIProxy, ::Service::Memcache, etc.
         "-Icpanlib/Class-MOP/lib",
         "-I../protobuf-perl/perl/lib",  # Perl protobuf stuff
         "-I../protobuf-perl/perl/cpanlib",
         qw(-I../sys-protect/blib/lib -I../sys-protect/blib/arch -MSys::Protect),
         "-I$appdir", $script or die "exec failed: $!";
}



