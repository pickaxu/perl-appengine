#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::API::Datastore::Entity;
use AppEngine::APIProxy;
use Data::Dumper;
use DBI;
use Test::More tests => 8;

$AppEngine::APIProxy::bypass_client = 1;
$ENV{APPLICATION_ID} = 'apiproxy-python';

my $kind = 'DBDTest_' . $$ . '_' . int(rand(100000));


sub run_query {
    my $sth = shift;
    my @results;

    $sth->execute;
    while (my $row = $sth->fetchrow_arrayref) {
        push @results, [ @$row ];
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


# Get a dbh
my $dbh = DBI->connect('dbi:Datastore:');

# Try a basic select
my $sth = $dbh->prepare("SELECT name FROM $kind");

my @results = run_query($sth);
@results = sort { $a->[0] cmp $b->[0] } @results;
is(scalar @results, 3);
is($results[0]->[0], 'bob');
is($results[1]->[0], 'larry');
is($results[2]->[0], 'moe');



# Test ordering
# Ascending
$sth = $dbh->prepare("SELECT name FROM $kind ORDER BY age");

@results = run_query($sth);
is(scalar @results, 3);
is($results[0]->[0], 'bob');
is($results[1]->[0], 'moe');
is($results[2]->[0], 'larry');
