=pod

=head1 NAME

AppEngine::API::Images - Perl version of google.appengine.api.images

=head1 SYNOPSIS

    #
    #    functional interface
    #
    images_resize();
    images_crop();
    images_rotate();
    images_horizontal_flip();
    images_vertical_flip();
    images_im_feeling_lucky();
    #
    #    OO interface
    #
    my $image = AppEngine::API::Images::Image->new($image_data);
    $image->resize();
    $image->crop();
    $image->rotate();
    $image->horizontal_flip();
    $image->vertical_flip();
    $image->im_feeling_lucky();
    $image->execute_transforms();

=head1 DESCRIPTION

Implements Perl equivalents of the Google AppEngine API Images interface.

=head1 METHODS

=cut

use strict;
use warnings;

package AppEngine::API::Images;

use AppEngine::APIProxy;
use AppEngine::Service::Base;
use AppEngine::Service::Images;

use base qw(Exporter);

use constant IMAGES_PNG => 0;
use constant IMAGES_JPEG => 1;

our %EXPORT_TAGS = (
    images_constants => [ qw/IMAGES_PNG IMAGES_JPEG/ ]
);

our @EXPORT = qw(
    images_resize
    images_crop
    images_rotate
    images_horizontal_flip
    images_vertical_flip
    images_im_feeling_lucky
);

Exporter::export_tags(keys %EXPORT_TAGS);


=pod

=head2 $new_image = images_resize($image_data, $width, $height, $output_encoding)

Resizes an image, scaling down or up to the given width and height. The function takes the image data to resize, and returns the transformed image in the same format.

Arguments:

=over

=item $image_data

The image to resize, as a bytestring (str) in JPEG, PNG, GIF (including animated), BMP, TIFF, or ICO format.

=item $width

The desired width, as a number of pixels. Must be an int or long.

=item $height

The desired height, as a number of pixels. Must be an int or long.

=item $output_encoding

The desired format of the transformed image. This is either images.PNG or images.JPEG. The default is images.PNG.

=back

=cut

sub images_resize {
    my ($image_data, $width, $height, $output_encoding) = @_;
    $width ||= 0;
    $height ||= 0;
    $output_encoding ||= IMAGES_PNG;
    
    return AppEngine::API::Images::Image->new($image_data)
        ->resize($width, $height)
        ->execute_transforms($output_encoding);
}

=pod

=head2 $new_image = images_crop($image_data, $left_x, $top_y, $right_x, $bottom_y, $output_encoding)

Crops an image to a given bounding box. The function takes the image data to crop, and returns the transformed image in the same format.

The left, top, right and bottom of the bounding box are specified as proportional distances. The coordinates of the bounding box are determined as left_x * width, top_y * height, right_x * width and bottom_y * height. This allows you to specify the bounding box independently of the final width and height of the image, which may change simultaneously with a resize action.

Arguments:

=over

=item $image_data

The image to crop, as a bytestring (str) in JPEG, PNG, GIF (including animated), BMP, TIFF, or ICO format. 

=item $left_x

The left border of the bounding box, as a proportion of the image width specified as a float value from 0.0 to 1.0 (inclusive).

=item $top_y

The top border of the bounding box, as a proportion of the image height specified as a float value from 0.0 to 1.0 (inclusive).

=item $right_x

The right border of the bounding box, as a proportion of the image width specified as a float value from 0.0 to 1.0 (inclusive).

=item $bottom_y

The bottom border of the bounding box, as a proportion of the image height specified as a float value from 0.0 to 1.0 (inclusive).

=item $output_encoding

The desired format of the transformed image. This is either images.PNG or images.JPEG. The default is images.PNG.

=back

=cut

sub images_crop {
    my ($image_data, $left_x, $top_y, $right_x, $bottom_y, $output_encoding) = @_;
    $output_encoding ||= images.PNG;
    
    return AppEngine::API::Images::Image->new($image_data)
        ->crop($left_x, $top_y, $right_x, $bottom_y)
        ->execute_transforms($output_encoding);
}

