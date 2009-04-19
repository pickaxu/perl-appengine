#!/usr/bin/perl

use strict;
use warnings;

use AppEngine::AppConfig;
use FindBin qw($Bin);
use Test::More tests => 18;

my $config = AppEngine::AppConfig->new("$Bin/advanced.yaml");

# Does is for two values
sub is2 {
    my ($actual1, $actual2, $expected1, $expected2, $test_name) = @_;

    is($actual1, $expected1, $test_name);
    is($actual2, $expected2, $test_name);
}

is2($config->handler_for_path('/'), undef, undef);
is2($config->handler_for_path('/404'), undef, undef);

is2($config->handler_for_path('/staticdir'), 'static', 'foo');
is2($config->handler_for_path('/staticdir/'), 'static', 'foo');
is2($config->handler_for_path('/staticdir/test.html'), 'static', 'foo/test.html');

is2($config->handler_for_path('/urlre1/foo'), 'script', 'bar.pl');
is2($config->handler_for_path('/urlre123a/foo'), undef, undef);

is2($config->handler_for_path('/backrefs/foo/bar'), 'script', 'foo-bar.pl');

is2($config->handler_for_path('/staticfiles/1234.png'), 'static', 'images/png/1234');

