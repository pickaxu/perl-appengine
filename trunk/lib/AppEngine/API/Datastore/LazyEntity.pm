package AppEngine::API::Datastore::LazyEntity;

use strict;
use warnings;

=head1 NAME

AppEngine::API::Datastore::LazyEntity - an entity that is fetched from the
datastore only when one of its fields is accessed.

=head1 DESCRIPTION

You shouldn't need to use this package directly.
Instances of LazyEntity are created when an Entity with one or more reference
values is loaded from the datastore.

=head1 METHODS

=over

=cut

use AppEngine::API::Datastore;
use AppEngine::API::Datastore::Key;
use AppEngine::Service::Entity;
use Carp;

use base qw(AppEngine::API::Datastore::Entity);

=item new ( key )

Creates a new LazyEntity that references the Entity with the given key.
The referenced entity is not loaded from the datastore straight away - it is
only loaded when one of its fields is accessed.

=cut

sub new {
    my ($pkg, $key) = @_;

    tie my %hash, __PACKAGE__, $key;
    my $self = \%hash;
    bless $self, $pkg;
    return $self;
}

=item is_loaded

Returns true if the actual Entity has been loaded yet.

=cut

sub is_loaded {
    return $_[0]->{__is_loaded__};
}

sub TIEHASH {
    my ($pkg, $key) = @_;

    my $self = {
        __kind__      => $key->kind,
        __key__       => $key,
        __is_saved__  => 1,
        __is_loaded__ => 0,
    };
    return bless $self, $pkg;
}

sub FETCH {
    my ($self, $key) = @_;

    if ($key !~ m/^_/) {
        $self->_ensure_loaded;
    }

    return $self->{$key};
}

sub STORE {
    my ($self, $key, $value) = @_;
    $self->_ensure_loaded;

    $self->{$key} = $value;
}

sub DELETE {
    my ($self, $key) = @_;
    $self->_ensure_loaded;

    return delete $self->{$key};
}

sub EXISTS {
    my ($self, $key) = @_;
    $self->_ensure_loaded;

    return exists $self->{$key};
}

sub FIRSTKEY {
    my $self = shift;
    $self->_ensure_loaded;

    my $a = keys %$self; # reset each() iterator
    return each %$self;
}

sub NEXTKEY {
    my $self = shift;
    return each %$self;
}

sub SCALAR {
    my $self = shift;
    $self->_ensure_loaded;

    return %$self;
}

sub _ensure_loaded {
    my $self = shift;
    return if $self->{__is_loaded__};

    # Load the entity and copy all its data into $self
    my $entity = AppEngine::API::Datastore->get($self->key);
    foreach my $key (keys %$entity) {
        next if $key =~ m/^_/;
        $self->{$key} = $entity->{$key};
    }

    $self->{__is_loaded__} = 1;
}


1;
