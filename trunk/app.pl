#!/usr/bin/perl
#
# This should eventually feel like a CGI (or FastCGI?) environment.
# same filedescriptors, etc.  Probably use another fd (3?) for the
# apiproxy interface for now, a socketpair to parent process or
# something.

use strict;
use Data::Dumper;

open(my $apiproxy, "<&=3") or die "Failed to open apiproxy fd: $!";

warn "mosorze from stderr";
print "<h1>Hello!</h1>Your requested path from \$ENV{PATH_INFO}: $ENV{PATH_INFO}\n";

syswrite($apiproxy, "Hello from app!\n");
my $apiproxy_response = <$apiproxy>;
print "<p>Apiproxy response: [$apiproxy_response]</p>\n";

syswrite($apiproxy, "Hello from app again, we are at $ENV{PATH_INFO}!\n");
my $x = <$apiproxy>;
print "<p>Apiproxy response: [$x]</p>";

my $rv = eval qq{unlink "/tmp/fooooo"};
print "<p>The end.  unlink=$rv, error=$@</p>\n";


print "<pre>ENV = ", Dumper(\%ENV), "</pre>\n";

