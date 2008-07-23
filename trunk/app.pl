#!/usr/bin/perl
#
# This should eventually feel like a CGI (or FastCGI?) environment.
# same filedescriptors, etc.  Probably use another fd (3?) for the
# apiproxy interface for now, a socketpair to parent process or
# something.

my $http_line = <STDIN>;
die "Bogus HTTP request" unless $http_line =~ /^(GET) (\S+)(?: HTTP\/(\d+\.\d+))?/;
my ($method, $path, $version) = ($1, $2, $3);

while (<STDIN>) {
    last if /^\s+$/;
}

print "HTTP/1.0 200 OK\n";
print "Content-Type: text/html\n\n";

print "<h1>Hello!</h1>You requested: $http_line\n";

unlink "/etc/passwd";

print "The end.\n";
