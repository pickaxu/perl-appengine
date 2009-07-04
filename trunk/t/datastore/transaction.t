#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::API::Datastore;
use AppEngine::API::Datastore::Entity;
use AppEngine::APIProxy;
use AppEngine::Python;
use Data::Dumper;
use Test::More tests => 11;

AppEngine::Python::initialize('appname');
$AppEngine::APIProxy::bypass_client = 1;
$ENV{APPLICATION_ID} = 'appname';

my $db = AppEngine::API::Datastore->new;
ok(!$db->in_transaction);

# Make an entity outside the transaction
my $entity = AppEngine::API::Datastore::Entity->new('test');
$entity->{foo} = 'bar';

$db->run_in_transaction(sub {
    ok($db->in_transaction);

    ok(!$entity->is_saved);
    $entity->put;
    ok($entity->is_saved);
});
ok(!$db->in_transaction);

my $key = $entity->key;

# Get the entity back again
$entity = $db->get($key);
is($entity->{foo}, 'bar');


# Now try again - but rollback the transaction instead of committing
$entity = AppEngine::API::Datastore::Entity->new('test');
$entity->{foo} = 'bar';

$db->run_in_transaction(sub {
    ok(!$entity->is_saved);
    $entity->put;
    ok($entity->is_saved);

    $db->rollback;
    fail("rollback didn't cause the function to return");
});

$key = $entity->key;

# Get the entity back again - it shouldn't exist
$entity = $db->get($key);
ok(!defined $entity);


# Test we can pass arguments to transaction functions, and get return values back
my $ret = $db->run_in_transaction(sub {
    is_deeply([@_], [qw(one two)]);
    return 'ret';
}, 'one', 'two');
is($ret, 'ret');
