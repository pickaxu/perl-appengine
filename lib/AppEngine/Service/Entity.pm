## Boilerplate:
# Auto-generated code from the protocol buffer compiler.  DO NOT EDIT!

use strict;
use warnings;
use 5.6.1;
use Protobuf;
package AppEngine::Service::Entity;

package AppEngine::Service::Entity;


use constant TRUE => 1;
use constant FALSE => 0;
## Top-level enums:

## Top-level extensions:

## All nested enums:
our $_PROPERTY_MEANING = Protobuf::EnumDescriptor->new(
  name => 'Meaning',
  full_name => 'appengine_entity.Property.Meaning',
  values => [
    Protobuf::EnumValueDescriptor->new(name => 'BLOB', index => 0, number => 14, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'TEXT', index => 1, number => 15, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'ATOM_CATEGORY', index => 2, number => 1, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'ATOM_LINK', index => 3, number => 2, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'ATOM_TITLE', index => 4, number => 3, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'ATOM_CONTENT', index => 5, number => 4, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'ATOM_SUMMARY', index => 6, number => 5, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'ATOM_AUTHOR', index => 7, number => 6, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'GD_WHEN', index => 8, number => 7, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'GD_EMAIL', index => 9, number => 8, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'GEORSS_POINT', index => 10, number => 9, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'GD_IM', index => 11, number => 10, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'GD_PHONENUMBER', index => 12, number => 11, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'GD_POSTALADDRESS', index => 13, number => 12, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'GD_RATING', index => 14, number => 13, type => undef),
]);
$_PROPERTY_MEANING->values->[0]->set_type($_PROPERTY_MEANING);
$_PROPERTY_MEANING->values->[1]->set_type($_PROPERTY_MEANING);
$_PROPERTY_MEANING->values->[2]->set_type($_PROPERTY_MEANING);
$_PROPERTY_MEANING->values->[3]->set_type($_PROPERTY_MEANING);
$_PROPERTY_MEANING->values->[4]->set_type($_PROPERTY_MEANING);
$_PROPERTY_MEANING->values->[5]->set_type($_PROPERTY_MEANING);
$_PROPERTY_MEANING->values->[6]->set_type($_PROPERTY_MEANING);
$_PROPERTY_MEANING->values->[7]->set_type($_PROPERTY_MEANING);
$_PROPERTY_MEANING->values->[8]->set_type($_PROPERTY_MEANING);
$_PROPERTY_MEANING->values->[9]->set_type($_PROPERTY_MEANING);
$_PROPERTY_MEANING->values->[10]->set_type($_PROPERTY_MEANING);
$_PROPERTY_MEANING->values->[11]->set_type($_PROPERTY_MEANING);
$_PROPERTY_MEANING->values->[12]->set_type($_PROPERTY_MEANING);
$_PROPERTY_MEANING->values->[13]->set_type($_PROPERTY_MEANING);
$_PROPERTY_MEANING->values->[14]->set_type($_PROPERTY_MEANING);

our $_ENTITYPROTO_KIND = Protobuf::EnumDescriptor->new(
  name => 'Kind',
  full_name => 'appengine_entity.EntityProto.Kind',
  values => [
    Protobuf::EnumValueDescriptor->new(name => 'GD_CONTACT', index => 0, number => 1, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'GD_EVENT', index => 1, number => 2, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'GD_MESSAGE', index => 2, number => 3, type => undef),
]);
$_ENTITYPROTO_KIND->values->[0]->set_type($_ENTITYPROTO_KIND);
$_ENTITYPROTO_KIND->values->[1]->set_type($_ENTITYPROTO_KIND);
$_ENTITYPROTO_KIND->values->[2]->set_type($_ENTITYPROTO_KIND);

