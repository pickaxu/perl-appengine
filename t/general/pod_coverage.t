#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Pod::Coverage;

# Don't include generated Protobuf modules
my @modules = grep !/::Service::/, all_modules();

plan tests => scalar @modules;

TODO: {
    local $TODO = 'not all modules documented yet';

    foreach my $module (@modules) {
        pod_coverage_ok($module);
    }
}
