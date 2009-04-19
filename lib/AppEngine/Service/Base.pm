## Boilerplate:
# Auto-generated code from the protocol buffer compiler.  DO NOT EDIT!

use strict;
use warnings;
use 5.6.1;
use Protobuf;
use Protobuf::Types;

package AppEngine::Service::Base;

package AppEngine::Service;


use constant TRUE => 1;
use constant FALSE => 0;
## Top-level enums:
## Top-level extensions:

## All nested enums:
## Message descriptors:

our $_STRINGPROTO = Protobuf::Descriptor->new(
  name => 'StringProto',
  full_name => 'AppEngine::Service::StringProto',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'value', index => 0, number => 1,
      type => 9, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
  ],
  options => Protobuf::MessageOptions->new(
  ),
);


our $_INTEGER32PROTO = Protobuf::Descriptor->new(
  name => 'Integer32Proto',
  full_name => 'AppEngine::Service::Integer32Proto',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'value', index => 0, number => 1,
      type => 5, cpp_type => 1, label => 2,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
  ],
  options => Protobuf::MessageOptions->new(
  ),
);


our $_INTEGER64PROTO = Protobuf::Descriptor->new(
  name => 'Integer64Proto',
  full_name => 'AppEngine::Service::Integer64Proto',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'value', index => 0, number => 1,
      type => 3, cpp_type => 2, label => 2,
      default_value => Protobuf::Types::BI("0"),
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
  ],
  options => Protobuf::MessageOptions->new(
  ),
);


our $_BOOLPROTO = Protobuf::Descriptor->new(
  name => 'BoolProto',
  full_name => 'AppEngine::Service::BoolProto',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'value', index => 0, number => 1,
      type => 8, cpp_type => 7, label => 2,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
  ],
  options => Protobuf::MessageOptions->new(
  ),
);


our $_DOUBLEPROTO = Protobuf::Descriptor->new(
  name => 'DoubleProto',
  full_name => 'AppEngine::Service::DoubleProto',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'value', index => 0, number => 1,
      type => 1, cpp_type => 5, label => 2,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
  ],
  options => Protobuf::MessageOptions->new(
  ),
);


our $_VOIDPROTO = Protobuf::Descriptor->new(
  name => 'VoidProto',
  full_name => 'AppEngine::Service::VoidProto',
  containing_type => undef,
  fields => [
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
  ],
  options => Protobuf::MessageOptions->new(
  ),
);

## Imports:

## Fix foreign fields:

## Messages:
Protobuf::Message->GenerateClass(__PACKAGE__ . '::StringProto', $_STRINGPROTO);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::Integer32Proto', $_INTEGER32PROTO);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::Integer64Proto', $_INTEGER64PROTO);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::BoolProto', $_BOOLPROTO);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::DoubleProto', $_DOUBLEPROTO);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::VoidProto', $_VOIDPROTO);

## Fix foreign fields in extensions:
## Services:

1;
