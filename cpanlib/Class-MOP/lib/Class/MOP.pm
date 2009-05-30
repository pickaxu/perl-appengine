
package Class::MOP;

use strict;
use warnings;

use MRO::Compat;

use Carp          'confess';
use Scalar::Util  'weaken';

use Class::MOP::Class;
use Class::MOP::Attribute;
use Class::MOP::Method;

use Class::MOP::Immutable;

BEGIN {
    
    our $VERSION   = '0.63';
    our $AUTHORITY = 'cpan:STEVAN';    
    
    *IS_RUNNING_ON_5_10 = ($] < 5.009_005) 
        ? sub () { 0 }
        : sub () { 1 };    

    # NOTE:
    # we may not use this yet, but once 
    # the get_code_info XS gets merged 
    # upstream to it, we will always use 
    # it. But for now it is just kinda 
    # extra overhead.
    # - SL
    my $_PP_get_code_info = eval { \&Sys::Protect::get_code_info };
    unless ($_PP_get_code_info) {
        eval {
            require Sub::Identify;
        };
        if ($@) {
            warn "Couldn't load Sub::Identify: $@\n";
        } else {
            $_PP_get_code_info = \&Sub::Identify::get_code_info;
        }
    }
        
    # stash these for a sec, and see how things go
    my $_PP_subname       = sub { $_[1] };
    
    if ($ENV{CLASS_MOP_NO_XS}) {
        # NOTE:
        # this is if you really want things
        # to be slow, then you can force the
        # no-XS rule this way, otherwise we 
        # make an effort to load as much of 
        # the XS as possible.
        # - SL
        no warnings 'prototype', 'redefine';
        
        unless (IS_RUNNING_ON_5_10()) {
            # get this from MRO::Compat ...
            *check_package_cache_flag = \&MRO::Compat::__get_pkg_gen_pp;
        }
        else {
            # NOTE:
            # but if we are running 5.10 
            # there is no need to use the 
            # Pure Perl version since we 
            # can use the built in mro 
            # version instead.
            # - SL
            *check_package_cache_flag = \&mro::get_pkg_gen; 
        }
        # our own version of Sub::Name
        *subname       = $_PP_subname;
        # and the Sub::Identify version of the get_code_info
        *get_code_info = $_PP_get_code_info;        
    }
    else {
        # now try our best to get as much 
        # of the XS loaded as possible
        {
            local $@;
            eval {
                require XSLoader;
                XSLoader::load( 'Class::MOP', $VERSION );            
            };
            die $@ if $@ && $@ !~ /object version|loadable object/;
            
            # okay, so the XS failed to load, so 
            # use the pure perl one instead.
            *get_code_info = $_PP_get_code_info if $@; 
        }        
        
        # get it from MRO::Compat
        *check_package_cache_flag = \&mro::get_pkg_gen;        
        
        # now try and load the Sub::Name 
        # module and use that as a means
        # for naming our CVs, if not, we 
        # use the workaround instead.
        if ( eval { require Sub::Name } ) {
            *subname = \&Sub::Name::subname;
        } 
        else {
            *subname = $_PP_subname;
        }     
    }
}

{
    # Metaclasses are singletons, so we cache them here.
    # there is no need to worry about destruction though
    # because they should die only when the program dies.
    # After all, do package definitions even get reaped?
    my %METAS;

    # means of accessing all the metaclasses that have
    # been initialized thus far (for mugwumps obj browser)
    sub get_all_metaclasses         {        %METAS         }
    sub get_all_metaclass_instances { values %METAS         }
    sub get_all_metaclass_names     { keys   %METAS         }
    sub get_metaclass_by_name       { $METAS{$_[0]}         }
    sub store_metaclass_by_name     { $METAS{$_[0]} = $_[1] }
    sub weaken_metaclass            { weaken($METAS{$_[0]}) }
    sub does_metaclass_exist        { exists $METAS{$_[0]} && defined $METAS{$_[0]} }
    sub remove_metaclass_by_name    { $METAS{$_[0]} = undef }

    # NOTE:
    # We only cache metaclasses, meaning instances of
    # Class::MOP::Class. We do not cache instance of
    # Class::MOP::Package or Class::MOP::Module. Mostly
    # because I don't yet see a good reason to do so.
}

