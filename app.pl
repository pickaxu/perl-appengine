#!/usr/bin/perl
#
# This should eventually feel like a CGI (or FastCGI?) environment.
# same filedescriptors, etc.  Probably use another fd (3?) for the
# apiproxy interface for now, a socketpair to parent process or
# something.

# for now we're using the wrong fd numbers...
open (my $socket, "<&=", 3) or die "Couldn't open socket: $!";

my $http_line = <$socket>;
die "Bogus HTTP request" unless $http_line =~ /^(GET) (\S+)(?: HTTP\/(\d+\.\d+))?/;
my ($method, $path, $version) = ($1, $2, $3);

while (<$socket>) {
    last if /^\s+$/;
}

print "You requested: $http_line\n";
