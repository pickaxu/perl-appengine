package AppEngine::API::Datastore::Entity;

use strict;
use warnings;

=head1 NAME

AppEngine::API::Datastore::Entity - An object that can be stored in datastore

=head1 SYNOPSIS

    use AppEngine::API::Datastore::Entity;
    
    my $p = AppEngine::API::Datastore::Entity->new('Person');
    $p->{name} = 'Dave';
    $p->{awesomeness} = 100;
    
    $p->put;

=head1 DESCRIPTION

An Entity represents an object that can be stored or retrieved from datastore.

An application creates a new data entity of a given C<kind> by calling new().
Properties of an entity can be assigned by treating the entity as a hash, or by
passing a hashref to the constructor:

    my $s = AppEngine::API::Datastore::Entity->new('Story');
    $s->{title} = 'The Three Little Pigs';
    
    my $s = AppEngine::API::Datastore::Entity->new('Story', {
        title => 'The Three Little Pigs',
    });

Properties whose names begin with an underscore (_) are ignored, so your
application can use such attributes to store data on an entity that
isn't saved to the datastore.

A data entity can have an optional parent entity.
Parent-child relationships form entity groups, which are used to control
transactionality and data locality in the datastore.
An application creates a parent-child relationship between two entities by
passing the parent entity to the child entity's constructor, as the C<parent>
argument.

Every entity has a key, a unique identifier that represents the entity.
An entity can have an optional key name, a string unique across entities of the
given kind.

B<Note:> An Entity instance does not have a corresponding entity in the
datastore until it is put() for the first time.

=head1 METHODS

=over

=cut

use Carp;
use AppEngine::API::Datastore;
use AppEngine::API::Datastore::Key;
use AppEngine::Service::Entity;

=item new ( kind [, named_args ] [, initial_properties ] )

Creates a new entity of the given C<kind>.

Two optional named arguments can be provided:

=over

=item I<parent>

The Model instance or Key instance for the entity that is the new entity's parent.

=item I<key_name>

The name for the new entity. 
The name becomes part of the primary key.
If key_name is not specified, a system-generated ID is used for the key.

The value for key_name must not start with a number, and must not be of the 
form __*__.
If your application uses user-submitted data as datastore entity key names
(such as an email address), the application should sanitize the value first,
such as by prefixing it with a known string like "key:", to meet these
requirements.

=back

Initial values for the entity's properties can be passed as a hashref to the
constructor.

=cut

sub new {
    my ($pkg, $kind) = @_;
    croak 'kind not provided' unless $kind;

    my $key_name = 0;
    my $parent = undef;
    my %extra;

    # Parse other arguments
    while (my $arg = shift) {
        if (ref($arg) eq 'HASH') {
            %extra = %$arg;
        } elsif ($arg eq 'parent') {
            $parent = shift;
        } elsif ($arg eq 'key_name') {
            $key_name = shift;
            next unless $key_name;

            croak 'key_name cannot begin with a number' if $key_name =~ m/^\d/;
        }
    }

    my $key ||= AppEngine::API::Datastore::Key::from_path(
        [$kind, $key_name],
        parent => $parent,
    );

    my $self = {
        __kind__     => $kind,
        __key__      => $key,
        __is_saved__ => 0,
        %extra
    };
    bless $self, $pkg;

    return $self;
}

=item kind

Returns the kind of the entity, as a string.

=cut

sub kind {
    return $_[0]->{__kind__};
}

=item key

Returns the datastore Key instance for this entity.
The Key returned by this function will not be complete until the entity has
been put() in the datastore.

=cut

sub key {
    return $_[0]->{__key__};
}

=item put

Stores the entity in the datastore. 
If the entity is newly created and has never been stored, this method creates a
new data entity in the datastore.
Otherwise, it updates the data entity with the current property values.

The method returns the Key of the stored entity.

Equivalent to:

    AppEngine::API::Datastore->put($entity);

=cut

sub put {
    return AppEngine::API::Datastore->put($_[0]);
}

=item delete

Deletes the model instance from the datastore.

Equivalent to:

    AppEngine::API::Datastore->delete($entity);

