#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::API::Datastore::Entity;
use AppEngine::API::Datastore::LazyEntity;
use AppEngine::API::Datastore::Key;
use AppEngine::APIProxy;
use AppEngine::Python;
use Data::Dumper;
use Test::More tests => 15;

AppEngine::Python::initialize('appname');
$AppEngine::APIProxy::bypass_client = 1;
$ENV{APPLICATION_ID} = 'appname';

# Create a parent entity with a reference to a child entity
my $parent = AppEngine::API::Datastore::Entity->new('test');
my $child  = AppEngine::API::Datastore::Entity->new('test');
$child->{foo} = 'bar';
$parent->{child} = $child;

$child->put;
$parent->put;
my $parent_key = $parent->key;

# Load the parent and test basic LazyEntity functionality
$parent = AppEngine::API::Datastore->get($parent_key);

ok(!$parent->{child}->is_loaded);
ok(exists $parent->{child}->{foo});
ok($parent->{child}->is_loaded);

$parent = AppEngine::API::Datastore->get($parent_key);

isa_ok($parent->{child}, 'AppEngine::API::Datastore::LazyEntity');

ok(!$parent->{child}->is_loaded);
is($parent->{child}->{foo}, 'bar');
ok($parent->{child}->is_loaded);

# Test that modifying the child loads the entity
$parent = AppEngine::API::Datastore->get($parent_key);

ok(!$parent->{child}->is_loaded);
delete $parent->{child}->{foo};
ok($parent->{child}->is_loaded);
ok(!exists $parent->{child}->{foo});

$parent = AppEngine::API::Datastore->get($parent_key);

ok(!$parent->{child}->is_loaded);
$parent->{child}->{foo} = 'wibble';
ok($parent->{child}->is_loaded);
is($parent->{child}->{foo}, 'wibble');

# Make sure we can store it again
$parent->{child}->put;
$parent = AppEngine::API::Datastore->get($parent_key);
is($parent->{child}->{foo}, 'wibble');

# Make sure the child isn't loaded at all if it isn't accessed
$parent = AppEngine::API::Datastore->get($parent_key);
$parent->{wibble} = 'meep';
$parent->put;
ok(!$parent->{child}->is_loaded);