sub load_class {
    my $class = shift;

    if (ref($class) || !defined($class) || !length($class)) {
        my $display = defined($class) ? $class : 'undef';
        confess "Invalid class name ($display)";
    }

    # if the class is not already loaded in the symbol table..
    unless (is_class_loaded($class)) {
        # require it
        my $file = $class . '.pm';
        $file =~ s{::}{/}g;
        eval { CORE::require($file) };
        confess "Could not load class ($class) because : $@" if $@;
    }

    # initialize a metaclass if necessary
    unless (does_metaclass_exist($class)) {
        eval { Class::MOP::Class->initialize($class) };
        confess "Could not initialize class ($class) because : $@" if $@;
    }

    return get_metaclass_by_name($class);
}

sub is_class_loaded {
    my $class = shift;

    return 0 if ref($class) || !defined($class) || !length($class);

    # walk the symbol table tree to avoid autovififying
    # \*{${main::}{"Foo::"}} == \*main::Foo::

    my $pack = \*::;
    foreach my $part (split('::', $class)) {
        return 0 unless exists ${$$pack}{"${part}::"};
        $pack = \*{${$$pack}{"${part}::"}};
    }

    # check for $VERSION or @ISA
    return 1 if exists ${$$pack}{VERSION}
             && defined *{${$$pack}{VERSION}}{SCALAR};
    return 1 if exists ${$$pack}{ISA}
             && defined *{${$$pack}{ISA}}{ARRAY};

    # check for any method
    foreach ( keys %{$$pack} ) {
        next if substr($_, -2, 2) eq '::';

        my $glob = ${$$pack}{$_} || next;

        # constant subs
        if ( IS_RUNNING_ON_5_10 ) {
            return 1 if ref $glob eq 'SCALAR';
        }

        return 1 if defined *{$glob}{CODE};
    }

    # fail
    return 0;
}


## ----------------------------------------------------------------------------
## Setting up our environment ...
## ----------------------------------------------------------------------------
## Class::MOP needs to have a few things in the global perl environment so
## that it can operate effectively. Those things are done here.
## ----------------------------------------------------------------------------

# ... nothing yet actually ;)

## ----------------------------------------------------------------------------
## Bootstrapping
## ----------------------------------------------------------------------------
## The code below here is to bootstrap our MOP with itself. This is also
## sometimes called "tying the knot". By doing this, we make it much easier
## to extend the MOP through subclassing and such since now you can use the
## MOP itself to extend itself.
##
## Yes, I know, thats weird and insane, but it's a good thing, trust me :)
## ----------------------------------------------------------------------------

# We need to add in the meta-attributes here so that
# any subclass of Class::MOP::* will be able to
# inherit them using &construct_instance

## --------------------------------------------------------
## Class::MOP::Package

Class::MOP::Package->meta->add_attribute(
    Class::MOP::Attribute->new('$!package' => (
        reader   => {
            # NOTE: we need to do this in order
            # for the instance meta-object to
            # not fall into meta-circular death
            #
            # we just alias the original method
            # rather than re-produce it here
            'name' => \&Class::MOP::Package::name
        },
        init_arg => 'package',
    ))
);

Class::MOP::Package->meta->add_attribute(
    Class::MOP::Attribute->new('%!namespace' => (
        reader => {
            # NOTE:
            # we just alias the original method
            # rather than re-produce it here
            'namespace' => \&Class::MOP::Package::namespace
        },
        init_arg => undef,
        default  => sub { \undef }
    ))
);

# NOTE:
# use the metaclass to construct the meta-package
# which is a superclass of the metaclass itself :P
Class::MOP::Package->meta->add_method('initialize' => sub {
    my $class        = shift;
    my $package_name = shift;
    $class->meta->new_object('package' => $package_name, @_);
});

## --------------------------------------------------------
## Class::MOP::Module

# NOTE:
# yeah this is kind of stretching things a bit,
# but truthfully the version should be an attribute
# of the Module, the weirdness comes from having to
# stick to Perl 5 convention and store it in the
# $VERSION package variable. Basically if you just
# squint at it, it will look how you want it to look.
# Either as a package variable, or as a attribute of
# the metaclass, isn't abstraction great :)

Class::MOP::Module->meta->add_attribute(
    Class::MOP::Attribute->new('$!version' => (
        reader => {
            # NOTE:
            # we just alias the original method
            # rather than re-produce it here
            'version' => \&Class::MOP::Module::version
        },
        init_arg => undef,
        default  => sub { \undef }
    ))
);

