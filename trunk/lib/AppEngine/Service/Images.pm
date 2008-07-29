## Boilerplate:
# Auto-generated code from the protocol buffer compiler.  DO NOT EDIT!

use strict;
use warnings;
use 5.6.1;
use Protobuf;
package AppEngine::Service::Images;

package AppEngine::Service;


use constant TRUE => 1;
use constant FALSE => 0;
## Top-level enums:

## Top-level extensions:

## All nested enums:
our $_IMAGESSERVICEERROR_ERRORCODE = Protobuf::EnumDescriptor->new(
  name => 'ErrorCode',
  full_name => 'appengine_api.ImagesServiceError.ErrorCode',
  values => [
    Protobuf::EnumValueDescriptor->new(name => 'UNSPECIFIED_ERROR', index => 0, number => 1, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'BAD_TRANSFORM_DATA', index => 1, number => 2, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'NOT_IMAGE', index => 2, number => 3, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'BAD_IMAGE_DATA', index => 3, number => 4, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'IMAGE_TOO_LARGE', index => 4, number => 5, type => undef),
]);
$_IMAGESSERVICEERROR_ERRORCODE->values->[0]->set_type($_IMAGESSERVICEERROR_ERRORCODE);
$_IMAGESSERVICEERROR_ERRORCODE->values->[1]->set_type($_IMAGESSERVICEERROR_ERRORCODE);
$_IMAGESSERVICEERROR_ERRORCODE->values->[2]->set_type($_IMAGESSERVICEERROR_ERRORCODE);
$_IMAGESSERVICEERROR_ERRORCODE->values->[3]->set_type($_IMAGESSERVICEERROR_ERRORCODE);
$_IMAGESSERVICEERROR_ERRORCODE->values->[4]->set_type($_IMAGESSERVICEERROR_ERRORCODE);

our $_IMAGESSERVICETRANSFORM_TYPE = Protobuf::EnumDescriptor->new(
  name => 'Type',
  full_name => 'appengine_api.ImagesServiceTransform.Type',
  values => [
    Protobuf::EnumValueDescriptor->new(name => 'RESIZE', index => 0, number => 1, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'ROTATE', index => 1, number => 2, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'HORIZONTAL_FLIP', index => 2, number => 3, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'VERTICAL_FLIP', index => 3, number => 4, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'CROP', index => 4, number => 5, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'IM_FEELING_LUCKY', index => 5, number => 6, type => undef),
]);
$_IMAGESSERVICETRANSFORM_TYPE->values->[0]->set_type($_IMAGESSERVICETRANSFORM_TYPE);
$_IMAGESSERVICETRANSFORM_TYPE->values->[1]->set_type($_IMAGESSERVICETRANSFORM_TYPE);
$_IMAGESSERVICETRANSFORM_TYPE->values->[2]->set_type($_IMAGESSERVICETRANSFORM_TYPE);
$_IMAGESSERVICETRANSFORM_TYPE->values->[3]->set_type($_IMAGESSERVICETRANSFORM_TYPE);
$_IMAGESSERVICETRANSFORM_TYPE->values->[4]->set_type($_IMAGESSERVICETRANSFORM_TYPE);
$_IMAGESSERVICETRANSFORM_TYPE->values->[5]->set_type($_IMAGESSERVICETRANSFORM_TYPE);

our $_OUTPUTSETTINGS_MIME_TYPE = Protobuf::EnumDescriptor->new(
  name => 'MIME_TYPE',
  full_name => 'appengine_api.OutputSettings.MIME_TYPE',
  values => [
    Protobuf::EnumValueDescriptor->new(name => 'PNG', index => 0, number => 0, type => undef),
    Protobuf::EnumValueDescriptor->new(name => 'JPEG', index => 1, number => 1, type => undef),
]);
$_OUTPUTSETTINGS_MIME_TYPE->values->[0]->set_type($_OUTPUTSETTINGS_MIME_TYPE);
$_OUTPUTSETTINGS_MIME_TYPE->values->[1]->set_type($_OUTPUTSETTINGS_MIME_TYPE);

## Message descriptors:

our $_IMAGESSERVICEERROR = Protobuf::Descriptor->new(
  name => 'ImagesServiceError',
  full_name => 'appengine_api.ImagesServiceError',
  containing_type => undef,
  fields => [
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
    $_IMAGESSERVICEERROR_ERRORCODE,
  ],
  options => Protobuf::MessageOptions->new(
  ),
);


