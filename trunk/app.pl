#!/usr/bin/perl
#
# This is the untrusted app, running in a hardened CGI environment.
#
# The HTTP response goes to stdout.  Logging to stderr.  Any interaction
# with the App Engine services (Datastore, Memcache, Images, ...) needs
# to be done through the APIProxy.
#

use strict;
use Data::Dumper;
use APIProxy;

warn "mosorze from stderr";
print "<h1>Hello!</h1>Your requested path from \$ENV{PATH_INFO}: $ENV{PATH_INFO}\n";

my $res;

$res = APIProxy::sync_call("Hello from app!\n");
print "<p>Apiproxy response: [$res]</p>\n";

$res = APIProxy::sync_call("Hello from app again, we are at $ENV{PATH_INFO}!\n");
print "<p>Apiproxy response: [$res]</p>\n";

my $set_req_pb = "\x0b\x12\x03foo\x1a\tFOO_VALUE5\xff\x00\x00\x00\x0c";
print "<p>Length of request: @{[ length($set_req_pb) ]}.</p>";

$res = eval {
    APIProxy::sync_call("memcache", "Set", $set_req_pb);
};

print "Memcache set response was: <pre>", Dumper([$res, $@]), "</pre>";

my $rv = eval qq{unlink "/tmp/fooooo"};
print "<p>The end.  unlink=$rv, error=$@</p>\n";


print "<pre>ENV = ", Dumper(\%ENV), "</pre>\n";

