#!/usr/bin/perl
#
# Potential plan for apiproxy in dev environment server...
#
# server.pl (allocates listening socket for apiproxy)
#  |
#  +-- apiproxy (listening socket) for now, python server,
#  |   using mock implementations of apiproxy services from
#  |   Python Google's dev_appserver.py.  for now.  :)
#  |
#  +-+- client1 (creates socket pair, then forks apiproxy client)
#  | |
#  | +--- client1 apiproxy client (listens on socketpair for apiproxy
#  |      requests, forwards them to apiproxy (over TCP)
#  +-+- client2
#  | +--- client2 apiproxy client
#  +-+- client3
#    +--- client3 apiproxy client
#

use FindBin qw($Bin);
use lib "$Bin/lib";   # for running in dev without installing
use AppEngine::Server;
use Getopt::Long;

sub usage {
    warn <<END;
Runs a development application server for an application.

dev_appserver.pl [options] <application root>

Application root must be the path to the application to run in this server.
Must contain a valid app.pl file.

Options:
  --help, -h                 View this helpful message.
  TODO(bradfitz): steal more options from python dev_appserver

END

    exit(1);
}

my $opt_help;
my $bind_address;
usage() unless GetOptions(
    "address|a=s" => \$bind_address,
    "help|h"      => \$opt_help,
    # TODO(bradfitz): clone more of the interesting
    # options from python_sdk_partial/dev_appserver.py
    );

usage() if $opt_help;

my $app_dir = shift;
usage() unless $app_dir;
die "Directory doesn't exist.\n" unless -d $app_dir;
die "Forbidden characters in directory name.\n" if $app_dir =~ /[^\w\-\/\.]/;
die "Directory doesn't contain an app.pl file.\n" unless -e "$app_dir/app.pl";

AppEngine::Server->new(9000, $app_dir)->run;