=pod

=head2 $new_image = images_rotate($image_data, $degrees, $output_encoding)

Rotates an image. The amount of rotation must be a multiple of 90 degrees. The function takes the image data to rotate, and returns the transformed image in the same format.

Rotation is performed clockwise. A 90 degree turn rotates the image so that the edge that was the top becomes the right edge.

Arguments:

=over

=item $image_data

The image to rotate, as a bytestring (str) in JPEG, PNG, GIF (including animated), BMP, TIFF, or ICO format. 

=item $degrees

The amount to rotate the image, as a number of degrees, in multiples of 90 degrees.

=item $output_encoding

The desired format of the transformed image. This is either images.PNG or images.JPEG. The default is images.PNG.

=back

=cut

sub images_rotate {
    my ($image_data, $degrees, $output_encoding) = @_;
    $output_encoding ||= IMAGES_PNG;
    
    return AppEngine::API::Images::Image->new($image_data)
        ->rotate($degrees)
        ->execute_transforms($output_encoding);
}

=pod

=head2 $new_image = images_horizontal_flip($image_data, $output_encoding)

Flips an image horizontally. The edge that was the left becomes the right edge, and vice versa. The function takes the image data to flip, and returns the transformed image in the same format.

Arguments:

=over

=item $image_data

The image to flip, as a bytestring (str) in JPEG, PNG, GIF (including animated), BMP, TIFF, or ICO format. 

=item $output_encoding

The desired format of the transformed image. This is either images.PNG or images.JPEG. The default is images.PNG.

=back

=cut

sub images_horizontal_flip {
    my ($image_data, $output_encoding) = @_;
    $output_encoding ||= IMAGES_PNG;
    
    return AppEngine::API::Images::Image->new($image_data)
        ->horizontal_flip()
        ->execute_transforms($output_encoding);
}

=pod

=head2 $new_image = images_vertical_flip($image_data, $output_encoding)

Flips an image vertically. The edge that was the top becomes the bottom edge, and vice versa. The function takes the image data to flip, and returns the transformed image in the same format.

Arguments:

=over

=item $image_data

The image to flip, as a bytestring (str) in JPEG, PNG, GIF (including animated), BMP, TIFF, or ICO format. 

=item $output_encoding

The desired format of the transformed image. This is either images.PNG or images.JPEG. The default is images.PNG.

=back

=cut

sub images_vertical_flip {
    my ($image_data, $output_encoding) = @_;
    $output_encoding ||= IMAGES_PNG;
    
    return AppEngine::API::Images::Image->new($image_data)
        ->vertical_flip()
        ->execute_transforms($output_encoding);
}

=pod

=head2 $new_image = images_im_feeling_lucky($image_data, $output_encoding)

Adjusts the contrast and color levels of an image according to an algorithm for improving photographs. This is similar to the "I'm Feeling Lucky" feature of Google Picasa. The function takes the image data to adjust, and returns the transformed image in the same format.

Arguments:

=over

=item $image_data

The image to adjust, as a bytestring (str) in JPEG, PNG, GIF (including animated), BMP, TIFF, or ICO format. 

=item $output_encoding

The desired format of the transformed image. This is either images.PNG or images.JPEG. The default is images.PNG. 

=back

=cut

sub images_im_feeling_lucky {
    my ($image_data, $output_encoding) = @_;
    $output_encoding ||= IMAGES_PNG;
    
    return AppEngine::API::Images::Image->new($image_data)
        ->im_feeling_lucky()
        ->execute_transforms($output_encoding);
}

1;

package AppEngine::API::Images::Image;

use AppEngine::API::Images qw(
    :images_constants
);

#
#    need to get the image format somehow ?
#

=pod

=head1 AppEngine::API::Images::Image

Provides OO interface for an individual image. Transform methods
are applied I<in place> to the contained image data. Individual transformations
are "stacked" and then executed all at once. Note that at most one of each type
of transform is permitted per execute_transforms() call.

=head2 METHODS

=head3 $image = AppEngine::API::Images::Image->new($image_data)

