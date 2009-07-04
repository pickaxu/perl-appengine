#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::API::Datastore;
use AppEngine::API::Datastore::Entity;
use AppEngine::API::Datastore::Query;
use AppEngine::APIProxy;
use AppEngine::Python;
use Data::Dumper;
use Test::More;

if ($ENV{EXPENSIVE_TESTS}) {
    plan tests => 25;
} else {
    plan skip_all => 'expensive test - export EXPENSIVE_TESTS=1 to run';
}

AppEngine::Python::initialize('appname');
$AppEngine::APIProxy::bypass_client = 1;
$ENV{APPLICATION_ID} = 'appname';

my $kind = 'limit.t_' . $$ . '_' . int(rand(100000));

# Save 1002 entities
for my $i (1..1002) {
    my $entity = AppEngine::API::Datastore::Entity->new($kind);
    $entity->{number} = $i;
    $entity->put;
}

# Run a query with a limit of 10
my $query = AppEngine::API::Datastore::Query->new($kind);
$query->set_limit(10);
$query->order('number');

is($query->count, 10);

my $i = 0;
while (my $entity = $query->fetch) {
    $i ++;
    is($entity->{number}, $i);
}
is($i, 10);

# Now get 16-25
$query->set_offset(15);
$i = 15;
while (my $entity = $query->fetch) {
    $i ++;
    is($entity->{number}, $i);
}
is($i, 25);


# Get as many as datastore will allow - should be 1000
$query->set_limit(undef);
$query->set_offset(undef);

$i = 0;
while (my $entity = $query->fetch) {
    $i ++;
}
is($i, 1000);

# Another query should get the last 2
$query->set_offset(1000);
while (my $entity = $query->fetch) {
    $i ++;
}
is($i, 1002);
