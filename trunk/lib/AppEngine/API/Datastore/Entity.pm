package AppEngine::API::Datastore::Entity;

use strict;
use warnings;

use Carp;
use AppEngine::API::Datastore;
use AppEngine::API::Datastore::Key;
use AppEngine::Service::Entity;


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

    # TODO(davidsansome): nicer way to find type of a scalar?

    my $type = ref $value;
    if ($type eq 'AppEngine::API::Datastore::Key') {
        $value->_to_reference_value_pb($property_value->value->referencevalue);
    } elsif ($type eq 'AppEngine::API::Datastore::Entity') {
        $value->key->_to_reference_value_pb($property_value->value->referencevalue);
    } elsif ($value =~ m/^[+-]?\d+$/) {
        $property_value->value->set_int64Value($value);
    } elsif ($value =~ m/^[+-]?[\d.]+$/) {
        $property_value->value->set_doubleValue($value);
    } else {
        $property_value->value->set_stringValue($value);
    }
}

sub _set_saved {
    my ($self, $key) = @_;

    $self->{__is_saved__} = 1;
    $self->{__key__} = $key;
}

sub kind {
    return $_[0]->{__kind__};
}

sub key {
    return $_[0]->{__key__};
}

sub put {
    return AppEngine::API::Datastore::put($_[0]);
}

sub delete {
    AppEngine::API::Datastore::delete($_[0]);
}

sub is_saved {
    return $_[0]->{__is_saved__};
}

sub parent {
    # TODO(davidsansome): maybe cache this?
    return AppEngine::API::Datastore::get($_[0]->parent_key);
}

sub parent_key {
    return $_[0]->key->parent;
}


1;
