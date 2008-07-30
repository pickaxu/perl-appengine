## Boilerplate:
# Auto-generated code from the protocol buffer compiler.  DO NOT EDIT!

use strict;
use warnings;
use 5.6.1;
use Protobuf;
package AppEngine::Service::Datastore;

package AppEngine::Service::Datastore;


use constant TRUE => 1;
use constant FALSE => 0;
## Top-level enums:

## Top-level extensions:

## All nested enums:
our $_QUERY_FILTER_OPERATOR = Protobuf::EnumDescriptor->new(
  name => 'Operator',
  full_name => 'appengine_datastore_v3.Query.Filter.Operator',
  values => [
    Protobuf::EnumValueDescriptor->new(name => 'LESS_THAN', index => 0, number => 1, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'LESS_THAN_OR_EQUAL', index => 1, number => 2, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'GREATER_THAN', index => 2, number => 3, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'GREATER_THAN_OR_EQUAL', index => 3, number => 4, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'EQUAL', index => 4, number => 5, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'IN', index => 5, number => 6, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'EXISTS', index => 6, number => 7, type => undef),
]);
$_QUERY_FILTER_OPERATOR->values->[0]->set_type($_QUERY_FILTER_OPERATOR);
$_QUERY_FILTER_OPERATOR->values->[1]->set_type($_QUERY_FILTER_OPERATOR);
$_QUERY_FILTER_OPERATOR->values->[2]->set_type($_QUERY_FILTER_OPERATOR);
$_QUERY_FILTER_OPERATOR->values->[3]->set_type($_QUERY_FILTER_OPERATOR);
$_QUERY_FILTER_OPERATOR->values->[4]->set_type($_QUERY_FILTER_OPERATOR);
$_QUERY_FILTER_OPERATOR->values->[5]->set_type($_QUERY_FILTER_OPERATOR);
$_QUERY_FILTER_OPERATOR->values->[6]->set_type($_QUERY_FILTER_OPERATOR);

our $_QUERY_ORDER_DIRECTION = Protobuf::EnumDescriptor->new(
  name => 'Direction',
  full_name => 'appengine_datastore_v3.Query.Order.Direction',
  values => [
    Protobuf::EnumValueDescriptor->new(name => 'ASCENDING', index => 0, number => 1, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'DESCENDING', index => 1, number => 2, type => undef),
]);
$_QUERY_ORDER_DIRECTION->values->[0]->set_type($_QUERY_ORDER_DIRECTION);
$_QUERY_ORDER_DIRECTION->values->[1]->set_type($_QUERY_ORDER_DIRECTION);

our $_ERROR_ERRORCODE = Protobuf::EnumDescriptor->new(
  name => 'ErrorCode',
  full_name => 'appengine_datastore_v3.Error.ErrorCode',
  values => [
    Protobuf::EnumValueDescriptor->new(name => 'BAD_REQUEST', index => 0, number => 1, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'CONCURRENT_TRANSACTION', index => 1, number => 2, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'INTERNAL_ERROR', index => 2, number => 3, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'NEED_INDEX', index => 3, number => 4, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'TIMEOUT', index => 4, number => 5, type => undef),
]);
$_ERROR_ERRORCODE->values->[0]->set_type($_ERROR_ERRORCODE);
$_ERROR_ERRORCODE->values->[1]->set_type($_ERROR_ERRORCODE);
$_ERROR_ERRORCODE->values->[2]->set_type($_ERROR_ERRORCODE);
$_ERROR_ERRORCODE->values->[3]->set_type($_ERROR_ERRORCODE);
$_ERROR_ERRORCODE->values->[4]->set_type($_ERROR_ERRORCODE);

## Message descriptors:

our $_TRANSACTION = Protobuf::Descriptor->new(
  name => 'Transaction',
  full_name => 'appengine_datastore_v3.Transaction',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'handle', index => 0, number => 1,
      type => 6, cpp_type => 4, label => 2,
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


our $_QUERY_FILTER = Protobuf::Descriptor->new(
  name => 'Filter',
  full_name => 'appengine_datastore_v3.Query.Filter',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'op', index => 0, number => 6,
      type => 5, cpp_type => 1, label => 2,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'property', index => 1, number => 14,
      type => 11, cpp_type => 10, label => 3,
      default_value => [],
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
    $_QUERY_FILTER_OPERATOR,
  ],
  options => Protobuf::MessageOptions->new(
  ),
);

our $_QUERY_ORDER = Protobuf::Descriptor->new(
  name => 'Order',
  full_name => 'appengine_datastore_v3.Query.Order',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'property', index => 0, number => 10,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'direction', index => 1, number => 11,
      type => 5, cpp_type => 1, label => 1,
      default_value => 1,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
    $_QUERY_ORDER_DIRECTION,
  ],
  options => Protobuf::MessageOptions->new(
  ),
);

