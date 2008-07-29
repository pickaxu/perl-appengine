#!/usr/bin/perl
#
# Compile proto/*.proto to lib/AppEngine/Service/*.pm
#

use strict;
use FindBin qw($Bin);

# Prefer the local dev compiler, else use the system-installed protoc.
my $compiler_dir = "$Bin/../../protobuf-perl/protobuf/src";
my $compiler;
if (-d $compiler_dir) {
    chdir $compiler_dir or die;
    system("make", "-j2", "protoc") and die "Build of protoc failed.\n";
    $compiler = "$compiler_dir/protoc";
} else {
    $compiler = `which protoc`;
    chomp $compiler;
    die "No 'protoc' found in path.\n" unless $compiler;
}

die "Compiler $compiler isn't executable.\n" unless -x $compiler;

chdir("$Bin/..") or die;

for my $proto (glob("proto/*.proto")) {
    print "Compiling $proto ...\n";
    system($compiler,
           "--perl_out=lib",
           "-Iproto",
           $proto) and die "Failed.\n";
}