# NOTE:
# By following the same conventions as version here,
# we are opening up the possibility that people can
# use the $AUTHORITY in non-Class::MOP modules as
# well.

Class::MOP::Module->meta->add_attribute(
    Class::MOP::Attribute->new('$!authority' => (
        reader => {
            # NOTE:
            # we just alias the original method
            # rather than re-produce it here
            'authority' => \&Class::MOP::Module::authority
        },
        init_arg => undef,
        default  => sub { \undef }
    ))
);

## --------------------------------------------------------
## Class::MOP::Class

Class::MOP::Class->meta->add_attribute(
    Class::MOP::Attribute->new('%!attributes' => (
        reader   => {
            # NOTE: we need to do this in order
            # for the instance meta-object to
            # not fall into meta-circular death
            #
            # we just alias the original method
            # rather than re-produce it here
            'get_attribute_map' => \&Class::MOP::Class::get_attribute_map
        },
        init_arg => 'attributes',
        default  => sub { {} }
    ))
);

Class::MOP::Class->meta->add_attribute(
    Class::MOP::Attribute->new('%!methods' => (
        init_arg => 'methods',
        reader   => {
            # NOTE:
            # we just alias the original method
            # rather than re-produce it here
            'get_method_map' => \&Class::MOP::Class::get_method_map
        },
        default => sub { {} }
    ))
);

Class::MOP::Class->meta->add_attribute(
    Class::MOP::Attribute->new('@!superclasses' => (
        accessor => {
            # NOTE:
            # we just alias the original method
            # rather than re-produce it here
            'superclasses' => \&Class::MOP::Class::superclasses
        },
        init_arg => undef,
        default  => sub { \undef }
    ))
);

Class::MOP::Class->meta->add_attribute(
    Class::MOP::Attribute->new('$!attribute_metaclass' => (
        reader   => {
            # NOTE:
            # we just alias the original method
            # rather than re-produce it here
            'attribute_metaclass' => \&Class::MOP::Class::attribute_metaclass
        },
        init_arg => 'attribute_metaclass',
        default  => 'Class::MOP::Attribute',
    ))
);

Class::MOP::Class->meta->add_attribute(
    Class::MOP::Attribute->new('$!method_metaclass' => (
        reader   => {
            # NOTE:
            # we just alias the original method
            # rather than re-produce it here
            'method_metaclass' => \&Class::MOP::Class::method_metaclass
        },
        init_arg => 'method_metaclass',
        default  => 'Class::MOP::Method',
    ))
);

Class::MOP::Class->meta->add_attribute(
    Class::MOP::Attribute->new('$!instance_metaclass' => (
        reader   => {
            # NOTE: we need to do this in order
            # for the instance meta-object to
            # not fall into meta-circular death
            #
            # we just alias the original method
            # rather than re-produce it here
            'instance_metaclass' => \&Class::MOP::Class::instance_metaclass
        },
        init_arg => 'instance_metaclass',
        default  => 'Class::MOP::Instance',
    ))
);

# NOTE:
# we don't actually need to tie the knot with
# Class::MOP::Class here, it is actually handled
# within Class::MOP::Class itself in the
# construct_class_instance method.

## --------------------------------------------------------
## Class::MOP::Attribute

Class::MOP::Attribute->meta->add_attribute(
    Class::MOP::Attribute->new('$!name' => (
        init_arg => 'name',
        reader   => {
            # NOTE: we need to do this in order
            # for the instance meta-object to
            # not fall into meta-circular death
            #
            # we just alias the original method
            # rather than re-produce it here
            'name' => \&Class::MOP::Attribute::name
        }
    ))
);

Class::MOP::Attribute->meta->add_attribute(
    Class::MOP::Attribute->new('$!associated_class' => (
        init_arg => 'associated_class',
        reader   => {
            # NOTE: we need to do this in order
            # for the instance meta-object to
            # not fall into meta-circular death
            #
            # we just alias the original method
            # rather than re-produce it here
            'associated_class' => \&Class::MOP::Attribute::associated_class
        }
    ))
);

Class::MOP::Attribute->meta->add_attribute(
    Class::MOP::Attribute->new('$!accessor' => (
        init_arg  => 'accessor',
        reader    => { 'accessor'     => \&Class::MOP::Attribute::accessor     },
        predicate => { 'has_accessor' => \&Class::MOP::Attribute::has_accessor },
    ))
);