our $_INDEX_PROPERTY_DIRECTION = Protobuf::EnumDescriptor->new(
  name => 'Direction',
  full_name => 'appengine_entity.Index.Property.Direction',
  values => [
    Protobuf::EnumValueDescriptor->new(name => 'ASCENDING', index => 0, number => 1, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'DESCENDING', index => 1, number => 2, type => undef),
]);
$_INDEX_PROPERTY_DIRECTION->values->[0]->set_type($_INDEX_PROPERTY_DIRECTION);
$_INDEX_PROPERTY_DIRECTION->values->[1]->set_type($_INDEX_PROPERTY_DIRECTION);

our $_COMPOSITEINDEX_STATE = Protobuf::EnumDescriptor->new(
  name => 'State',
  full_name => 'appengine_entity.CompositeIndex.State',
  values => [
    Protobuf::EnumValueDescriptor->new(name => 'WRITE_ONLY', index => 0, number => 1, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'READ_WRITE', index => 1, number => 2, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'DELETED', index => 2, number => 3, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'ERROR', index => 3, number => 4, type => undef),
]);
$_COMPOSITEINDEX_STATE->values->[0]->set_type($_COMPOSITEINDEX_STATE);
$_COMPOSITEINDEX_STATE->values->[1]->set_type($_COMPOSITEINDEX_STATE);
$_COMPOSITEINDEX_STATE->values->[2]->set_type($_COMPOSITEINDEX_STATE);
$_COMPOSITEINDEX_STATE->values->[3]->set_type($_COMPOSITEINDEX_STATE);

## Message descriptors:

