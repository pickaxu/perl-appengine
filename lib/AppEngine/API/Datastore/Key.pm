package AppEngine::API::Datastore::Key;

use strict;
use warnings;

use AppEngine::Service::Entity;
use Carp;
use MIME::Base64::URLSafe;

sub new {
    my ($pkg, $encoded) = @_;

    my $pb = AppEngine::Service::Entity::Reference->new;
    $pb->merge_from_string(urlsafe_b64decode($encoded));

    return _from_pb($pb);
}

sub from_path {
    my $ref = AppEngine::Service::Entity::Reference->new;
    $ref->set_app($ENV{APPLICATION_ID});

    my @path;

    while (my $arg = shift) {
        if (ref($arg) eq 'ARRAY') {
            croak 'path is empty'                  unless @$arg;
            croak 'odd number of elements in path' unless (@$arg % 2) == 0;

            push @path, @$arg;
        } elsif ($arg eq 'parent') {
            my $parent = shift;
            next unless $parent;

            if (ref($parent) eq 'AppEngine::API::Datastore::Entity') {
                $parent = $parent->key;
            } elsif (ref($parent) ne 'AppEngine::API::Datastore::Key') {
                croak 'expected Key or Entity for parent';
            }

            # Put the parent's path onto the beginning of this path
            unshift @path, $parent->path;
        }
    }

    croak 'path not provided' unless @path;

    # Set the path on the protobuf
    my $p = $ref->path;
    for (my $i = 0 ; $i < @path ; $i += 2) {
        my $element = $p->add_element;
        $element->set_type($path[$i]);

        if ($path[$i+1] =~ m/^\d/) {
            # Don't set the ID if we were passed 0 - this way has_id_or_name
            # will return false
            $element->set_id($path[$i+1]) unless $path[$i+1] == 0;
        } else {
            $element->set_name($path[$i+1]);
        }
    }

    my $self = {
        _ref => $ref,
    };
    bless $self, __PACKAGE__;
    return $self;
}

sub _from_pb {
    my ($pb) = @_;

    my $self = {
        _ref => $pb,
    };
    bless $self, __PACKAGE__;
    return $self;
}


sub app {
    return $_[0]->{_ref}->app;
}

sub _last_element {
    my $i = $_[0]->{_ref}->path->element_size - 1;
    return $_[0]->{_ref}->path->elements->[$i];
}

sub kind {
    return $_[0]->_last_element->type;
}

sub name {
    my $e = $_[0]->_last_element;
    return $e->name if $e->has_name;
    return;
}

sub id {
    my $e = $_[0]->_last_element;
    return $e->id if $e->has_id;
    return;
}

sub id_or_name {
    return $_[0]->id || $_[0]->name;
}

sub has_id_or_name {
    return $_[0]->_last_element->has_id || $_[0]->_last_element->has_name;
}

sub path {
    my $self = shift;

    my @ret;
    foreach my $element (@{$self->{_ref}->path->elements}) {
        if ($element->has_id) {
            push @ret, $element->type, $element->id;
        } elsif ($element->has_name) {
            push @ret, $element->type, $element->name;
        } else {
            push @ret, $element->type, 0;
        }
    }

    return @ret;
}

sub parent {
    my $self = shift;
    my @path = $self->path;

    return if @path == 2; # No parent
    pop @path;
    pop @path;

    return AppEngine::API::Datastore::Key::from_path(\@path);
}

sub entity_group {
    my $self = shift;
    my @path = $self->path;

    return AppEngine::API::Datastore::Key::from_path([@path[0, 1]]);
}

sub str {
    my $self = shift;

    return urlsafe_b64encode($self->{_ref}->serialize_to_string);
}

sub _to_pb {
    my ($self, $pb) = @_;

    $pb->set_app($self->app);
    $self->_path_to_pb($pb->path);
}

sub _path_to_pb {
    my ($self, $pb) = @_;

    foreach my $element (@{$self->{_ref}->path->elements}) {
        my $element_dest = $pb->add_element;
        $element_dest->set_type($element->type) if $element->has_type;
        $element_dest->set_id($element->id)     if $element->has_id;
        $element_dest->set_name($element->name) if $element->has_name;
    }
}

sub _to_reference_value_pb {
    my ($self, $pb) = @_;

    $pb->set_app($self->app);

    foreach my $element (@{$self->{_ref}->path->elements}) {
        my $element_dest = $pb->add_pathelement;
        $element_dest->set_type($element->type) if $element->has_type;
        $element_dest->set_id($element->id)     if $element->has_id;
        $element_dest->set_name($element->name) if $element->has_name;
    }
}

1;