Class::MOP::Attribute->meta->add_attribute(
    Class::MOP::Attribute->new('$!reader' => (
        init_arg  => 'reader',
        reader    => { 'reader'     => \&Class::MOP::Attribute::reader     },
        predicate => { 'has_reader' => \&Class::MOP::Attribute::has_reader },
    ))
);

Class::MOP::Attribute->meta->add_attribute(
    Class::MOP::Attribute->new('$!initializer' => (
        init_arg  => 'initializer',
        reader    => { 'initializer'     => \&Class::MOP::Attribute::initializer     },
        predicate => { 'has_initializer' => \&Class::MOP::Attribute::has_initializer },
    ))
);

Class::MOP::Attribute->meta->add_attribute(
    Class::MOP::Attribute->new('$!writer' => (
        init_arg  => 'writer',
        reader    => { 'writer'     => \&Class::MOP::Attribute::writer     },
        predicate => { 'has_writer' => \&Class::MOP::Attribute::has_writer },
    ))
);

Class::MOP::Attribute->meta->add_attribute(
    Class::MOP::Attribute->new('$!predicate' => (
        init_arg  => 'predicate',
        reader    => { 'predicate'     => \&Class::MOP::Attribute::predicate     },
        predicate => { 'has_predicate' => \&Class::MOP::Attribute::has_predicate },
    ))
);

Class::MOP::Attribute->meta->add_attribute(
    Class::MOP::Attribute->new('$!clearer' => (
        init_arg  => 'clearer',
        reader    => { 'clearer'     => \&Class::MOP::Attribute::clearer     },
        predicate => { 'has_clearer' => \&Class::MOP::Attribute::has_clearer },
    ))
);

Class::MOP::Attribute->meta->add_attribute(
    Class::MOP::Attribute->new('$!builder' => (
        init_arg  => 'builder',
        reader    => { 'builder'     => \&Class::MOP::Attribute::builder     },
        predicate => { 'has_builder' => \&Class::MOP::Attribute::has_builder },
    ))
);

Class::MOP::Attribute->meta->add_attribute(
    Class::MOP::Attribute->new('$!init_arg' => (
        init_arg  => 'init_arg',
        reader    => { 'init_arg'     => \&Class::MOP::Attribute::init_arg     },
        predicate => { 'has_init_arg' => \&Class::MOP::Attribute::has_init_arg },
    ))
);

Class::MOP::Attribute->meta->add_attribute(
    Class::MOP::Attribute->new('$!default' => (
        init_arg  => 'default',
        # default has a custom 'reader' method ...
        predicate => { 'has_default' => \&Class::MOP::Attribute::has_default },
    ))
);

Class::MOP::Attribute->meta->add_attribute(
    Class::MOP::Attribute->new('@!associated_methods' => (
        init_arg => 'associated_methods',
        reader   => { 'associated_methods' => \&Class::MOP::Attribute::associated_methods },
        default  => sub { [] }
    ))
);

# NOTE: (meta-circularity)
# This should be one of the last things done
# it will "tie the knot" with Class::MOP::Attribute
# so that it uses the attributes meta-objects
# to construct itself.
Class::MOP::Attribute->meta->add_method('new' => sub {
    my $class   = shift;
    my $name    = shift;
    my %options = @_;

    (defined $name && $name)
        || confess "You must provide a name for the attribute";
    $options{init_arg} = $name
        if not exists $options{init_arg};

    if(exists $options{builder}){
        confess("builder must be a defined scalar value which is a method name")
            if ref $options{builder} || !(defined $options{builder});
        confess("Setting both default and builder is not allowed.")
            if exists $options{default};
    } else {
        (Class::MOP::Attribute::is_default_a_coderef(\%options))
            || confess("References are not allowed as default values, you must ".
                       "wrap the default of '$name' in a CODE reference (ex: sub { [] } and not [])")
                if exists $options{default} && ref $options{default};
    }
    # return the new object
    $class->meta->new_object(name => $name, %options);
});

Class::MOP::Attribute->meta->add_method('clone' => sub {
    my $self  = shift;
    $self->meta->clone_object($self, @_);
});

## --------------------------------------------------------
## Class::MOP::Method

Class::MOP::Method->meta->add_attribute(
    Class::MOP::Attribute->new('&!body' => (
        init_arg => 'body',
        reader   => { 'body' => \&Class::MOP::Method::body },
    ))
);

