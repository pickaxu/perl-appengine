#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::API::Datastore::Entity;
use AppEngine::APIProxy;
use AppEngine::Service::Entity;
use Data::Dumper;
use Test::More tests => 16;

$ENV{APPLICATION_ID} = 'appid';

# Test basic getters and setters
my $entity = AppEngine::API::Datastore::Entity->new('kind');
is($entity->kind, 'kind');
is($entity->key->id, undef);
is($entity->key->kind, 'kind');
is($entity->is_saved, 0);

$entity = AppEngine::API::Datastore::Entity->new('kind',
    key_name => 'keyname',
    {
        foo => 'bar',
    }
);
is($entity->kind, 'kind');
is($entity->key->name, 'keyname');
is($entity->key->kind, 'kind');
is($entity->is_saved, 0);
is($entity->{foo}, 'bar');

# Test serialisation and deserialisation
my $pb = AppEngine::Service::Entity::EntityProto->new;
$entity->_to_pb($pb);
$entity = AppEngine::API::Datastore::Entity::_from_pb($pb);
is($entity->kind, 'kind');
is($entity->key->name, 'keyname');
is($entity->key->kind, 'kind');
is($entity->is_saved, 1);
is($entity->{foo}, 'bar');

# Test parent stuff
# Note we don't call ->parent here, as that would do an actual call to the DB
ok(!$entity->parent_key);
my $child = AppEngine::API::Datastore::Entity->new('kind', parent => $entity);
is($child->parent_key->name, 'keyname');

