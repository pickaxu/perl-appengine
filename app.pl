#!/usr/bin/perl
#
# This should eventually feel like a CGI (or FastCGI?) environment.
# same filedescriptors, etc.  Probably use another fd (3?) for the
# apiproxy interface for now, a socketpair to parent process or
# something.

open(my $apiproxy, "<&=3") or die "Failed to open apiproxy fd: $!";


print "moose blah!\n";
warn "mosorze from stderr";

syswrite($apiproxy, "Hello from app!\n");


my $apiproxy_response = <$apiproxy>;

print "<h1>Hello!</h1>You requested: $http_line\n";

print "<p>Apiproxy says: [$apiproxy_response]</p>\n";

my $rv = eval qq{unlink "/etc/passwd"};

print "The end.  unlink=$rv, error=$@\n";

print "yatta!!\n";


syswrite($apiproxy, "Hello from app again, we are at $ENV{PATH_INFO}!\n");

my $x = <$apiproxy>;

print "got $x $apiproxy";