Class::MOP::Method->meta->add_attribute(
    Class::MOP::Attribute->new('$!package_name' => (
        init_arg => 'package_name',
        reader   => { 'package_name' => \&Class::MOP::Method::package_name },
    ))
);

Class::MOP::Method->meta->add_attribute(
    Class::MOP::Attribute->new('$!name' => (
        init_arg => 'name',
        reader   => { 'name' => \&Class::MOP::Method::name },
    ))
);

Class::MOP::Method->meta->add_method('wrap' => sub {
    my $class   = shift;
    my $code    = shift;
    my %options = @_;

    ('CODE' eq ref($code))
        || confess "You must supply a CODE reference to bless, not (" . ($code || 'undef') . ")";

    ($options{package_name} && $options{name})
        || confess "You must supply the package_name and name parameters";

    # return the new object
    $class->meta->new_object(body => $code, %options);
});

Class::MOP::Method->meta->add_method('clone' => sub {
    my $self  = shift;
    $self->meta->clone_object($self, @_);
});

## --------------------------------------------------------
## Class::MOP::Method::Wrapped

# NOTE:
# the way this item is initialized, this
# really does not follow the standard
# practices of attributes, but we put
# it here for completeness
Class::MOP::Method::Wrapped->meta->add_attribute(
    Class::MOP::Attribute->new('%!modifier_table')
);

## --------------------------------------------------------
## Class::MOP::Method::Generated

Class::MOP::Method::Generated->meta->add_attribute(
    Class::MOP::Attribute->new('$!is_inline' => (
        init_arg => 'is_inline',
        reader   => { 'is_inline' => \&Class::MOP::Method::Generated::is_inline },
        default  => 0, 
    ))
);

Class::MOP::Method::Generated->meta->add_method('new' => sub {
    my ($class, %options) = @_;
    ($options{package_name} && $options{name})
        || confess "You must supply the package_name and name parameters";    
    my $self = $class->meta->new_object(%options);
    $self->initialize_body;  
    $self;
});

## --------------------------------------------------------
## Class::MOP::Method::Accessor

Class::MOP::Method::Accessor->meta->add_attribute(
    Class::MOP::Attribute->new('$!attribute' => (
        init_arg => 'attribute',
        reader   => {
            'associated_attribute' => \&Class::MOP::Method::Accessor::associated_attribute
        },
    ))
);

Class::MOP::Method::Accessor->meta->add_attribute(
    Class::MOP::Attribute->new('$!accessor_type' => (
        init_arg => 'accessor_type',
        reader   => { 'accessor_type' => \&Class::MOP::Method::Accessor::accessor_type },
    ))
);

Class::MOP::Method::Accessor->meta->add_method('new' => sub {
    my $class   = shift;
    my %options = @_;

    (exists $options{attribute})
        || confess "You must supply an attribute to construct with";

    (exists $options{accessor_type})
        || confess "You must supply an accessor_type to construct with";

    (Scalar::Util::blessed($options{attribute}) && $options{attribute}->isa('Class::MOP::Attribute'))
        || confess "You must supply an attribute which is a 'Class::MOP::Attribute' instance";

    ($options{package_name} && $options{name})
        || confess "You must supply the package_name and name parameters";

    # return the new object
    my $self = $class->meta->new_object(%options);
    
    # we don't want this creating
    # a cycle in the code, if not
    # needed
    Scalar::Util::weaken($self->{'$!attribute'});

    $self->initialize_body;  
    
    $self;
});


## --------------------------------------------------------
## Class::MOP::Method::Constructor

Class::MOP::Method::Constructor->meta->add_attribute(
    Class::MOP::Attribute->new('%!options' => (
        init_arg => 'options',
        reader   => {
            'options' => \&Class::MOP::Method::Constructor::options
        },
        default  => sub { +{} }
    ))
);

Class::MOP::Method::Constructor->meta->add_attribute(
    Class::MOP::Attribute->new('$!associated_metaclass' => (
        init_arg => 'metaclass',
        reader   => {
            'associated_metaclass' => \&Class::MOP::Method::Constructor::associated_metaclass
        },
    ))
);

