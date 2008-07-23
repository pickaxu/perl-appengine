#!/usr/bin/perl

use strict;
use IO::Socket::INET;
use English;
use Fcntl qw(F_GETFL F_SETFL FD_CLOEXEC);
use POSIX qw(dup2);

# Make file descriptors stdin/out/err (0, 1, 2) and 3 (apiproxy
# socketpair) available in exec'd process.
$SYSTEM_FD_MAX = 3;

my $server_socket = IO::Socket::INET->new(Listen => 10,
                                          ReuseAddr => 1,
                                          LocalAddr => "127.0.0.1:9000")
    or die "Couldn't listen to socket.";

print "Accepting from http://127.0.0.1:9000/ ...\n";
my $client_socket = $server_socket->accept
    or die;

print "socket = $client_socket, fileno = ", fileno($client_socket), "\n";

open(my $devnull_fh, "+</dev/null") or die "no dev null";

# for now...
my $apiproxy_socket = $devnull_fh;

dup2(fileno($client_socket), 0) == 0 or die "dup2 of 0 failed: $!";
dup2(fileno($client_socket), 1) == 1 or die "dup2 of 1 failed: $!";
dup2(fileno($devnull_fh), 2) == 2 or die "dup2 of 2 failed: $!";
dup2(fileno($apiproxy_socket), 3) == 3 or die "dup2 of 3 failed: $!";

exec(qw(perl -I../sys-protect/blib/lib -I../sys-protect/blib/arch -MSys::Protect app.pl));



