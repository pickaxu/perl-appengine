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
use AppEngine::Service::MemcacheProto;

print "<h1>Hello!</h1>";
print "You requested path: $ENV{PATH_INFO}\n";

my ($req, $item);

# add: (will work on the first try of SDK being up)
$req = AppEngine::Service::MemcacheSetRequest->new;
$item = $req->add_item;
$item->set_key("foo");
$item->set_value("FOO_VALUE");
$item->set_expiration_time(255);
$item->set_set_policy(AppEngine::Service::MemcacheSetRequest::Item::SetPolicy::ADD);
do_req("memcache", "Set", $req);

# set:
$item->set_set_policy(AppEngine::Service::MemcacheSetRequest::Item::SetPolicy::SET);
do_req("memcache", "Set", $req);

# add again (won't work)
$item->set_set_policy(AppEngine::Service::MemcacheSetRequest::Item::SetPolicy::ADD);
do_req("memcache", "Set", $req);

# just to show failing opcodes:
my $rv = eval qq{unlink "/tmp/fooooo"};
print "<p>The end.  unlink=$rv, error=$@</p>\n";

print "<pre>ENV = ", Dumper(\%ENV), "</pre>\n";

sub do_req {
    my ($service, $method, $proto) = @_;
    my $res = eval {
        AppEngine::APIProxy::sync_call($service, $method, $proto);
    };
    if ($@) {
        print "$service $method error was: <pre>", Dumper([$res, $@]), "</pre>";
    } else {
        my $escaped = $res;
        $escaped =~ s/([^\w])/"\\x" . sprintf("%02x", ord($1))/eg;
        print "<p>$service $method response was success: $escaped.</p>";
    }
}
