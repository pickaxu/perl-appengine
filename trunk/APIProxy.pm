# Devserver implementation of devappserver, sending the request
# up a file descriptor to the parent process which sends it down
# to the python sdk to use the python mock implementations.
# TODO(bradfitz): actually do that. :) for now just lines of text.

package APIProxy;
use strict;

open(my $apiproxy, "<&=3") or die "Failed to open apiproxy fd: $!";

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
        $message = $message->as_string();
    }
    die "Bogus message" if ref($message);
    my $len = length $message;
    my $request = "apiproxy $service $method $len\n$message";
    syswrite($apiproxy, $request);
    my $res = <$apiproxy>;
    die "Bogus apiproxy response: $res" unless
        $res =~ s/^apiresult ([01]) (\d+)\n//;
    my ($success, $length) = ($1, $2);
    my $body;
    read($apiproxy, $body, $length) == $length or die;
    if ($success) {
        return $body;
    } else {
        die "APIProxy error: $body\n";
    }
}

# old simple echo test.
sub chat_line {
    my ($request) = @_;
    syswrite($apiproxy, $request);
    return scalar <$apiproxy>;
}

1;
