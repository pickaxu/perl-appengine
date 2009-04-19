package AppEngine::API::Datastore::Key;

use strict;
use warnings;

use Carp;
use AppEngine::Service::Entity;

# TODO(davidsansome): parent parameter
sub from_path {
    my ($path) = @_;
    croak 'arrayref expected for path'     unless ref($path) eq 'ARRAY';
    croak 'path is empty'                  unless @$path;
    croak 'odd number of elements in path' unless (@$path % 2) == 0;

    my $ref = AppEngine::Service::Entity::Reference->new;
    $ref->set_app($ENV{APPLICATION_ID});

    my $p = $ref->path;

    for (my $i = 0 ; $i < @$path ; $i += 2) {
        my $element = $p->add_element;
        $element->set_type($path->[$i]);

        if ($path->[$i+1] =~ m/^\d/) {
            $element->set_id($path->[$i+1]);
        } else {
            $element->set_name($path->[$i+1]);
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

# TODO(davidsansome): parent()

1;
