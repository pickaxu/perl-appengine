package AppEngine::API::Datastore::Key;

use strict;
use warnings;

=head1 NAME

AppEngine::API::Datastore::Key - Perl version of google.appengine.ext.db.Key

=head1 SYNOPSIS

    use AppEngine::API::Datastore::Key qw(key_from_path);
    
    my $key = AppEngine::API::Datastore::Key->new($encoded_str);
    my $key = key_from_path(['User', 'Boris', 'Address', 9876]);
    
    print $key->app;
    print $key->kind;
    print $key->id_or_name;
    
    print $key->str;

=head1 DESCRIPTION

An instance of the Key class represents a unique key for a datastore entity.

=head2 Exports

The following functions can be exported by request:

    key_from_path

=head1 METHODS

=over

=cut

use AppEngine::Service::Entity;
use Carp;
use MIME::Base64::URLSafe;

use base qw(Exporter);
our @EXPORT_OK = qw(key_from_path);

=item new ( encoded_string )

Creates a Key object from its encoded string representation.

A key can be encoded to a string by calling its key() method.
A string-encoded key is an opaque value using characters safe for including in
URLs.
The string-encoded key can be converted back to a Key object by passing it to
the Key constructor (the C<encoded_string> argument).

B<Note:> A string-encoded key can be converted back to the raw key data.
This makes it easy to guess other keys when one is known.
While string-encoded key values are safe to include in URLs, an application
should only do so if key guessability is not an issue.

C<encoded> is the str form of a Key instance to convert back into a Key.

=cut

sub new {
    my ($pkg, $encoded) = @_;

    my $pb = AppEngine::Service::Entity::Reference->new;
    $pb->merge_from_string(urlsafe_b64decode($encoded));

    return _from_pb($pb);
}

=item from_path ( path [, parent => parent_key ] )

Builds a new Key object from an ancestor path of one or more entity keys.

A path represents the hierarchy of parent-child relationships for an entity. 
Each entity in the path is represented the entity's kind, and either its numeric
ID or its key name.
The full path represents the entity that appears last in the path, with its
ancestors (parents) as preceding entities.

For example, the following call creates a key for an entity of kind Address with
the numeric ID 9876 whose parent is an entity of kind User with the named key
'Boris':

    my $key = AppEngine::API::Datastore::Key::from_path(['User', 'Boris', 'Address', 9876])

C<path> is an arrayref containing the path from the root entity to the subject.
Each entity in the path is represented by two elements in the list: the name of
the kind, and the key name or ID of the entity of that kind.

C<parent_key> can be used to specify a parent entity to prepend to the given
path.

=cut

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

=item key_from_path ( path [, parent => parent_key ] )

Alias for from_path() that can be exported into the caller's namespace.

    use AppEngine::API::Datastore::Key qw(key_from_path);
    my $key = key_from_path(['User', 'Boris', 'Address', 9876])

=cut

*key_from_path = \&from_path;

=item app

Returns the name of the application that stored the data entity.

=cut

sub app {
    return $_[0]->{_ref}->app;
}

=item kind

Returns the kind of the data entity, as a string.

=cut

sub kind {
    return $_[0]->_last_element->type;
}

=item name

Returns the name of the data entity, or undef if the entity does not have a
name.

=cut

sub name {
    my $e = $_[0]->_last_element;
    return $e->name if $e->has_name;
    return;
}

=item id

Returns the numeric ID of the data entity, as an integer, or undef if the
entity does not have a numeric ID.

=cut

sub id {
    my $e = $_[0]->_last_element;
    return $e->id if $e->has_id;
    return;
}

=item id_or_name

Returns the name or numeric ID of the data entity, whichever it has, or undef
if the entity has neither a name nor a numeric ID.

=cut

sub id_or_name {
    return $_[0]->id || $_[0]->name;
}

=item has_id_or_name

Returns true if the entity has either a name or a numeric ID.

=cut

sub has_id_or_name {
    return $_[0]->_last_element->has_id || $_[0]->_last_element->has_name;
}

=item path

Returns the complete path for this entity as an array.
Suitable for passing to key_from_path().

    my $key2 = key_from_path( [ $key1->path ] );

=cut

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

=item parent

Returns the Key of the data entity's parent entity, or None if the entity has
no parent.

=cut

sub parent {
    my $self = shift;
    my @path = $self->path;

    return if @path == 2; # No parent
    pop @path;
    pop @path;

    return AppEngine::API::Datastore::Key::from_path(\@path);
}

=item str

Returns an encoded string representation of this Key.
Suitable for passing to new().

    my $key2 = AppEngine::API::Datastore::Key->new( $key1->str );

=cut

sub str {
    my $self = shift;

    return urlsafe_b64encode($self->{_ref}->serialize_to_string);
}

=item entity_group

Returns the key of the root entity that has this entity as a child

Two entities that share the same root ancestor are said to be in the same
C<entity group>.

=cut

sub entity_group {
    my $self = shift;
    my @path = $self->path;

    return AppEngine::API::Datastore::Key::from_path([@path[0, 1]]);
}


# Internal methods

sub _last_element {
    my $i = $_[0]->{_ref}->path->element_size - 1;
    return $_[0]->{_ref}->path->elements->[$i];
}

sub _from_pb {
    my ($pb) = @_;

    my $self = {
        _ref => $pb,
    };
    bless $self, __PACKAGE__;
    return $self;
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