Constructor.

=cut

sub new {
    my ($class, $image_data) = @_;
    return bless {
        image_data => $image_data,
        image_encoding => images_get_encoding($image_data),
        transforms => []
        transform_map => {}
    }, $class;
}

=pod

=head3 $image->resize($width, $height)

=over

=item $width

The desired width, as a number of pixels. Must be an int or long.

=item $height

The desired height, as a number of pixels. Must be an int or long.

=back

=cut

sub resize {
    my ($self, $width, $height) = @_;
    die "resize transform already applied."
        if exists $self->{transform_map}{resize};
    $width ||= 0;
    $height ||= 0;
    die "Width/height must be integers between 0 and 4000."
        unless ($width=~/^\d+$/) && ($height=~/^\d+$/) &&
            ($width <= 4000) && ($height <= 4000);

    die "At least one of width/height must be non-zero."
        unless $width || $height;
            

    my $transform = AppEngine::Service::Images::Transform->new();
    $transform->set_width($width);
    $transform->set_height($height);
    push @{$self->{transforms}}, $transform;
    $self->{transform_map}{resize} = 1;
    return $self;    
}

=pod

=head3 $image->crop($left_x, $top_y, $right_x, $bottom_y)

Crops an image to a given bounding box. The method returns the transformed image in the same format.

The left, top, right and bottom of the bounding box are specified as proportional distances. The coordinates of the bounding box are determined as left_x * width, top_y * height, right_x * width and bottom_y * height. This allows you to specify the bounding box independently of the final width and height of the image, which may change simultaneously with a resize action.

=cut

sub _validate_crop_arg {
    my ($val, $valname) = @_;
    
    die "arg '$valname' must be of type 'float'."
        unless $val=~/^\d+(?:\.\d+)?$/;

    die "arg '$valname' must be between 0.0 and 1.0 (inclusive)"
        unless (0 <= $val) && ($val <= 1.0);
}

sub crop {
    my ($self, $left_x, $top_y, $right_x, $bottom_y) = @_;
    die "crop transform already applied."
        if exists $self->{transform_map}{crop};

    _validate_crop_arg($left_x, 'left_x');
    _validate_crop_arg($top_y, 'top_y');
    _validate_crop_arg($right_x, 'right_x');
    _validate_crop_arg($bottom_y, 'bottom_y');

    die "left_x must be less than right_x"
        if ($left_x >= $right_x);
    die "top_y must be less than bottom_y"
        if ($top_y >= $bottom_y);

    my $transform = AppEngine::Service::Images::Transform->new();
    $transform->set_crop_left_x($left_x);
    $transform->set_crop_top_y($top_y);
    $transform->set_crop_right_x($right_x);
    $transform->set_crop_bottom_y($bottom_y);
    push @{$self->{transforms}}, $transform;
    $self->{transform_map}{crop} = 1;
    return $self;
}

=pod

=head3 $image->rotate($degrees)

Rotates an image. The amount of rotation must be a multiple of 90 degrees.

Rotation is performed clockwise. A 90 degree turn rotates the image so that the edge that was the top becomes the right edge.

=cut

sub rotate {
    my ($self, $degrees) = @_;
    die "rotate transform already applied."
        if exists $self->{transform_map}{rotate};

    die "Degrees must be integers."
        unless $degrees=~/^\d+$/;

    die "degrees argument must be multiple of 90."
        if $degrees % 90;

    $degrees = $degrees % 360

    my $transform = AppEngine::Service::Images::Transform->new();
    $transform->set_rotate($degrees);

    push @{$self->{transforms}}, $transform;
    $self->{transform_map}{rotate} = 1;
    return $self;
}

=pod

=head3 $image->horizontal_flip()

Flips an image horizontally. The edge that was the left becomes the right edge, and vice versa. 

=cut

sub horizontal_flip {
    my $self = shift;
    die "horizontal_flip transform already applied."
        if exists $self->{transform_map}{horizontal_flip};

    my $transform = AppEngine::Service::Images::Transform->new();
    $transform->set_horizontal_flip(TRUE);

    push @{$self->{transforms}}, $transform;
    $self->{transform_map}{horizontal_flip} = 1;
    return $self;
}

