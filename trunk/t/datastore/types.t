#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::API::Datastore;
use AppEngine::API::Datastore::Entity;
use AppEngine::API::Users;
use AppEngine::APIProxy;
use AppEngine::Python;
use Data::Dumper;
use Test::More tests => 10;

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


# Test putting and getting undef
$entity = AppEngine::API::Datastore::Entity->new('kind');
$entity->{nothing} = undef;
ok(exists $entity->{nothing});
$entity->put;

$entity = AppEngine::API::Datastore->get($entity->key);
ok(!exists $entity->{nothing});
