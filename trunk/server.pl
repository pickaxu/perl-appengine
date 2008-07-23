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

use strict;
use IO::Socket::INET;
use English;
use Fcntl qw(F_GETFL F_SETFL FD_CLOEXEC);
use POSIX qw(dup2);
use Socket;

# Make file descriptors stdin/out/err (0, 1, 2) and 3 (apiproxy
# socketpair) available in exec'd process.
$SYSTEM_FD_MAX = 3;

# lazy for now, using TCP instead of unix domain sockets:
my $apiproxy_server = IO::Socket::INET->new(Listen => 10,
                                            ReuseAddr => 1,
                                            LocalAddr => "127.0.0.1:9001")
    or die "Couldn't listen on apiproxy server socket.";


my $server_socket = IO::Socket::INET->new(Listen => 10,
                                          ReuseAddr => 1,
                                          LocalAddr => "127.0.0.1:9000")
    or die "Couldn't listen to socket.";

print "Accepting from http://127.0.0.1:9000/ ...\n";
while (my $client_socket = $server_socket->accept) {
    my $child_pid = fork;
    next if $child_pid;
    if (!defined($child_pid)) {
        die "Error forking.";
    }

    print "socket = $client_socket, fileno = ", fileno($client_socket), "\n";

    # setup socketpair between the untrusted app and the parent
    my $app_apiproxy_fh;
    my $parent_apiproxy_fh;
    socketpair($app_apiproxy_fh, $parent_apiproxy_fh,
               AF_UNIX, SOCK_STREAM, PF_UNSPEC) or die "socketpair: $!";

    my $app_pid = fork;
    die "Couldn't fork: $!" unless defined $app_pid;
    if ($app_pid) {
        close($client_socket);
        become_apiproxy_server($parent_apiproxy_fh);
        exit 0;
    }

    open(my $devnull_fh, "+</dev/null") or die "no dev null";

    # for now...
    my $apiproxy_socket = $devnull_fh;

    dup2(fileno($client_socket), 0) == 0 or die "dup2 of 0 failed: $!";
    dup2(fileno($client_socket), 1) == 1 or die "dup2 of 1 failed: $!";
    #dup2(fileno($devnull_fh), 2) == 2 or die "dup2 of 2 failed: $!";
    dup2(fileno($app_apiproxy_fh), 3) == 3 or die "dup2 of 3 failed: $!";

    exec(qw(perl -I../sys-protect/blib/lib -I../sys-protect/blib/arch -MSys::Protect app.pl));
}

sub become_apiproxy_server {
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
