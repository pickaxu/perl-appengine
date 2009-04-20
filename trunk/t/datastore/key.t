#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::API::Datastore::Key;
use AppEngine::Service::Entity;
use Test::More tests => 23;

$ENV{APPLICATION_ID} = 'appid';

# Test basic getters and setters
my $key = AppEngine::API::Datastore::Key::from_path(['parentkind', 'parentname', 'kind', 'name']);
is($key->app, 'appid');
is($key->kind, 'kind');
is($key->id, undef);
is($key->name, 'name');
is($key->id_or_name, 'name');
ok($key->has_id_or_name);

# Test serialisation and deserialisation
my $pb = AppEngine::Service::Entity::Reference->new;
$key->_to_pb($pb);
$key = AppEngine::API::Datastore::Key::_from_pb($pb);

is($key->app, 'appid');
is($key->kind, 'kind');
is($key->id, undef);
is($key->name, 'name');
is($key->id_or_name, 'name');
ok($key->has_id_or_name);

# Test parent stuff
my $parent = $key->parent;
is($parent->app, 'appid');
is($parent->kind, 'parentkind');
is($parent->id, undef);
is($parent->name, 'parentname');
is($parent->id_or_name, 'parentname');
ok($parent->has_id_or_name);
ok(!defined $parent->parent);

# Test parent constructor
my $child = AppEngine::API::Datastore::Key::from_path(
    ['childkind', 'childname'],
    parent => $key,
);
is($child->name, 'childname');
is($child->parent->name, 'name');
is($child->parent->parent->name, 'parentname');
ok(!defined $child->parent->parent->parent);
