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
use AppEngine::APIProxy;
use AppEngine::Service::Memcache;
use AppEngine::Service::Images;
use AppEngine::Service::URLFetch;
# for datastore:
use AppEngine::Service::Base;
use AppEngine::Service::Entity;
use AppEngine::Service::Datastore;

print "<h1>Hello!</h1>";
print "You requested path: $ENV{PATH_INFO}\n";

my ($req, $res, $item);

# add: (will work on the first try of SDK being up)
$req = AppEngine::Service::MemcacheSetRequest->new;
$res = AppEngine::Service::MemcacheSetResponse->new;

$item = $req->add_item;
$item->set_key("foo");
$item->set_value("FOO_VALUE");
$item->set_expiration_time(255);
$item->set_set_policy(AppEngine::Service::MemcacheSetRequest::Item::SetPolicy::ADD);
if (do_req("memcache", "Set", $req, $res)) {
    print "<pre>ENV = ", Dumper($res), "</pre>\n";
}

# set:
$item->set_set_policy(AppEngine::Service::MemcacheSetRequest::Item::SetPolicy::SET);
do_req("memcache", "Set", $req, $res);

# add again (won't work)
$item->set_set_policy(AppEngine::Service::MemcacheSetRequest::Item::SetPolicy::ADD);
do_req("memcache", "Set", $req, $res);

# just to show failing opcodes:
my $rv = eval qq{unlink "/tmp/fooooo"};
print "<p>The end.  unlink=$rv, error=$@</p>\n";

print "<pre>ENV = ", Dumper(\%ENV), "</pre>\n";

sub do_req {
    my ($service, $method, $proto, $res) = @_;
    my $res_bytes = eval {
        AppEngine::APIProxy::sync_call($service, $method, $proto);
    };
    if ($@) {
        print "$service $method error was: <pre>", Dumper([$res_bytes, $@]), "</pre>";
        return undef;
    }
    my $escaped = $res_bytes;
    $escaped =~ s/([^\w])/"\\x" . sprintf("%02x", ord($1))/eg;
    print "<p>$service $method response was success: $escaped.</p>";
    my $parsed = eval { $res->parse_from_string($res_bytes); 1 };
    return 1 if $parsed;
    print "<p>Failed to parse_from_string: $@\n</p>";
    return 0;
}
