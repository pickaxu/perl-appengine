package AppEngine::API::Datastore::Key;

use strict;
use warnings;

use Carp;
use AppEngine::Service::Entity;

# TODO(davidsansome): parent parameter
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
            $element->set_id($path[$i+1]);
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
    return $_[0]->_last_element->name;
}

sub id {
    return $_[0]->_last_element->id;
}

sub id_or_name {
    return $_[0]->_last_element->id || $_[0]->_last_element->name;
}

sub has_id_or_name {
    return $_[0]->_last_element->has_id || $_[0]->_last_element->has_name;
}

sub path {
    my $self = shift;

    my @ret;
    foreach my $element (@{$self->{_ref}->path->elements}) {
        push @ret, $element->type, ($element->id || $element->name);
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

sub _to_pb {
    my ($self, $pb) = @_;

    $pb->set_app($self->app);
    foreach my $element (@{$self->{_ref}->path->elements}) {
        my $element_dest = $pb->path->add_element;
        $element_dest->set_type($element->type) if $element->has_type;
        $element_dest->set_id($element->id) if $element->has_id;
        $element_dest->set_name($element->name) if $element->has_name;
    }
}

1;
