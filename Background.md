# Background #

Currently, the low level plumbing that will allow a Perl program to access
the available services within the Google compute farm is being implemented.

## protobuf-perl ##

This is done by making calls to an API proxy and passing parameters
which have been serialized using an approach called "protocol buffers."
The "protobuf" tool uses a serialization specification (in a .proto file)
(i.e. like an Interface Definition Language or IDL) and produces
code for Google's main three languages: C++, Java, and Python.
Brad has done work on adding Perl support to the protocol buffers tool set.
This is generically useful (at least to all projects using protocol buffers such
as those within Google's compute farm) and therefore has been made a separate
project.

  * http://code.google.com/p/protobuf/
  * http://code.google.com/apis/protocolbuffers/docs/tutorials.html
  * http://code.google.com/apis/protocolbuffers/docs/reference/other.html
  * http://code.google.com/p/protobuf/wiki/OtherLanguages
  * http://groups.google.com/group/protobuf-perl
  * http://code.google.com/p/protobuf-perl/

## sys-protect ##

Also, the Sys::Protect module is an XS module which eliminates the use of
certain Perl opcodes. This is not how it will be when code
runs at Google, but it will help ensure that code that runs in the development
environment does not contain illegal actions which will not be allowed in the
production environment.

  * http://code.google.com/p/sys-protect/
  * http://search.cpan.org/~bradfitz/Sys-Protect/
  * http://search.cpan.org/~bradfitz/Sys-Protect/lib/Sys/Protect.pm

## Moose ##

The project also uses Moose, "a postmodern object system for Perl 5 that
takes the tedium out of writing object-oriented Perl. It borrows all the
best features from Perl 6, CLOS (LISP), Smalltalk, Java, BETA, OCaml, Ruby and more, while still keeping true to it's Perl 5 roots." It also uses Moose::Policy.

  * http://www.iinteractive.com/moose/
  * http://search.cpan.org/~stevan/Moose/
  * http://search.cpan.org/~stevan/Moose/lib/Moose.pm
  * http://search.cpan.org/~stevan/Moose-Policy/
  * http://search.cpan.org/~stevan/Moose-Policy/lib/Moose/Policy.pm