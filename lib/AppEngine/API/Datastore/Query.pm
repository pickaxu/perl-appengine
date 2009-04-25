package AppEngine::API::Datastore::Query;

use strict;
use warnings;

=head1 NAME

AppEngine::API::Datastore::Query - Perl version of google.appengine.ext.db.Query

=head1 SYNOPSIS

    use AppEngine::API::Datastore::Query;

    my $query = AppEngine::API::Datastore::Query->new('Song');
    $query->filter('title =', 'Imagine');
    $query->order('-date');
    $query->ancestor(key);

    while (my $song = $query->fetch) {
        print $song->{title}, "\n";
    }

=head1 DESCRIPTION

Datastore query interface that uses objects and methods to prepare queries.

=head1 METHODS

=over

=cut

use AppEngine::API::Datastore::Entity;
use AppEngine::Service::Base;
use AppEngine::Service::Datastore;
use Carp;
use Data::Dumper;

use constant SERVICE   => 'datastore_v3';
use constant OPERATORS => {
    '<'  => 1,
    '<=' => 2,
    '>'  => 3,
    '>=' => 4,
    '='  => 5,
    'IN' => 6,
};

our $DEFAULT_BUFFER_SIZE = 20;


=item new ( kind )

Creates a new Query object that will return all entities of the given C<kind>.
The instance methods filter(), order() and ancestor() apply criteria to the
query to filter or order the results.

=cut

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


=item order ( property )

Adds an ordering for the results.
Results are ordered starting with the first order added.

C<property> is the name of the property to order.
By default results are returned in ascending order.
To specify that the order ought to be descending, precede the name with a
hyphen ( - ).

Examples:

    # Order by last name, alphabetical:
    $query->order('last_name');

    # Order tallest to shortest:
    $query->order('-height');

=cut

sub order {
    my ($self, $property) = @_;
    croak 'expected name of property to order by' unless defined($property);

    my $descending = $property =~ s/^-//;

    my $order = $self->{_pb}->add_order;
    $order->set_property($property);

    # TODO(davidsansome): how to use the enum name from the protobuf?
    $order->set_direction(2) if $descending;
}


=item filter ( property_operator, value )

Adds a property condition filter to the query.
Only entities with properties that meet all of the conditions will be returned
by the query.

C<property_operator> is a string containing the property name, and an optional
comparison operator.
The name and the operator must be separated by a space, as in: C<age E<gt>>.
The following comparison operators are supported: < <= = >= > IN.
If the operator is omitted from the string (the argument is just the property
name), the filter uses the = operator.

C<value> is the value to use in the comparison on the right-hand side of the
expression.

Example:

    $query->filter('height >', 42);
    $query->filter('city = ', 'Seattle');

=cut

my $filter_re_str = '^([^\s]+)(?:\s+(' . join('|', keys %{OPERATORS()}) . '))?\s*$';
my $filter_re = qr/$filter_re_str/;

sub filter {
    my ($self, $property_operator, $value) = @_;
    $property_operator =~ $filter_re
        or croak 'invalid property/operator: ' . $property_operator;

    # TODO(davidsansome): support for !=
    # The python SDK does this by running two queries - one for < and one for >

    my $property = $1;
    my $operator = $2 || '=';

    my $filter = $self->{_pb}->add_filter;
    $filter->set_op(OPERATORS->{$operator});

    AppEngine::API::Datastore::Entity::_property_to_pb($filter->add_property, $property, $value);
}


=item ancestor ( ancestor )

Adds an ancestor condition filter to the query.
Only entities with the given entity as an ancestor (anywhere in its path) will
be returned by the query.

C<ancestor> is a Model instance or Key instance representing the ancestor.

=cut

sub ancestor {
    my ($self, $ancestor) = @_;
    croak 'missing ancestor' unless $ancestor;

    my $type = ref($ancestor);

    if ($type eq 'AppEngine::API::Datastore::Entity') {
        $ancestor = $ancestor->key;
    } elsif ($type ne 'AppEngine::API::Datastore::Key') {
        croak 'expected Key or Entity, got ' . $type;
    }

    $ancestor->_to_pb($self->{_pb}->ancestor);
}


=item count

Returns the number of results this query fetches.

count() is somewhat faster than retrieving all of the data by a constant factor,
but the running time still grows with the size of the result set.
It's best to only use count() in cases where the count is expected to be small,
or specify a limit.

Note: count() returns a maximum of 1000.
If the actual number of entities that match the query criteria exceeds the
maximum, count() returns a count of 1000.

=cut

sub count {
    my $self = shift;

    my $res_bytes = AppEngine::APIProxy::sync_call(SERVICE, 'Count', $self->{_pb});
    my $res = AppEngine::Service::Integer32Proto->new;
    $res->parse_from_string($res_bytes);

    return $res->value;
}

sub _execute {
    my $self = shift;

    my $res_bytes = AppEngine::APIProxy::sync_call(SERVICE, 'RunQuery', $self->{_pb});
    my $res = AppEngine::Service::Datastore::QueryResult->new;
    $res->parse_from_string($res_bytes);

    $self->{_cursor} = $res->cursor;
    $self->{_more_results} = $res->more_results;
}


=item fetch

Fetches the next result from the query, and returns undef when there are no more
results.

By default this method fetches results in bursts of 20, buffering them
internally and returning one at a time.
You can change the size of this buffer with set_buffer_size().

Example:

    while (my $song = $query->fetch) {
        print $song->{title}, "\n";
    }

=cut

sub fetch {
    my ($self, $peek) = @_;
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

    return $self->{_buffer}[0] if $peek;
    return shift @{$self->{_buffer}};
}


=item set_buffer_size ( size )

Sets the buffer size for this query object to C<size>.
See fetch() for information on how this is used.

You can also set the default buffer size for newly created queries with:

    $AppEngine::API::Datastore::Query::DEFAULT_BUFFER_SIZE = $size;

But be aware that this will affect B<all> the queries in your application.

=cut

sub set_buffer_size {
    $_[0]->{_buffer_size} = $_[1];
}

1;