Class::MOP::Method::Constructor->meta->add_method('new' => sub {
    my $class   = shift;
    my %options = @_;

    (Scalar::Util::blessed $options{metaclass} && $options{metaclass}->isa('Class::MOP::Class'))
        || confess "You must pass a metaclass instance if you want to inline"
            if $options{is_inline};

    ($options{package_name} && $options{name})
        || confess "You must supply the package_name and name parameters";

    # return the new object
    my $self = $class->meta->new_object(%options);
    
    # we don't want this creating
    # a cycle in the code, if not
    # needed
    Scalar::Util::weaken($self->{'$!associated_metaclass'});

    $self->initialize_body;  
    
    $self;
});

## --------------------------------------------------------
## Class::MOP::Instance

# NOTE:
# these don't yet do much of anything, but are just
# included for completeness

Class::MOP::Instance->meta->add_attribute(
    Class::MOP::Attribute->new('$!meta')
);

Class::MOP::Instance->meta->add_attribute(
    Class::MOP::Attribute->new('@!slots')
);

## --------------------------------------------------------
## Now close all the Class::MOP::* classes

# NOTE:
# we don't need to inline the
# constructors or the accessors
# this only lengthens the compile
# time of the MOP, and gives us
# no actual benefits.

$_->meta->make_immutable(
    inline_constructor => 0,
    inline_accessors   => 0,
) for qw/
    Class::MOP::Package
    Class::MOP::Module
    Class::MOP::Class

    Class::MOP::Attribute
    Class::MOP::Method
    Class::MOP::Instance

    Class::MOP::Object

    Class::MOP::Method::Generated

    Class::MOP::Method::Accessor
    Class::MOP::Method::Constructor
    Class::MOP::Method::Wrapped
/;

1;

__END__

=pod

=head1 NAME

Class::MOP - A Meta Object Protocol for Perl 5

=head1 DESCRIPTON

This module is a fully functioning meta object protocol for the
Perl 5 object system. It makes no attempt to change the behavior or
characteristics of the Perl 5 object system, only to create a
protocol for its manipulation and introspection.

That said, it does attempt to create the tools for building a rich
set of extensions to the Perl 5 object system. Every attempt has been
made for these tools to keep to the spirit of the Perl 5 object
system that we all know and love.

This documentation is admittedly sparse on details, as time permits
I will try to improve them. For now, I suggest looking at the items
listed in the L<SEE ALSO> section for more information. In particular
the book "The Art of the Meta Object Protocol" was very influential
in the development of this system.

=head2 What is a Meta Object Protocol?

A meta object protocol is an API to an object system.

To be more specific, it is a set of abstractions of the components of
an object system (typically things like; classes, object, methods,
object attributes, etc.). These abstractions can then be used to both
inspect and manipulate the object system which they describe.

It can be said that there are two MOPs for any object system; the
implicit MOP, and the explicit MOP. The implicit MOP handles things
like method dispatch or inheritance, which happen automatically as
part of how the object system works. The explicit MOP typically
handles the introspection/reflection features of the object system.
All object systems have implicit MOPs, without one, they would not
work. Explict MOPs however as less common, and depending on the
language can vary from restrictive (Reflection in Java or C#) to
wide open (CLOS is a perfect example).

=head2 Yet Another Class Builder!! Why?

This is B<not> a class builder so much as it is a I<class builder
B<builder>>. My intent is that an end user does not use this module
directly, but instead this module is used by module authors to
build extensions and features onto the Perl 5 object system.

=head2 Who is this module for?

This module is specifically for anyone who has ever created or
wanted to create a module for the Class:: namespace. The tools which
this module will provide will hopefully make it easier to do more
complex things with Perl 5 classes by removing such barriers as
the need to hack the symbol tables, or understand the fine details
of method dispatch.

=head2 What changes do I have to make to use this module?

This module was designed to be as unintrusive as possible. Many of
its features are accessible without B<any> change to your existsing
code at all. It is meant to be a compliment to your existing code and
not an intrusion on your code base. Unlike many other B<Class::>
modules, this module B<does not> require you subclass it, or even that
you C<use> it in within your module's package.

The only features which requires additions to your code are the
attribute handling and instance construction features, and these are
both completely optional features. The only reason for this is because
Perl 5's object system does not actually have these features built
in. More information about this feature can be found below.

=head2 A Note about Performance?

It is a common misconception that explict MOPs are performance drains.
But this is not a universal truth at all, it is an side-effect of
specific implementations. For instance, using Java reflection is much
slower because the JVM cannot take advantage of any compiler
optimizations, and the JVM has to deal with much more runtime type
information as well. Reflection in C# is marginally better as it was
designed into the language and runtime (the CLR). In contrast, CLOS
(the Common Lisp Object System) was built to support an explicit MOP,
and so performance is tuned for it.

This library in particular does it's absolute best to avoid putting
B<any> drain at all upon your code's performance. In fact, by itself
it does nothing to affect your existing code. So you only pay for
what you actually use.

=head2 About Metaclass compatibility

This module makes sure that all metaclasses created are both upwards
and downwards compatible. The topic of metaclass compatibility is
highly esoteric and is something only encountered when doing deep and
involved metaclass hacking. There are two basic kinds of metaclass
incompatibility; upwards and downwards.

Upwards metaclass compatibility means that the metaclass of a
given class is either the same as (or a subclass of) all of the
class's ancestors.

Downward metaclass compatibility means that the metaclasses of a
given class's anscestors are all either the same as (or a subclass
of) that metaclass.