our $_IMAGESSERVICETRANSFORM = Protobuf::Descriptor->new(
  name => 'ImagesServiceTransform',
  full_name => 'appengine_api.ImagesServiceTransform',
  containing_type => undef,
  fields => [
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
    $_IMAGESSERVICETRANSFORM_TYPE,
  ],
  options => Protobuf::MessageOptions->new(
  ),
);


our $_TRANSFORM = Protobuf::Descriptor->new(
  name => 'Transform',
  full_name => 'appengine_api.Transform',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'width', index => 0, number => 1,
      type => 5, cpp_type => 1, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'height', index => 1, number => 2,
      type => 5, cpp_type => 1, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'rotate', index => 2, number => 3,
      type => 5, cpp_type => 1, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'horizontal_flip', index => 3, number => 4,
      type => 8, cpp_type => 7, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'vertical_flip', index => 4, number => 5,
      type => 8, cpp_type => 7, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'crop_left_x', index => 5, number => 6,
      type => 2, cpp_type => 6, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'crop_top_y', index => 6, number => 7,
      type => 2, cpp_type => 6, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'crop_right_x', index => 7, number => 8,
      type => 2, cpp_type => 6, label => 1,
      default_value => 1,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'crop_bottom_y', index => 8, number => 9,
      type => 2, cpp_type => 6, label => 1,
      default_value => 1,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'autolevels', index => 9, number => 10,
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


our $_IMAGEDATA = Protobuf::Descriptor->new(
  name => 'ImageData',
  full_name => 'appengine_api.ImageData',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'content', index => 0, number => 1,
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


our $_OUTPUTSETTINGS = Protobuf::Descriptor->new(
  name => 'OutputSettings',
  full_name => 'appengine_api.OutputSettings',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'mime_type', index => 0, number => 1,
      type => 14, cpp_type => 8, label => 1,
      default_value => 0,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
  ],
  extensions => [
  ],
  nested_types => [],  # TODO(bradfitz): Implement.
  enum_types => [
    $_OUTPUTSETTINGS_MIME_TYPE,
  ],
  options => Protobuf::MessageOptions->new(
  ),
);


our $_IMAGESTRANSFORMREQUEST = Protobuf::Descriptor->new(
  name => 'ImagesTransformRequest',
  full_name => 'appengine_api.ImagesTransformRequest',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'image', index => 0, number => 1,
      type => 11, cpp_type => 10, label => 2,
      default_value => undef,
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'transform', index => 1, number => 2,
      type => 11, cpp_type => 10, label => 3,
      default_value => [],
      message_type => undef, enum_type => undef, containing_type => undef,
      is_extension => FALSE, extension_scope => undef),
    Protobuf::FieldDescriptor->new(
      name => 'output', index => 2, number => 3,
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


our $_IMAGESTRANSFORMRESPONSE = Protobuf::Descriptor->new(
  name => 'ImagesTransformResponse',
  full_name => 'appengine_api.ImagesTransformResponse',
  containing_type => undef,
  fields => [
    Protobuf::FieldDescriptor->new(
      name => 'image', index => 0, number => 1,
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

## Imports:

## Fix foreign fields:
$_OUTPUTSETTINGS->fields_by_name('mime_type')->set_enum_type($_OUTPUTSETTINGS_MIME_TYPE);
$_IMAGESTRANSFORMREQUEST->fields_by_name('image')->set_message_type($_IMAGEDATA);
$_IMAGESTRANSFORMREQUEST->fields_by_name('transform')->set_message_type($_TRANSFORM);
$_IMAGESTRANSFORMREQUEST->fields_by_name('output')->set_message_type($_OUTPUTSETTINGS);
$_IMAGESTRANSFORMRESPONSE->fields_by_name('image')->set_message_type($_IMAGEDATA);

## Messages:
Protobuf::Message->GenerateClass(__PACKAGE__ . '::ImagesServiceError', $_IMAGESSERVICEERROR);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::ImagesServiceTransform', $_IMAGESSERVICETRANSFORM);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::Transform', $_TRANSFORM);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::ImageData', $_IMAGEDATA);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::OutputSettings', $_OUTPUTSETTINGS);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::ImagesTransformRequest', $_IMAGESTRANSFORMREQUEST);

Protobuf::Message->GenerateClass(__PACKAGE__ . '::ImagesTransformResponse', $_IMAGESTRANSFORMRESPONSE);

## Fix foreign fields in extensions:
## Services:
