#!/usr/bin/perl
#
# This is the untrusted app, running in a hardened CGI environment.
#
# Guestbook app.
#

use strict;
use Data::Dumper;
use AppEngine::APIProxy;
use AppEngine::Service::Memcache;
# for datastore:
use AppEngine::Service::Base;
use AppEngine::Service::Entity;
use AppEngine::Service::Datastore;

print "<h1>Hello!</h1>";
print "You requested path: $ENV{PATH_INFO}\n";

my ($req, $res, $item);

$req = AppEngine::Service::Datastore::PutRequest->new;
$res = AppEngine::Service::Datastore::PutResponse->new;

my $entity = $req->add_entity;
my $key_ref = $entity->key;
$key_ref->set_app(""); # required.  what is it?
my $path = $key_ref->path;  # vivify it, but do nothing.

my $entity_group_path = $entity->entity_group; # vivify it, do nothing

use Data::Dumper;
print "<pre>" . Dumper($req) . "</pre>";

do_req("datastore_v3", "Put", $req, $res) or die;

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
