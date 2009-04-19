#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::API::Datastore::Entity;
use AppEngine::Service::Entity;
use Test::More tests => 14;

$ENV{APPLICATION_ID} = 'appid';

my $entity = AppEngine::API::Datastore::Entity->new('kind');
is($entity->kind, 'kind');
is($entity->key->id, 0);
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


my $pb = AppEngine::Service::Entity::EntityProto->new;
$entity->_to_pb($pb);
$entity = AppEngine::API::Datastore::Entity::_from_pb($pb);
is($entity->kind, 'kind');
is($entity->key->name, 'keyname');
is($entity->key->kind, 'kind');
is($entity->is_saved, 1);
is($entity->{foo}, 'bar');