our $_QUERY = Protobuf::Descriptor->new(
  name => 'Query',
  full_name => 'appengine_datastore_v3.Query',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'app', index => 0, number => 1,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'kind', index => 1, number => 3,
      type => 12, cpp_type => 9, label => 1,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'ancestor', index => 2, number => 17,
      type => 11, cpp_type => 10, label => 1,
      default_value => undef,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'filter', index => 3, number => 4,
      type => 10, cpp_type => 10, label => 3,
      default_value => [],
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'search_query', index => 4, number => 8,
      type => 12, cpp_type => 9, label => 1,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'order', index => 5, number => 9,
      type => 10, cpp_type => 10, label => 3,
      default_value => [],
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'offset', index => 6, number => 12,
      type => 5, cpp_type => 1, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'limit', index => 7, number => 16,
      type => 5, cpp_type => 1, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'composite_index', index => 8, number => 19,
      type => 11, cpp_type => 10, label => 3,
      default_value => [],
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'require_perfect_plan', index => 9, number => 20,
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


our $_QUERYEXPLANATION = Protobuf::Descriptor->new(
  name => 'QueryExplanation',
  full_name => 'appengine_datastore_v3.QueryExplanation',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'native_ancestor', index => 0, number => 1,
      type => 8, cpp_type => 7, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'native_index', index => 1, number => 2,
      type => 11, cpp_type => 10, label => 3,
      default_value => [],
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'native_offset', index => 2, number => 3,
      type => 5, cpp_type => 1, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'native_limit', index => 3, number => 4,
      type => 5, cpp_type => 1, label => 1,
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


our $_CURSOR = Protobuf::Descriptor->new(
  name => 'Cursor',
  full_name => 'appengine_datastore_v3.Cursor',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'cursor', index => 0, number => 1,
      type => 6, cpp_type => 4, label => 2,
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


our $_ERROR = Protobuf::Descriptor->new(
  name => 'Error',
  full_name => 'appengine_datastore_v3.Error',
  containing_type => undef,
  fields => [
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
    $_ERROR_ERRORCODE,
  ],
  options => Protobuf::MessageOptions->new(
  ),
);


our $_GETREQUEST = Protobuf::Descriptor->new(
  name => 'GetRequest',
  full_name => 'appengine_datastore_v3.GetRequest',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'key', index => 0, number => 1,
      type => 11, cpp_type => 10, label => 3,
      default_value => [],
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'transaction', index => 1, number => 2,
      type => 11, cpp_type => 10, label => 1,
      default_value => undef,
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


our $_GETRESPONSE_ENTITY = Protobuf::Descriptor->new(
  name => 'Entity',
  full_name => 'appengine_datastore_v3.GetResponse.Entity',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'entity', index => 0, number => 2,
      type => 11, cpp_type => 10, label => 1,
      default_value => undef,
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

our $_GETRESPONSE = Protobuf::Descriptor->new(
  name => 'GetResponse',
  full_name => 'appengine_datastore_v3.GetResponse',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'entity', index => 0, number => 1,
      type => 10, cpp_type => 10, label => 3,
      default_value => [],
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


our $_PUTREQUEST = Protobuf::Descriptor->new(
  name => 'PutRequest',
  full_name => 'appengine_datastore_v3.PutRequest',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'entity', index => 0, number => 1,
      type => 11, cpp_type => 10, label => 3,
      default_value => [],
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'transaction', index => 1, number => 2,
      type => 11, cpp_type => 10, label => 1,
      default_value => undef,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'composite_index', index => 2, number => 3,
      type => 11, cpp_type => 10, label => 3,
      default_value => [],
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


our $_PUTRESPONSE = Protobuf::Descriptor->new(
  name => 'PutResponse',
  full_name => 'appengine_datastore_v3.PutResponse',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'key', index => 0, number => 1,
      type => 11, cpp_type => 10, label => 3,
      default_value => [],
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


our $_DELETEREQUEST = Protobuf::Descriptor->new(
  name => 'DeleteRequest',
  full_name => 'appengine_datastore_v3.DeleteRequest',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'key', index => 0, number => 6,
      type => 11, cpp_type => 10, label => 3,
      default_value => [],
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'transaction', index => 1, number => 5,
      type => 11, cpp_type => 10, label => 1,
      default_value => undef,
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


our $_NEXTREQUEST = Protobuf::Descriptor->new(
  name => 'NextRequest',
  full_name => 'appengine_datastore_v3.NextRequest',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'cursor', index => 0, number => 1,
      type => 11, cpp_type => 10, label => 2,
      default_value => undef,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'count', index => 1, number => 2,
      type => 5, cpp_type => 1, label => 1,
      default_value => 1,
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


our $_QUERYRESULT = Protobuf::Descriptor->new(
  name => 'QueryResult',
  full_name => 'appengine_datastore_v3.QueryResult',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'cursor', index => 0, number => 1,
      type => 11, cpp_type => 10, label => 1,
      default_value => undef,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'result', index => 1, number => 2,
      type => 11, cpp_type => 10, label => 3,
      default_value => [],
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'more_results', index => 2, number => 3,
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


our $_SCHEMA = Protobuf::Descriptor->new(
  name => 'Schema',
  full_name => 'appengine_datastore_v3.Schema',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'kind', index => 0, number => 1,
      type => 11, cpp_type => 10, label => 3,
      default_value => [],
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


our $_COMPOSITEINDICES = Protobuf::Descriptor->new(
  name => 'CompositeIndices',
  full_name => 'appengine_datastore_v3.CompositeIndices',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'index', index => 0, number => 1,
      type => 11, cpp_type => 10, label => 3,
      default_value => [],
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
eval "use AppEngine::Service::Entity;";
eval "use AppEngine::Service::Base;";

## Fix foreign fields:
$_QUERY_FILTER->fields_by_name('property')->set_message_type($AppEngine::Service::Entity::_PROPERTY);
$_QUERY->fields_by_name('ancestor')->set_message_type($AppEngine::Service::Entity::_REFERENCE);
$_QUERY->fields_by_name('filter')->set_message_type($_QUERY_FILTER);
$_QUERY->fields_by_name('order')->set_message_type($_QUERY_ORDER);
$_QUERY->fields_by_name('composite_index')->set_message_type($AppEngine::Service::Entity::_COMPOSITEINDEX);
$_QUERYEXPLANATION->fields_by_name('native_index')->set_message_type($AppEngine::Service::Entity::_INDEX);
$_GETREQUEST->fields_by_name('key')->set_message_type($AppEngine::Service::Entity::_REFERENCE);
$_GETREQUEST->fields_by_name('transaction')->set_message_type($_TRANSACTION);
$_GETRESPONSE_ENTITY->fields_by_name('entity')->set_message_type($AppEngine::Service::Entity::_ENTITYPROTO);
$_GETRESPONSE->fields_by_name('entity')->set_message_type($_GETRESPONSE_ENTITY);
$_PUTREQUEST->fields_by_name('entity')->set_message_type($AppEngine::Service::Entity::_ENTITYPROTO);
$_PUTREQUEST->fields_by_name('transaction')->set_message_type($_TRANSACTION);
$_PUTREQUEST->fields_by_name('composite_index')->set_message_type($AppEngine::Service::Entity::_COMPOSITEINDEX);
$_PUTRESPONSE->fields_by_name('key')->set_message_type($AppEngine::Service::Entity::_REFERENCE);
$_DELETEREQUEST->fields_by_name('key')->set_message_type($AppEngine::Service::Entity::_REFERENCE);
$_DELETEREQUEST->fields_by_name('transaction')->set_message_type($_TRANSACTION);
$_NEXTREQUEST->fields_by_name('cursor')->set_message_type($_CURSOR);
$_QUERYRESULT->fields_by_name('cursor')->set_message_type($_CURSOR);
$_QUERYRESULT->fields_by_name('result')->set_message_type($AppEngine::Service::Entity::_ENTITYPROTO);
$_SCHEMA->fields_by_name('kind')->set_message_type($AppEngine::Service::Entity::_ENTITYPROTO);
$_COMPOSITEINDICES->fields_by_name('index')->set_message_type($AppEngine::Service::Entity::_COMPOSITEINDEX);

## Messages:
Protobuf::Message->GenerateClass(__PACKAGE__ . '::Transaction', $_TRANSACTION);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::Query', $_QUERY);
Protobuf::Message->GenerateClass(__PACKAGE__ . '::Query::Filter', $_QUERY_FILTER);
Protobuf::Message->GenerateClass(__PACKAGE__ . '::Query::Order', $_QUERY_ORDER);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::QueryExplanation', $_QUERYEXPLANATION);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::Cursor', $_CURSOR);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::Error', $_ERROR);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::GetRequest', $_GETREQUEST);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::GetResponse', $_GETRESPONSE);
Protobuf::Message->GenerateClass(__PACKAGE__ . '::GetResponse::Entity', $_GETRESPONSE_ENTITY);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::PutRequest', $_PUTREQUEST);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::PutResponse', $_PUTRESPONSE);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::DeleteRequest', $_DELETEREQUEST);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::NextRequest', $_NEXTREQUEST);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::QueryResult', $_QUERYRESULT);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::Schema', $_SCHEMA);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::CompositeIndices', $_COMPOSITEINDICES);

## Fix foreign fields in extensions:
## Services:
