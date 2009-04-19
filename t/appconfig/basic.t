#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More tests => 5;

use_ok('AppEngine::AppConfig');

my $config = AppEngine::AppConfig->new("$Bin/basic.yaml");

isa_ok($config, 'AppEngine::AppConfig');
can_ok($config, qw(handler_for_path));

is($config->handler_for_path('/'), 'app.pl');
is($config->handler_for_path('/foo'), 'app.pl');
