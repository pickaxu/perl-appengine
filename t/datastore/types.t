#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::API::Datastore;
use AppEngine::API::Datastore::Entity;
use AppEngine::API::Users;
use AppEngine::APIProxy;
use AppEngine::Python;
use Data::Dumper;
use Test::More tests => 20;

AppEngine::Python::initialize('appname');
$AppEngine::APIProxy::bypass_client = 1;
$ENV{APPLICATION_ID} = 'appname';

sub compare_users {
    my ($actual, $expected) = @_;

    isa_ok($actual, 'AppEngine::API::Users::User');
    is($actual->email, $expected->email);
    is($actual->auth_domain, $expected->auth_domain);
    is($actual->nickname, $expected->nickname);
}

my $user1 = AppEngine::API::Users::User->new('user1@example.com', 'example.com');
my $user2 = AppEngine::API::Users::User->new('user2@gmail.com', 'gmail.com');

# Test putting and getting a user
my $entity = AppEngine::API::Datastore::Entity->new('kind');
$entity->{user1} = $user1;
$entity->{user2} = $user2;
$entity->put;

$entity = AppEngine::API::Datastore->get($entity->key);
compare_users($entity->{user1}, $user1);
compare_users($entity->{user2}, $user2);

my $userentity_key = $entity->key;


# Test putting and getting undef
$entity = AppEngine::API::Datastore::Entity->new('kind');
$entity->{nothing} = undef;
ok(exists $entity->{nothing});
$entity->put;

$entity = AppEngine::API::Datastore->get($entity->key);
ok(!exists $entity->{nothing});


# Test putting and getting an array of things
$entity = AppEngine::API::Datastore::Entity->new('kind');
$entity->{intarray} = [ 1, 2, 3, 4 ];
$entity->{stringarray} = [ 'foo', 'bar', 'baz' ];
$entity->{mixedarray} = [ 42, 'wibble', $user1, $userentity_key ];
$entity->{undefarray} = [ undef, 2, undef, 4 ];
$entity->put;

$entity = AppEngine::API::Datastore->get($entity->key);
is_deeply($entity->{intarray}, [ 1, 2, 3, 4 ]);
is_deeply($entity->{stringarray}, [ 'foo', 'bar', 'baz' ]);
is_deeply($entity->{undefarray}, [ 2, 4 ]);

is($entity->{mixedarray}[0], 42);
is($entity->{mixedarray}[1], 'wibble');
compare_users($entity->{mixedarray}[2], $user1);
is($entity->{mixedarray}[3]->key->str, $userentity_key->str);
