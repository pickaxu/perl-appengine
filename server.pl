#!/usr/bin/perl

use strict;
use IO::Socket::INET;
use English;
use Fcntl qw(F_GETFL F_SETFL FD_CLOEXEC);
use POSIX qw(dup2);

# Make file descriptors stdin/out/err (0, 1, 2) and 3 (apiproxy
# socketpair) available in exec'd process.
$SYSTEM_FD_MAX = 3;

#close(STDIN);
#close(STDOUT);
#close(STDERR);

# this steals fd==3 for now.
open(my $dummy_fh, "/dev/null") or die; 

my $server_socket = IO::Socket::INET->new(Listen => 10,
                                          ReuseAddr => 1,
                                          LocalAddr => "127.0.0.1:9000")
    or die "Couldn't listen to socket.";

close($dummy_fh);  # okay, we're done reserving fd==3, time to return it.  :)

print "Accepting from http://127.0.0.1:9000/ ...\n";
my $client_socket = $server_socket->accept
    or die;

unless (fileno($client_socket) == 3) { die "ASSERT not fd 3"; }

my $flags = fcntl($client_socket, F_GETFL, 0)
    or die "Can't get flags for the socket: $!\n";
print "Flags = $flags\n";

fcntl($client_socket, F_SETFL, $flags | FD_CLOEXEC) or die;

$flags = fcntl($client_socket, F_GETFL, 0)
    or die "Can't get flags for the socket: $!\n";
print "Flags2 = $flags\n";

print "socket = $client_socket, fileno = ", fileno($client_socket), "\n";

exec(qw(perl -I../sys-protect/blib/lib -I../sys-protect/blib/arch -MSys::Protect app.pl));



