#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::API::Datastore;
use AppEngine::API::Datastore::Entity;
use AppEngine::APIProxy;
use AppEngine::Python;
use Data::Dumper;
use Test::More tests => 17;

AppEngine::Python::initialize('appname');
$AppEngine::APIProxy::bypass_client = 1;
$ENV{APPLICATION_ID} = 'appname';

my $db = AppEngine::API::Datastore->new;

# Test put and get with one entity
my $entity = AppEngine::API::Datastore::Entity->new('test');
$entity->{foo} = 'bar';
ok(!$entity->is_saved);
ok(!$entity->key->has_id_or_name);
my $key = $entity->put;

ok($entity->is_saved);
ok($entity->key->has_id_or_name);
ok($key->has_id_or_name);
is_deeply($key, $entity->key);

$entity = $db->get($key);
is_deeply($key, $entity->key);
is($entity->{foo}, 'bar');

# Delete that entity
$db->delete($key);

# Trying to get it again should return undef
$entity = $db->get($key);
ok(!$entity);


# Test put and get with an entity with a name
$entity = AppEngine::API::Datastore::Entity->new('test', key_name => 'wibble');
$key = $entity->put;
is($key->name, 'wibble');

$entity = $db->get($key);
is($entity->key->name, 'wibble');

# Make a child of this entity
my $child = AppEngine::API::Datastore::Entity->new('test', key_name => 'wobble', parent => $entity);
my $child_key = $child->put;

$child = $db->get($child_key);
is($child->key->name, 'wobble');
is($child->parent_key->name, 'wibble');
is($child->parent->key->name, 'wibble');


# Can we make a child without a name?
$child = AppEngine::API::Datastore::Entity->new('test', parent => $entity);
$child_key = $child->put;

$child = $db->get($child_key);
is($child->key->name, undef);
is($child->parent_key->name, 'wibble');
is($child->parent->key->name, 'wibble');
