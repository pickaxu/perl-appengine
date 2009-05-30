#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::API::Users;
use AppEngine::APIProxy;
use AppEngine::Python;
use Data::Dumper;
use Test::More tests => 14;
use URI::Escape;

AppEngine::Python::initialize('appname');
$AppEngine::APIProxy::bypass_client = 1;
$ENV{SERVER_NAME} = 'servername';
$ENV{SERVER_PORT} = '1234';

# Test the login and logout URL functions
is(uri_unescape(users_create_login_url('/')),
    '/_ah/login?continue=http://servername:1234/');
is(uri_unescape(users_create_logout_url('/')),
    '/_ah/login?continue=http://servername:1234/&action=Logout');

is(uri_unescape(users_create_login_url('/path')),
    '/_ah/login?continue=http://servername:1234/path');
is(uri_unescape(users_create_logout_url('/path')),
    '/_ah/login?continue=http://servername:1234/path&action=Logout');


# Test with no logged in user
delete $ENV{COOKIE};
AppEngine::Python::initialize('appname');

my $user = users_get_current_user();
ok(!defined $user);
ok(!users_is_current_user_admin());


# Test with a normal (non-admin) user
$ENV{COOKIE} = 'dev_appserver_login=user@example.com:False';
AppEngine::Python::initialize('appname');

$user = users_get_current_user();
isa_ok($user, 'AppEngine::API::Users::User');
is($user->nickname, 'user@example.com');
is($user->email,    'user@example.com');
ok(!users_is_current_user_admin());


# Test with an admin user
$ENV{COOKIE} = 'dev_appserver_login=user@example.com:True';
AppEngine::Python::initialize('appname');

$user = users_get_current_user();
isa_ok($user, 'AppEngine::API::Users::User');
is($user->nickname, 'user@example.com');
is($user->email,    'user@example.com');
ok(users_is_current_user_admin());

