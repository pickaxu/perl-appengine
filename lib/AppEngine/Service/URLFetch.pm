## Boilerplate:
# Auto-generated code from the protocol buffer compiler.  DO NOT EDIT!

use strict;
use warnings;
use 5.6.1;
use Protobuf;
package AppEngine::Service::URLFetch;

package AppEngine::Service;


use constant TRUE => 1;
use constant FALSE => 0;
## Top-level enums:

## Top-level extensions:

## All nested enums:
our $_URLFETCHSERVICEERROR_ERRORCODE = Protobuf::EnumDescriptor->new(
  name => 'ErrorCode',
  full_name => 'appengine_api.URLFetchServiceError.ErrorCode',
  values => [
    Protobuf::EnumValueDescriptor->new(name => 'OK', index => 0, number => 0, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'INVALID_URL', index => 1, number => 1, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'FETCH_ERROR', index => 2, number => 2, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'UNSPECIFIED_ERROR', index => 3, number => 3, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'RESPONSE_TOO_LARGE', index => 4, number => 4, type => undef),
]);
$_URLFETCHSERVICEERROR_ERRORCODE->values->[0]->set_type($_URLFETCHSERVICEERROR_ERRORCODE);
$_URLFETCHSERVICEERROR_ERRORCODE->values->[1]->set_type($_URLFETCHSERVICEERROR_ERRORCODE);
$_URLFETCHSERVICEERROR_ERRORCODE->values->[2]->set_type($_URLFETCHSERVICEERROR_ERRORCODE);
$_URLFETCHSERVICEERROR_ERRORCODE->values->[3]->set_type($_URLFETCHSERVICEERROR_ERRORCODE);
$_URLFETCHSERVICEERROR_ERRORCODE->values->[4]->set_type($_URLFETCHSERVICEERROR_ERRORCODE);

our $_URLFETCHREQUEST_REQUESTMETHOD = Protobuf::EnumDescriptor->new(
  name => 'RequestMethod',
  full_name => 'appengine_api.URLFetchRequest.RequestMethod',
  values => [
    Protobuf::EnumValueDescriptor->new(name => 'GET', index => 0, number => 1, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'POST', index => 1, number => 2, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'HEAD', index => 2, number => 3, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'PUT', index => 3, number => 4, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'DELETE', index => 4, number => 5, type => undef),
]);
$_URLFETCHREQUEST_REQUESTMETHOD->values->[0]->set_type($_URLFETCHREQUEST_REQUESTMETHOD);
$_URLFETCHREQUEST_REQUESTMETHOD->values->[1]->set_type($_URLFETCHREQUEST_REQUESTMETHOD);
$_URLFETCHREQUEST_REQUESTMETHOD->values->[2]->set_type($_URLFETCHREQUEST_REQUESTMETHOD);
$_URLFETCHREQUEST_REQUESTMETHOD->values->[3]->set_type($_URLFETCHREQUEST_REQUESTMETHOD);
$_URLFETCHREQUEST_REQUESTMETHOD->values->[4]->set_type($_URLFETCHREQUEST_REQUESTMETHOD);

## Message descriptors:

our $_URLFETCHSERVICEERROR = Protobuf::Descriptor->new(
  name => 'URLFetchServiceError',
  full_name => 'appengine_api.URLFetchServiceError',
  containing_type => undef,
  fields => [
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
    $_URLFETCHSERVICEERROR_ERRORCODE,
  ],
  options => Protobuf::MessageOptions->new(
  ),
);


our $_URLFETCHREQUEST_HEADER = Protobuf::Descriptor->new(
  name => 'Header',
  full_name => 'appengine_api.URLFetchRequest.Header',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'Key', index => 0, number => 4,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'Value', index => 1, number => 5,
      type => 12, cpp_type => 9, label => 2,
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

our $_URLFETCHREQUEST = Protobuf::Descriptor->new(
  name => 'URLFetchRequest',
  full_name => 'appengine_api.URLFetchRequest',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'Method', index => 0, number => 1,
      type => 14, cpp_type => 8, label => 2,
      default_value => 1,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'Url', index => 1, number => 2,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'header', index => 2, number => 3,
      type => 10, cpp_type => 10, label => 3,
      default_value => [],
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'Payload', index => 3, number => 6,
      type => 12, cpp_type => 9, label => 1,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
    $_URLFETCHREQUEST_REQUESTMETHOD,
  ],
  options => Protobuf::MessageOptions->new(
  ),
);


our $_URLFETCHRESPONSE_HEADER = Protobuf::Descriptor->new(
  name => 'Header',
  full_name => 'appengine_api.URLFetchResponse.Header',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'Key', index => 0, number => 4,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'Value', index => 1, number => 5,
      type => 12, cpp_type => 9, label => 2,
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

our $_URLFETCHRESPONSE = Protobuf::Descriptor->new(
  name => 'URLFetchResponse',
  full_name => 'appengine_api.URLFetchResponse',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'Content', index => 0, number => 1,
      type => 12, cpp_type => 9, label => 1,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'StatusCode', index => 1, number => 2,
      type => 5, cpp_type => 1, label => 2,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'header', index => 2, number => 3,
      type => 10, cpp_type => 10, label => 3,
      default_value => [],
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'ContentWasTruncated', index => 3, number => 6,
      type => 8, cpp_type => 7, label => 1,
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

## Imports:

## Fix foreign fields:
$_URLFETCHREQUEST->fields_by_name('Method')->set_enum_type($_URLFETCHREQUEST_REQUESTMETHOD);
$_URLFETCHREQUEST->fields_by_name('header')->set_message_type($_URLFETCHREQUEST_HEADER);
$_URLFETCHRESPONSE->fields_by_name('header')->set_message_type($_URLFETCHRESPONSE_HEADER);

## Messages:
Protobuf::Message->GenerateClass(__PACKAGE__ . '::URLFetchServiceError', $_URLFETCHSERVICEERROR);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::URLFetchRequest', $_URLFETCHREQUEST);
Protobuf::Message->GenerateClass(__PACKAGE__ . '::URLFetchRequest::Header', $_URLFETCHREQUEST_HEADER);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::URLFetchResponse', $_URLFETCHRESPONSE);
Protobuf::Message->GenerateClass(__PACKAGE__ . '::URLFetchResponse::Header', $_URLFETCHRESPONSE_HEADER);

## Fix foreign fields in extensions:
## Services:
