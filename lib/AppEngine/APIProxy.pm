# Devserver implementation of devappserver, sending the request
# up a file descriptor to the parent process which sends it down
# to the python sdk to use the python mock implementations.

package AppEngine::APIProxy;

use warnings;
use strict;

use Data::Dumper;
use HTTP::Request::Common;
use LWP::UserAgent;

use base qw(Exporter);
our @EXPORT_OK = qw(sync_call become_apiproxy_client);

our $bypass_client = 0;

my $apiproxy;

sub sync_call {
    if (scalar @_ == 1) {
        return chat_line(@_);
    }
    if (scalar @_ != 3) {
        die "Wrong number of arguments to sync_call";
    }
    my ($service, $method, $message) = @_;
    die "Bogus service" unless $service =~ /^\w+$/;
    die "Bogus method" unless $method =~ /^\w+$/;
    if (UNIVERSAL::isa($message, "Protobuf::Message")) {
        $message = $message->serialize_to_string;
    }
    die "Bogus message" if ref($message);

    my ($success, $body);
    if ($bypass_client) {
        ($success, $body) = _make_request($service, $method, $message);
    }
    else {
        unless ($apiproxy) {
            open($apiproxy, "<&=3") or die "Failed to open apiproxy fd: $!";
        }

        my $len = length $message;
        my $request = "apiproxy $service $method $len\n$message";
        syswrite($apiproxy, $request);
        my $res = <$apiproxy>;
        die "Bogus apiproxy response: $res" unless
            $res =~ s/^apiresult ([01]) (\d+)\n//;
        ($success, $len) = ($1, $2);
        read($apiproxy, $body, $len) == $len or die;
    }

    return $body if $success;
    die "APIProxy error: $body\n";
}

sub become_apiproxy_client {
    my $socket = shift;

    select($socket);
    $| = 1;
    while (my $cmd = <$socket>) {
        chomp $cmd;
        unless ($cmd =~ /^apiproxy (\S+) (\S+) (\d+)/) {
            print STDERR "Unknown apiproxy line: [$cmd]\n";
            print $socket "You said: $cmd\n";
            next;
        }
        my ($service, $method, $request_length) = ($1, $2, $3);
        my $pb_request;
        my $rv = read($socket, $pb_request, $request_length);
        if ($rv != $request_length) {
            die "Failed to read entire request from app.";
        }

        my ($success, $body) = _make_request($service, $method, $pb_request);

        print $socket "apiresult $success ", length($body), "\n$body";
    }
}

sub _make_request {
    my $success = 1;
    my $body;

    eval { $body = AppEngine::Python::make_request(@_) };

    if ($@) {
        $body = $@;
        $success = 0;
    }

    return ($success, $body);
}

# old simple echo test.
sub chat_line {
    my ($request) = @_;
    syswrite($apiproxy, $request);
    return scalar <$apiproxy>;
}

1;