Here is a diagram showing a set of two classes (C<A> and C<B>) and
two metaclasses (C<Meta::A> and C<Meta::B>) which have correct
metaclass compatibility both upwards and downwards.

    +---------+     +---------+
    | Meta::A |<----| Meta::B |      <....... (instance of  )
    +---------+     +---------+      <------- (inherits from)
         ^               ^
         :               :
    +---------+     +---------+
    |    A    |<----|    B    |
    +---------+     +---------+

As I said this is a highly esoteric topic and one you will only run
into if you do a lot of subclassing of B<Class::MOP::Class>. If you
are interested in why this is an issue see the paper
I<Uniform and safe metaclass composition> linked to in the
L<SEE ALSO> section of this document.

=head2 Using custom metaclasses

Always use the metaclass pragma when using a custom metaclass, this
will ensure the proper initialization order and not accidentely
create an incorrect type of metaclass for you. This is a very rare
problem, and one which can only occur if you are doing deep metaclass
programming. So in other words, don't worry about it.

=head1 PROTOCOLS

The protocol is divided into 4 main sub-protocols:

=over 4

=item The Class protocol

This provides a means of manipulating and introspecting a Perl 5
class. It handles all of symbol table hacking for you, and provides
a rich set of methods that go beyond simple package introspection.

See L<Class::MOP::Class> for more details.

=item The Attribute protocol

This provides a consistent represenation for an attribute of a
Perl 5 class. Since there are so many ways to create and handle
attributes in Perl 5 OO, this attempts to provide as much of a
unified approach as possible, while giving the freedom and
flexibility to subclass for specialization.

See L<Class::MOP::Attribute> for more details.

=item The Method protocol

This provides a means of manipulating and introspecting methods in
the Perl 5 object system. As with attributes, there are many ways to
approach this topic, so we try to keep it pretty basic, while still
making it possible to extend the system in many ways.

See L<Class::MOP::Method> for more details.

=item The Instance protocol

This provides a layer of abstraction for creating object instances. 
Since the other layers use this protocol, it is relatively easy to 
change the type of your instances from the default HASH ref to other
types of references. Several examples are provided in the F<examples/> 
directory included in this distribution.

See L<Class::MOP::Instance> for more details.

=back

=head1 FUNCTIONS

=head2 Constants

=over 4

=item I<IS_RUNNING_ON_5_10>

We set this constant depending on what version perl we are on, this 
allows us to take advantage of new 5.10 features and stay backwards 
compat.

=back

=head2 Utility functions

=over 4

=item B<load_class ($class_name)>

This will load a given C<$class_name> and if it does not have an
already initialized metaclass, then it will intialize one for it.
This function can be used in place of tricks like 
C<eval "use $module"> or using C<require>.

=item B<is_class_loaded ($class_name)>

This will return a boolean depending on if the C<$class_name> has
been loaded.

NOTE: This does a basic check of the symbol table to try and
determine as best it can if the C<$class_name> is loaded, it
is probably correct about 99% of the time.

=item B<check_package_cache_flag ($pkg)>

This will return an integer that is managed by C<Class::MOP::Class>
to determine if a module's symbol table has been altered. 

In Perl 5.10 or greater, this flag is package specific. However in 
versions prior to 5.10, this will use the C<PL_sub_generation> variable
which is not package specific. 

=item B<get_code_info ($code)>

