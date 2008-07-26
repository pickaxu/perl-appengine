# Devserver implementation of devappserver, sending the request
# up a file descriptor to the parent process which sends it down
# to the python sdk to use the python mock implementations.
# TODO(bradfitz): actually do that. :) for now just lines of text.

package APIProxy;
use strict;

open(my $apiproxy, "<&=3") or die "Failed to open apiproxy fd: $!";

sub sync_call {
    my ($request) = @_;
    syswrite($apiproxy, $request);
    return scalar <$apiproxy>;
    
}

1;