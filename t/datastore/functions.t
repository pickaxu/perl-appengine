#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::API::Datastore;
use AppEngine::API::Datastore::Entity;
use AppEngine::APIProxy;
use Data::Dumper;
use Test::More tests => 9;

$AppEngine::APIProxy::bypass_client = 1;
$ENV{APPLICATION_ID} = 'appid';

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

$entity = AppEngine::API::Datastore::get($key);
is_deeply($key, $entity->key);
is($entity->{foo}, 'bar');

# Delete that entity
AppEngine::API::Datastore::delete($key);

# Trying to get it again should return undef
$entity = AppEngine::API::Datastore::get($key);
ok(!$entity);
