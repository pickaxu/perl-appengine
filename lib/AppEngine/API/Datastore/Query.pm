package AppEngine::API::Datastore::Query;

use strict;
use warnings;

use AppEngine::API::Datastore::Entity;
use AppEngine::Service::Datastore;
use Carp;
use Data::Dumper;

use constant SERVICE => 'datastore_v3';

our $DEFAULT_BUFFER_SIZE = 20;

sub new {
    my ($pkg, $kind) = @_;

    my $pb = AppEngine::Service::Datastore::Query->new;
    $pb->set_app($ENV{APPLICATION_ID});
    $pb->set_kind($kind);

    my $self = {
        _pb           => $pb,
        _cursor       => undef,
        _buffer       => [],
        _buffer_size  => $DEFAULT_BUFFER_SIZE,
        _more_results => 0,
    };
    bless $self, $pkg;

    return $self;
}

sub set_limit {
    $_[0]->{_pb}->set_limit($_[1]);
}

sub set_offset {
    $_[0]->{_pb}->set_offset($_[1]);
}

sub order {
    my ($self, $property) = @_;
    croak 'expected name of property to order by' unless defined($property);

    my $descending = $property =~ s/^-//;

    my $order = $self->{_pb}->add_order;
    $order->set_property($property);

    # TODO(davidsansome): how to use the enum name from the protobuf?
    $order->set_direction(2) if $descending;
}

sub _execute {
    my $self = shift;

    my $res_bytes = AppEngine::APIProxy::sync_call(SERVICE, 'RunQuery', $self->{_pb});
    my $res = AppEngine::Service::Datastore::QueryResult->new;
    $res->parse_from_string($res_bytes);

    $self->{_cursor} = $res->cursor;
    $self->{_more_results} = $res->more_results;
}

sub fetch {
    my $self = shift;
    $self->_execute unless $self->{_cursor} || $self->{_more_results};

    if (@{$self->{_buffer}} == 0) {
        return unless $self->{_more_results};

        # Buffer is empty, so get some more results
        my $req = AppEngine::Service::Datastore::NextRequest->new;
        $req->set_cursor($self->{_cursor});
        $req->set_count($self->{_buffer_size});

        my $res_bytes = AppEngine::APIProxy::sync_call(SERVICE, 'Next', $req);
        my $res = AppEngine::Service::Datastore::QueryResult->new;
        $res->parse_from_string($res_bytes);

        $self->{_more_results} = $res->more_results;

        # Put results in the buffer
        foreach my $result (@{$res->results}) {
            push @{$self->{_buffer}}, AppEngine::API::Datastore::Entity::_from_pb($result);
        }
    }

    return shift @{$self->{_buffer}};
}

1;
