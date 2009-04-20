#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::API::Datastore::Entity;
use AppEngine::API::Datastore::Query;
use AppEngine::APIProxy;
use Data::Dumper;
use Test::More tests => 29;

$AppEngine::APIProxy::bypass_client = 1;
$ENV{APPLICATION_ID} = 'appid';

# Get a unique-ish kind, so we don't have to clear the DB before running tests
my $kind = 'QueryTest_' . $$ . '_' . rand(100000);


sub run_query {
    my $q = shift;
    my @results;
    while (my $e = $q->fetch) {
        push @results, $e;
    }
    return @results;
}


# Add some sample data
AppEngine::API::Datastore::Entity->new($kind, {
    name => 'bob',
    age  => 20,
})->put;
AppEngine::API::Datastore::Entity->new($kind, {
    name => 'larry',
    age  => 42,
})->put;
my $moe_key = AppEngine::API::Datastore::Entity->new($kind, {
    name => 'moe',
    age  => 31,
})->put;


# Test that a basic query works
my $q = AppEngine::API::Datastore::Query->new($kind);
my @results = run_query($q);
@results = sort { $a->{name} cmp $b->{name} } @results;

is(scalar(@results), 3);
is($results[0]->{name}, 'bob');
is($results[0]->{age}, 20);
is($results[1]->{name}, 'larry');
is($results[1]->{age}, 42);
is($results[2]->{name}, 'moe');
is($results[2]->{age}, 31);


# Test ordering
# Ascending...
$q = AppEngine::API::Datastore::Query->new($kind);
$q->order('age');
@results = run_query($q);

is(scalar(@results), 3);
is($results[0]->{name}, 'bob');
is($results[0]->{age}, 20);
is($results[1]->{name}, 'moe');
is($results[1]->{age}, 31);
is($results[2]->{name}, 'larry');
is($results[2]->{age}, 42);

# Descending...
$q = AppEngine::API::Datastore::Query->new($kind);
$q->order('-age');
@results = run_query($q);

is(scalar(@results), 3);
is($results[0]->{name}, 'larry');
is($results[0]->{age}, 42);
is($results[1]->{name}, 'moe');
is($results[1]->{age}, 31);
is($results[2]->{name}, 'bob');
is($results[2]->{age}, 20);


# Test filter operators
# =
$q = AppEngine::API::Datastore::Query->new($kind);
$q->filter('name =', 'larry');
@results = run_query($q);

is(scalar(@results), 1);
is($results[0]->{name}, 'larry');

# >
$q = AppEngine::API::Datastore::Query->new($kind);
$q->filter('age <', 25);
@results = run_query($q);

is(scalar(@results), 1);
is($results[0]->{name}, 'bob');


# Give moe a child
AppEngine::API::Datastore::Entity->new($kind, parent => $moe_key, {
    name => 'littlemoe',
    age  => 4,
})->put;

# Test ancestor
$q = AppEngine::API::Datastore::Query->new($kind);
$q->ancestor($moe_key);
$q->order('age');
@results = run_query($q);

is(scalar(@results), 2);
is($results[0]->{name}, 'littlemoe');
is($results[1]->{name}, 'moe');


# Test count
$q = AppEngine::API::Datastore::Query->new($kind);
$q->filter('age <', 30);
is($q->count, 2);
