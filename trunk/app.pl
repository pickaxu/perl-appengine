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

my $apiproxy_response;

$apiproxy_response = APIProxy::sync_call("Hello from app!\n");
print "<p>Apiproxy response: [$apiproxy_response]</p>\n";

$apiproxy_response = APIProxy::sync_call("Hello from app again, we are at $ENV{PATH_INFO}!\n");
print "<p>Apiproxy response: [$apiproxy_response]</p>\n";

my $rv = eval qq{unlink "/tmp/fooooo"};
print "<p>The end.  unlink=$rv, error=$@</p>\n";


print "<pre>ENV = ", Dumper(\%ENV), "</pre>\n";

