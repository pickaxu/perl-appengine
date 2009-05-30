## Boilerplate:
# Auto-generated code from the protocol buffer compiler.  DO NOT EDIT!

use strict;
use warnings;
use 5.6.1;
use Protobuf;
use Protobuf::Types;

package AppEngine::Service::User;


use constant TRUE => 1;
use constant FALSE => 0;
## Top-level enums:
## Top-level extensions:

## All nested enums:
our $_USERSERVICEERROR_ERRORCODE = Protobuf::EnumDescriptor->new(
  name => 'ErrorCode',
  full_name => 'AppEngine::Service::User::ErrorCode',
  values => [
    Protobuf::EnumValueDescriptor->new(name => 'OK', index => 0, number => 0, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'REDIRECT_URL_TOO_LONG', index => 1, number => 1, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'NOT_ALLOWED', index => 2, number => 2, type => undef),
]);
$_USERSERVICEERROR_ERRORCODE->values->[0]->set_type($_USERSERVICEERROR_ERRORCODE);
$_USERSERVICEERROR_ERRORCODE->values->[1]->set_type($_USERSERVICEERROR_ERRORCODE);
$_USERSERVICEERROR_ERRORCODE->values->[2]->set_type($_USERSERVICEERROR_ERRORCODE);

## Message descriptors:

our $_USERSERVICEERROR = Protobuf::Descriptor->new(
  name => 'UserServiceError',
  full_name => 'AppEngine::Service::User::UserServiceError',
  containing_type => undef,
  fields => [
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
    $_USERSERVICEERROR_ERRORCODE,
  ],
  options => Protobuf::MessageOptions->new(
  ),
);

## Imports:
eval "use AppEngine::Service::Base;";

## Fix foreign fields:

## Messages:
Protobuf::Message->GenerateClass(__PACKAGE__ . '::UserServiceError', $_USERSERVICEERROR);

## Fix foreign fields in extensions:
## Services:

1;
