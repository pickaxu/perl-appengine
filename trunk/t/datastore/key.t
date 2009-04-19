#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::API::Datastore::Key;
use AppEngine::Service::Entity;
use Test::More tests => 12;

$ENV{APPLICATION_ID} = 'appid';

my $key = AppEngine::API::Datastore::Key::from_path(['parentkind', 'parentname', 'kind', 'name']);
is($key->app, 'appid');
is($key->kind, 'kind');
is($key->id, 0);
is($key->name, 'name');
is($key->id_or_name, 'name');
ok($key->has_id_or_name);
# TODO(davidsansome): parent()

my $pb = AppEngine::Service::Entity::Reference->new;
$key->_to_pb($pb);
$key = AppEngine::API::Datastore::Key::_from_pb($pb);

is($key->app, 'appid');
is($key->kind, 'kind');
is($key->id, 0);
is($key->name, 'name');
is($key->id_or_name, 'name');
ok($key->has_id_or_name);