=pod

=head3 $image->vertical_flip()

Flips an image vertically. The edge that was the top becomes the bottom edge, and vice versa. 

=cut

sub vertical_flip {
    my $self = shift;
    die "vertical_flip transform already applied."
        if exists $self->{transform_map}{vertical_flip};
    my $transform = AppEngine::Service::Images::Transform->new();
    $transform->set_vertical_flip(TRUE);

    push @{$self->{transforms}}, $transform;
    $self->{transform_map}{vertical_flip} = 1;
    return $self;
}

=pod

=head3 $image->im_feeling_lucky()

Adjusts the contrast and color levels of an image according to an algorithm for improving photographs. This is similar to the "I'm Feeling Lucky" feature of Google Picasa. The method returns the transformed image in the same format.

=cut

sub im_feeling_lucky {
    my $self = shift;
    die "im_feeling_lucky transform already applied."
        if exists $self->{transform_map}{im_feeling_lucky};
    my $transform = AppEngine::Service::Images::Transform->new();
    $transform->set_autolevels(TRUE);

    push @{$self->{transforms}}, $transform;
    $self->{transform_map}{im_feeling_lucky} = 1;
    return $self;
}

=pod

=head3 $new_image = $image->execute_transforms($output_encoding)

Executes all transforms set for the Image instance by the above methods, and 
returns the result as new image data. The transform "stack" is cleared after
this call, and the contained image data is replaced by the transformed image
data.

=cut

#
#    the other operations are stacked and then applied all at once
#
sub execute_transforms {
    my ($self, $output_encoding) = @_;
    $output_encoding ||= IMAGES_PNG;
    
    die "Invalid output_encoding."
        unless ($output_encoding == IMAGES_PNG) || ($output_encoding == IMAGES_JPEG);
    
    die "Nothing to do."
        unless scalar @{$self->{transforms});
    
    my $request = AppEngine::Service::Images::ImagesTransformRequest->new();
    my $response = AppEngine::Service::Images::ImagesTransformResponse->new();

    $request->mutable_image()->set_content($self->{image_data});

    foreach (@{$self->{transforms}}) {
#
#    apply each transform
#
        $request->add_transform()->CopyFrom($_);
    }

    $request->mutable_output()->set_mime_type($output_encoding);

    _do_req("images", "Transform", $request, $response);

    $self->{image_data} = $response->image()->content();

    $self->transforms = [];
    $self->transform_map = {};
    return $self->{image_data};
}

sub _do_req {
    my ($service, $method, $proto, $res) = @_;
    my $res_bytes = eval {
        AppEngine::APIProxy::sync_call($service, $method, $proto);
    };
    if ($@) {
        print "<p><b>do_req error for svc=$service meth=$method</b>: error was: <pre>", Dumper($@), "</pre></p>";
        return undef;
    }
    my $escaped = $res_bytes;
    $escaped =~ s/([^\w])/"\\x" . sprintf("%02x", ord($1))/eg;
    print "<p>$service $method response was success: $escaped.</p>";
    my $parsed = eval { $res->parse_from_string($res_bytes); 1 };
    return 1 if $parsed;
    print "<p>Failed to parse_from_string: $@\n</p>";
    return 0;
}

1;

=pod

=head1 SEE ALSO

Refer to the Google AppEngine SDK document for detailed descriptions of the classes,
constructors, and public methods of the google.appengine.api.images components.

=head1 AUTHOR, COPYRIGHT, AND LICENSE

Copyright(C) 2008, Dean Arnold, USA.

Dean Arnold L</mailto:darnold@presicient.com>

Permission is granted to use, modify, and redistribute this software under the terms of
either

a) the GNU General Public License as published by the Free Software Foundation; either version 1, 
or (at your option) any later version, or

b) the "Artistic License".

Google(R) is a registered trademark of Google, Inc.

=cut