=cut

sub delete {
    AppEngine::API::Datastore->delete($_[0]);
}

=item is_saved

Returns true if the entity has been put() into the datastore at least once.

This method only checks that the entity has been stored at least once since it
was created.
It does not check if the entity's properties have been updated since the last
time it was put().

=cut

sub is_saved {
    return $_[0]->{__is_saved__};
}

=item parent

Returns an Entity object for the parent entity of this instance, or undef if
this entity does not have a parent.

Calling this method always results in an API call to datastore, and the result
is not cached.

Equivalent to:

    AppEngine::API::Datastore->get($entity->parent_key);

=cut

sub parent {
    # TODO(davidsansome): maybe cache this?  update POD
    return AppEngine::API::Datastore->get($_[0]->parent_key);
}

=item parent_key

Returns the Key of the parent entity of this entity, or undef if this entity
does not have a parent.

=cut

sub parent_key {
    return $_[0]->key->parent;
}



# Internal methods

sub _set_saved {
    my ($self, $key) = @_;

    $self->{__is_saved__} = 1;
    $self->{__key__} = $key;
}

sub _from_pb {
    my ($pb) = @_;

    my $key = AppEngine::API::Datastore::Key::_from_pb($pb->key);

    my $self = {
        __kind__     => $key->kind,
        __key__      => $key,
        __is_saved__ => 1,
    };
    bless $self, __PACKAGE__;

    foreach my $element (@{$pb->propertys}) {
        my $value;
        my $value_pb = $element->value;
        if ($value_pb->has_int64Value) {
            $value = $value_pb->int64Value;
        } elsif ($value_pb->has_doubleValue) {
            $value = $value_pb->doubleValue;
        } elsif ($value_pb->has_stringValue) {
            $value = $value_pb->stringValue;
        } elsif ($value_pb->has_uservalue) {
            $value = AppEngine::API::Users::User::_from_pb(
                $value_pb->uservalue);
        } elsif ($value_pb->has_referencevalue) {
            my $ref_key = AppEngine::API::Datastore::Key::_from_reference_value_pb(
                $value_pb->referencevalue);

            $value = AppEngine::API::Datastore::LazyEntity->new($ref_key);
        } else {
            croak 'unknown property value type';
        }

        $self->{$element->name} = $value;
    }

    return $self;
}

sub _to_pb {
    my ($self, $pb) = @_;

    $self->key->_to_pb($pb->key);

    my $group = $pb->entity_group;
    if ($self->key->has_id_or_name) {
        # I don't understand *why* we only set an entity group if we have an
        # ID or name, but the python does it and datastore complains if we
        # don't
        $self->key->entity_group->_path_to_pb($group);
    }

    # Add properties
    while ((my $key, my $value) = each %$self) {
        next if $key =~ m/^_/;
        next unless defined $value;

        my $property_value = $pb->add_property;
        _property_to_pb($property_value, $key, $value);
    }
}

sub _property_to_pb {
    my ($property_value, $key, $value) = @_;

    # This is a bit of a hack
    $key = '__key__' if $key eq 'key';

    if ($key eq '__key__' && !ref $value) {
        $value = AppEngine::API::Datastore::Key->new($value);
    }

    $property_value->set_name($key);
    $property_value->set_multiple(0);

    if (ref $value) {
        if ($value->isa('AppEngine::API::Datastore::Key')) {
            $value->_to_reference_value_pb($property_value->value->referencevalue);
        } elsif ($value->isa('AppEngine::API::Datastore::Entity')) {
            $value->key->_to_reference_value_pb($property_value->value->referencevalue);
        } elsif ($value->isa('AppEngine::API::Users::User')) {
            $value->_to_pb($property_value->value->uservalue);
        }
    } else {
        if ($value =~ m/^[+-]?\d+$/) {
            $property_value->value->set_int64Value($value);
        } elsif ($value =~ m/^[+-]?[\d.]+$/) {
            $property_value->value->set_doubleValue($value);
        } else {
            $property_value->value->set_stringValue($value);
        }
    }
}


1;