our $_PROPERTYVALUE_POINTVALUE = Protobuf::Descriptor->new(
  name => 'PointValue',
  full_name => 'appengine_entity.PropertyValue.PointValue',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'x', index => 0, number => 6,
      type => 1, cpp_type => 5, label => 2,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'y', index => 1, number => 7,
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

our $_PROPERTYVALUE_USERVALUE = Protobuf::Descriptor->new(
  name => 'UserValue',
  full_name => 'appengine_entity.PropertyValue.UserValue',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'email', index => 0, number => 9,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'auth_domain', index => 1, number => 10,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'nickname', index => 2, number => 11,
      type => 9, cpp_type => 9, label => 1,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'gaiaid', index => 3, number => 18,
      type => 3, cpp_type => 2, label => 2,
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

our $_PROPERTYVALUE_REFERENCEVALUE_PATHELEMENT = Protobuf::Descriptor->new(
  name => 'PathElement',
  full_name => 'appengine_entity.PropertyValue.ReferenceValue.PathElement',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'type', index => 0, number => 15,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'id', index => 1, number => 16,
      type => 3, cpp_type => 2, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'name', index => 2, number => 17,
      type => 12, cpp_type => 9, label => 1,
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

our $_PROPERTYVALUE_REFERENCEVALUE = Protobuf::Descriptor->new(
  name => 'ReferenceValue',
  full_name => 'appengine_entity.PropertyValue.ReferenceValue',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'app', index => 0, number => 13,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'pathelement', index => 1, number => 14,
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

our $_PROPERTYVALUE = Protobuf::Descriptor->new(
  name => 'PropertyValue',
  full_name => 'appengine_entity.PropertyValue',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'int64Value', index => 0, number => 1,
      type => 3, cpp_type => 2, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'booleanValue', index => 1, number => 2,
      type => 8, cpp_type => 7, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'stringValue', index => 2, number => 3,
      type => 12, cpp_type => 9, label => 1,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'doubleValue', index => 3, number => 4,
      type => 1, cpp_type => 5, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'pointvalue', index => 4, number => 5,
      type => 10, cpp_type => 10, label => 1,
      default_value => undef,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'uservalue', index => 5, number => 8,
      type => 10, cpp_type => 10, label => 1,
      default_value => undef,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'referencevalue', index => 6, number => 12,
      type => 10, cpp_type => 10, label => 1,
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


our $_PROPERTY = Protobuf::Descriptor->new(
  name => 'Property',
  full_name => 'appengine_entity.Property',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'meaning', index => 0, number => 1,
      type => 14, cpp_type => 8, label => 1,
      default_value => 14,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'meaning_uri', index => 1, number => 2,
      type => 12, cpp_type => 9, label => 1,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'name', index => 2, number => 3,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'value', index => 3, number => 5,
      type => 11, cpp_type => 10, label => 2,
      default_value => undef,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'multiple', index => 4, number => 4,
      type => 8, cpp_type => 7, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
    $_PROPERTY_MEANING,
  ],
  options => Protobuf::MessageOptions->new(
  ),
);


our $_PATH_ELEMENT = Protobuf::Descriptor->new(
  name => 'Element',
  full_name => 'appengine_entity.Path.Element',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'type', index => 0, number => 2,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'id', index => 1, number => 3,
      type => 3, cpp_type => 2, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'name', index => 2, number => 4,
      type => 12, cpp_type => 9, label => 1,
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

our $_PATH = Protobuf::Descriptor->new(
  name => 'Path',
  full_name => 'appengine_entity.Path',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'element', index => 0, number => 1,
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


our $_REFERENCE = Protobuf::Descriptor->new(
  name => 'Reference',
  full_name => 'appengine_entity.Reference',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'app', index => 0, number => 13,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'path', index => 1, number => 14,
      type => 11, cpp_type => 10, label => 2,
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


our $_USER = Protobuf::Descriptor->new(
  name => 'User',
  full_name => 'appengine_entity.User',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'email', index => 0, number => 1,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'auth_domain', index => 1, number => 2,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'nickname', index => 2, number => 3,
      type => 9, cpp_type => 9, label => 1,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'gaiaid', index => 3, number => 4,
      type => 3, cpp_type => 2, label => 2,
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


our $_ENTITYPROTO = Protobuf::Descriptor->new(
  name => 'EntityProto',
  full_name => 'appengine_entity.EntityProto',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'key', index => 0, number => 13,
      type => 11, cpp_type => 10, label => 2,
      default_value => undef,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'entity_group', index => 1, number => 16,
      type => 11, cpp_type => 10, label => 2,
      default_value => undef,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'owner', index => 2, number => 17,
      type => 11, cpp_type => 10, label => 1,
      default_value => undef,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'kind', index => 3, number => 4,
      type => 14, cpp_type => 8, label => 1,
      default_value => 1,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'kind_uri', index => 4, number => 5,
      type => 12, cpp_type => 9, label => 1,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'property', index => 5, number => 14,
      type => 11, cpp_type => 10, label => 3,
      default_value => [],
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'raw_property', index => 6, number => 15,
      type => 11, cpp_type => 10, label => 3,
      default_value => [],
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
    $_ENTITYPROTO_KIND,
  ],
  options => Protobuf::MessageOptions->new(
  ),
);


our $_COMPOSITEPROPERTY = Protobuf::Descriptor->new(
  name => 'CompositeProperty',
  full_name => 'appengine_entity.CompositeProperty',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'index_id', index => 0, number => 1,
      type => 3, cpp_type => 2, label => 2,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'value', index => 1, number => 2,
      type => 12, cpp_type => 9, label => 3,
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


our $_INDEX_PROPERTY = Protobuf::Descriptor->new(
  name => 'Property',
  full_name => 'appengine_entity.Index.Property',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'name', index => 0, number => 3,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'direction', index => 1, number => 4,
      type => 14, cpp_type => 8, label => 1,
      default_value => 1,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
    $_INDEX_PROPERTY_DIRECTION,
  ],
  options => Protobuf::MessageOptions->new(
  ),
);

our $_INDEX = Protobuf::Descriptor->new(
  name => 'Index',
  full_name => 'appengine_entity.Index',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'entity_type', index => 0, number => 1,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'ancestor', index => 1, number => 5,
      type => 8, cpp_type => 7, label => 2,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'property', index => 2, number => 2,
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


our $_COMPOSITEINDEX = Protobuf::Descriptor->new(
  name => 'CompositeIndex',
  full_name => 'appengine_entity.CompositeIndex',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'app_id', index => 0, number => 1,
      type => 12, cpp_type => 9, label => 2,
      default_value => "",
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'id', index => 1, number => 2,
      type => 3, cpp_type => 2, label => 2,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'definition', index => 2, number => 3,
      type => 11, cpp_type => 10, label => 2,
      default_value => undef,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'state', index => 3, number => 4,
      type => 14, cpp_type => 8, label => 2,
      default_value => 1,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
    $_COMPOSITEINDEX_STATE,
  ],
  options => Protobuf::MessageOptions->new(
  ),
);

## Imports:

## Fix foreign fields:
$_PROPERTYVALUE_REFERENCEVALUE->fields_by_name('pathelement')->set_message_type($_PROPERTYVALUE_REFERENCEVALUE_PATHELEMENT);
$_PROPERTYVALUE->fields_by_name('pointvalue')->set_message_type($_PROPERTYVALUE_POINTVALUE);
$_PROPERTYVALUE->fields_by_name('uservalue')->set_message_type($_PROPERTYVALUE_USERVALUE);
$_PROPERTYVALUE->fields_by_name('referencevalue')->set_message_type($_PROPERTYVALUE_REFERENCEVALUE);
$_PROPERTY->fields_by_name('meaning')->set_enum_type($_PROPERTY_MEANING);
$_PROPERTY->fields_by_name('value')->set_message_type($_PROPERTYVALUE);
$_PATH->fields_by_name('element')->set_message_type($_PATH_ELEMENT);
$_REFERENCE->fields_by_name('path')->set_message_type($_PATH);
$_ENTITYPROTO->fields_by_name('key')->set_message_type($_REFERENCE);
$_ENTITYPROTO->fields_by_name('entity_group')->set_message_type($_PATH);
$_ENTITYPROTO->fields_by_name('owner')->set_message_type($_USER);
$_ENTITYPROTO->fields_by_name('kind')->set_enum_type($_ENTITYPROTO_KIND);
$_ENTITYPROTO->fields_by_name('property')->set_message_type($_PROPERTY);
$_ENTITYPROTO->fields_by_name('raw_property')->set_message_type($_PROPERTY);
$_INDEX_PROPERTY->fields_by_name('direction')->set_enum_type($_INDEX_PROPERTY_DIRECTION);
$_INDEX->fields_by_name('property')->set_message_type($_INDEX_PROPERTY);
$_COMPOSITEINDEX->fields_by_name('definition')->set_message_type($_INDEX);
$_COMPOSITEINDEX->fields_by_name('state')->set_enum_type($_COMPOSITEINDEX_STATE);

## Messages:
Protobuf::Message->GenerateClass(__PACKAGE__ . '::PropertyValue', $_PROPERTYVALUE);
Protobuf::Message->GenerateClass(__PACKAGE__ . '::PropertyValue::PointValue', $_PROPERTYVALUE_POINTVALUE);
Protobuf::Message->GenerateClass(__PACKAGE__ . '::PropertyValue::UserValue', $_PROPERTYVALUE_USERVALUE);
Protobuf::Message->GenerateClass(__PACKAGE__ . '::PropertyValue::ReferenceValue', $_PROPERTYVALUE_REFERENCEVALUE);
Protobuf::Message->GenerateClass(__PACKAGE__ . '::PropertyValue::ReferenceValue::PathElement', $_PROPERTYVALUE_REFERENCEVALUE_PATHELEMENT);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::Property', $_PROPERTY);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::Path', $_PATH);
Protobuf::Message->GenerateClass(__PACKAGE__ . '::Path::Element', $_PATH_ELEMENT);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::Reference', $_REFERENCE);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::User', $_USER);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::EntityProto', $_ENTITYPROTO);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::CompositeProperty', $_COMPOSITEPROPERTY);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::Index', $_INDEX);
Protobuf::Message->GenerateClass(__PACKAGE__ . '::Index::Property', $_INDEX_PROPERTY);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::CompositeIndex', $_COMPOSITEINDEX);

## Fix foreign fields in extensions:
## Services:
