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
    $query->ancestor($key);

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
use Readonly;

Readonly my $SERVICE   => 'datastore_v3';
Readonly my %OPERATORS => (
    '<'  => AppEngine::Service::Datastore::Query::Filter::Operator::LESS_THAN,
    '<=' => AppEngine::Service::Datastore::Query::Filter::Operator::LESS_THAN_OR_EQUAL,
    '>'  => AppEngine::Service::Datastore::Query::Filter::Operator::GREATER_THAN,
    '>=' => AppEngine::Service::Datastore::Query::Filter::Operator::GREATER_THAN_OR_EQUAL,
    '='  => AppEngine::Service::Datastore::Query::Filter::Operator::EQUAL,
    'IN' => AppEngine::Service::Datastore::Query::Filter::Operator::IN,
);

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

=item set_limit ( limit )

Limits the number of entities that will be returned by the query.

If limit is not provided (or undef), any previously set limit will be cleared.

Note that Datastore will return at most 1000 entities to the application,
regardless of the limit set by set_limit().
If you need to get more than 1000 entities you should make multiple queries
and use set_offset().

=cut

sub set_limit {
    my ($self, $limit) = @_;

    if (defined $limit) {
        $self->{_pb}->set_limit($limit);
    } else {
        $self->{_pb}->clear_limit;
    }
}

=item set_offset ( offset )

Sets the number of results that will be skipped by the query.
Note than setting an offset of '1' means 'skip the first result' - not 'start
from the first result'.

For example, if you want only the 5th result from a query:

 $query->set_limit(1);
 $query->set_offset(4);

If offset is not provided (or undef), any previously set offset will be cleared.

=cut

sub set_offset {
    my ($self, $offset) = @_;

    if (defined $offset) {
        $self->{_pb}->set_offset($offset);
    } else {
        $self->{_pb}->clear_offset;
    }
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
    $property = '__key__' if $property eq 'key';

    my $order = $self->{_pb}->add_order;
    $order->set_property($property);

    $order->set_direction(
        AppEngine::Service::Datastore::Query::Order::Direction::DESCENDING) if $descending;
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

my $filter_re_str = '^([^\s]+)(?:\s+(' . join('|', keys %OPERATORS) . '))?\s*$';
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
    $filter->set_op($OPERATORS{$operator});

    AppEngine::API::Datastore::Entity::_add_property($filter, $property, $value);
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

    my $type = ref $ancestor;

    if ($type && $type eq 'AppEngine::API::Datastore::Entity') {
        $ancestor = $ancestor->key;
    } elsif ($type && $type ne 'AppEngine::API::Datastore::Key') {
        croak 'expected Key or Entity, got ' . $type;
    } elsif (!$type) {
        # It might be an encoded key
        $ancestor = AppEngine::API::Datastore::Key->new($ancestor);
    }

    $ancestor->_to_pb($self->{_pb}->ancestor);
}


=item count

Returns the number of results this query fetches.

count() is somewhat faster than retrieving all of the data by a constant factor,
but the running time still grows with the size of the result set.
It's best to only use count() in cases where the count is expected to be small.

Note: count() returns a maximum of 1000.
If the actual number of entities that match the query criteria exceeds the
maximum, count() returns a count of 1000.

=cut

sub count {
    my $self = shift;

    my $res_bytes = AppEngine::APIProxy::sync_call($SERVICE, 'Count', $self->{_pb});
    my $res = AppEngine::Service::Integer32Proto->new;
    $res->parse_from_string($res_bytes);

    return $res->value;
}

sub _execute {
    my $self = shift;

    my $res_bytes = AppEngine::APIProxy::sync_call($SERVICE, 'RunQuery', $self->{_pb});
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
        unless ($self->{_more_results}) {
            # Reset the Query so the next call to fetch() starts again
            $self->{_cursor} = undef;
            return;
        }

        # Buffer is empty, so get some more results
        my $req = AppEngine::Service::Datastore::NextRequest->new;
        $req->set_cursor($self->{_cursor});
        $req->set_count($self->{_buffer_size});

        my $res_bytes = AppEngine::APIProxy::sync_call($SERVICE, 'Next', $req);
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
