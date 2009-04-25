#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::API::Datastore::Entity;
use AppEngine::APIProxy;
use Data::Dumper;
use DBI;
use Test::More tests => 38;

$AppEngine::APIProxy::bypass_client = 1;
$ENV{APPLICATION_ID} = 'apiproxy-python';

my $kind = 'DBDTest_' . $$ . '_' . int(rand(100000));


sub run_query {
    my $sth = shift;
    my @results;

    $sth->execute(@_);
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

# Descending
$sth = $dbh->prepare("SELECT name FROM $kind ORDER BY age DESC");

@results = run_query($sth);
is(scalar @results, 3);
is($results[0]->[0], 'larry');
is($results[1]->[0], 'moe');
is($results[2]->[0], 'bob');


# Add another older larry
AppEngine::API::Datastore::Entity->new($kind, {
    name => 'larry',
    age  => 100,
})->put;

# Give moe a child
AppEngine::API::Datastore::Entity->new($kind, parent => $moe_key, {
    name => 'littlemoe',
    age  => 4,
})->put;


# Test filter operators
# =
$sth = $dbh->prepare("SELECT name FROM $kind WHERE name='larry'");

@results = run_query($sth);
is(scalar(@results), 2);
is($results[0]->[0], 'larry');
is($results[1]->[0], 'larry');

# AND
$sth = $dbh->prepare("SELECT name, age FROM $kind WHERE name='larry' and age=100");

@results = run_query($sth);
is(scalar(@results), 1);
is($results[0]->[0], 'larry');
is($results[0]->[1], 100);

# ANCESTOR IS
$sth = $dbh->prepare("SELECT name FROM $kind WHERE ANCESTOR IS ?");

@results = run_query($sth, $moe_key->str);
is(scalar(@results), 2);
is($results[0]->[0], 'moe');
is($results[1]->[0], 'littlemoe');


# Test bound values
$sth = $dbh->prepare("SELECT name, age FROM $kind WHERE name=? and age=?");

@results = run_query($sth, 'larry', 42);
is(scalar(@results), 1);
is($results[0]->[0], 'larry');
is($results[0]->[1], 42);


# Test SELECT *
$sth = $dbh->prepare("SELECT * FROM $kind");

@results = run_query($sth);
is(scalar(@results), 5);
foreach my $result (@results) {
    is(scalar @$result, 3);
}


# Test SELECT key
$sth = $dbh->prepare("SELECT key FROM $kind WHERE name='moe'");

@results = run_query($sth);
is(scalar(@results), 1);
is($results[0]->[0], $moe_key->str);


# Test WHERE key = ...
$sth = $dbh->prepare("SELECT name FROM $kind WHERE key=?");

@results = run_query($sth, $moe_key->str);
is(scalar(@results), 1);
is($results[0]->[0], 'moe');


# Test other ways of fetching rows
$sth = $dbh->prepare("SELECT age, name, key FROM $kind WHERE name='moe'");
$sth->execute;
my $row = $sth->fetchrow_hashref;
is($row->{name}, 'moe');
is($row->{age}, 31);
is($row->{key}, $moe_key->str);
