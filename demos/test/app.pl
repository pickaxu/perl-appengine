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

my $do_set = sub {
    my $pb = shift;
    my $res = eval {
        APIProxy::sync_call("memcache", "Set", $pb);
    };
    if ($@) {
        print "Memcache set error was: <pre>", Dumper([$res, $@]), "</pre>";
    } else {
        my $escaped = $res;
        $escaped =~ s/([^\w])/"\\x" . sprintf("%02x", ord($1))/eg;
        print "<p>Memcache set response was success: $escaped.</p>";
    }
};

# add: (will work on the first try of SDK being up)
$do_set->("\x0b\x12\x03foo\x1a\tFOO_VALUE(\x025\xff\x00\x00\x00\x0c");
# set:
$do_set->("\x0b\x12\x03foo\x1a\tFOO_VALUE(\x015\xff\x00\x00\x00\x0c");
# add: (should return a "NOT_STORED" response)
$do_set->("\x0b\x12\x03foo\x1a\tFOO_VALUE(\x025\xff\x00\x00\x00\x0c");

my $rv = eval qq{unlink "/tmp/fooooo"};
print "<p>The end.  unlink=$rv, error=$@</p>\n";


print "<pre>ENV = ", Dumper(\%ENV), "</pre>\n";