This function returns two values, the name of the package the C<$code> 
is from and the name of the C<$code> itself. This is used by several 
elements of the MOP to detemine where a given C<$code> reference is from.

=item B<subname ($name, $code)>

B<NOTE: DO NOT USE THIS FUNCTION, IT IS FOR INTERNAL USE ONLY!>

If possible, we will load the L<Sub::Name> module and this will function 
as C<Sub::Name::subname> does, otherwise it will just return the C<$code>
argument.

=back

=head2 Metaclass cache functions

Class::MOP holds a cache of metaclasses, the following are functions
(B<not methods>) which can be used to access that cache. It is not
recommended that you mess with this, bad things could happen. But if
you are brave and willing to risk it, go for it.

=over 4

=item B<get_all_metaclasses>

This will return an hash of all the metaclass instances that have
been cached by B<Class::MOP::Class> keyed by the package name.

=item B<get_all_metaclass_instances>

This will return an array of all the metaclass instances that have
been cached by B<Class::MOP::Class>.

=item B<get_all_metaclass_names>

This will return an array of all the metaclass names that have
been cached by B<Class::MOP::Class>.

=item B<get_metaclass_by_name ($name)>

This will return a cached B<Class::MOP::Class> instance of nothing
if no metaclass exist by that C<$name>.

=item B<store_metaclass_by_name ($name, $meta)>

This will store a metaclass in the cache at the supplied C<$key>.

=item B<weaken_metaclass ($name)>

In rare cases it is desireable to store a weakened reference in 
the metaclass cache. This function will weaken the reference to 
the metaclass stored in C<$name>.

=item B<does_metaclass_exist ($name)>

This will return true of there exists a metaclass stored in the 
C<$name> key and return false otherwise.

=item B<remove_metaclass_by_name ($name)>

This will remove a the metaclass stored in the C<$name> key.

=back

=head1 SEE ALSO

=head2 Books

There are very few books out on Meta Object Protocols and Metaclasses
because it is such an esoteric topic. The following books are really
the only ones I have found. If you know of any more, B<I<please>>
email me and let me know, I would love to hear about them.

=over 4

=item "The Art of the Meta Object Protocol"

=item "Advances in Object-Oriented Metalevel Architecture and Reflection"

=item "Putting MetaClasses to Work"

=item "Smalltalk: The Language"

=back

=head2 Papers

=over 4

=item Uniform and safe metaclass composition

An excellent paper by the people who brought us the original Traits paper.
This paper is on how Traits can be used to do safe metaclass composition,
and offers an excellent introduction section which delves into the topic of
metaclass compatibility.

L<http://www.iam.unibe.ch/~scg/Archive/Papers/Duca05ySafeMetaclassTrait.pdf>

=item Safe Metaclass Programming

This paper seems to precede the above paper, and propose a mix-in based
approach as opposed to the Traits based approach. Both papers have similar
information on the metaclass compatibility problem space.

L<http://citeseer.ist.psu.edu/37617.html>

=back

=head2 Prior Art

=over 4

=item The Perl 6 MetaModel work in the Pugs project

=over 4

=item L<http://svn.openfoundry.org/pugs/perl5/Perl6-MetaModel>

=item L<http://svn.openfoundry.org/pugs/perl5/Perl6-ObjectSpace>

=back

=back

=head2 Articles

=over 4

=item CPAN Module Review of Class::MOP

L<http://www.oreillynet.com/onlamp/blog/2006/06/cpan_module_review_classmop.html>

=back

=head1 SIMILAR MODULES

As I have said above, this module is a class-builder-builder, so it is
not the same thing as modules like L<Class::Accessor> and
L<Class::MethodMaker>. That being said there are very few modules on CPAN
with similar goals to this module. The one I have found which is most
like this module is L<Class::Meta>, although it's philosophy and the MOP it
creates are very different from this modules.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 ACKNOWLEDGEMENTS

=over 4

=item Rob Kinyon

Thanks to Rob for actually getting the development of this module kick-started.

=back

=head1 AUTHORS

Stevan Little E<lt>stevan@iinteractive.comE<gt>

B<with contributions from:>

Brandon (blblack) Black

Guillermo (groditi) Roditi

Matt (mst) Trout

Rob (robkinyon) Kinyon

Yuval (nothingmuch) Kogman

Scott (konobi) McWhirter

=head1 COPYRIGHT AND LICENSE

Copyright 2006-2008 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut