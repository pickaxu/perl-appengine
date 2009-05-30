=pod

=head1 NAME

AppEngine::API::Users - Perl version of google.appengine.api.users

=head1 SYNOPSIS

    #
    #    functional interfaces
    #
    use AppEngine::API::Users;

    users_create_login_url($dest_url);

    users_create_logout_url($dest_url);

    if (users_is_current_user_admin()) {
        print "Hey Mr. Admin!";
    }
    #
    #    OO interface
    #
    my $user = users_get_current_user()
    
    $nickname = $user->nickname();
    $address = $user->email();

=head1 DESCRIPTION

Implements the Perl version of the Google AppEngine Users API interface.

=head1 METHODS

=cut

use strict;
use warnings;

package AppEngine::API::Users;

use AppEngine::APIProxy;
use AppEngine::Service::Base;

use base qw(Exporter);

our @EXPORT = qw(
    users_create_login_url
    users_create_logout_url
    users_get_current_user
    users_is_current_user_admin
);

=pod

=head2 users_create_login_url(dest_url)

Returns a URL that, when visited, will prompt the user to sign in using a Google account, then redirect the user back to the URL given as dest_url. This URL is suitable for links, buttons and redirects.

dest_url can be full URL or a path relative to your application's domain.

=cut

sub users_create_login_url {
    my ($dest_url) = @_;
    my $req = AppEngine::Service::StringProto->new;
    my $resp = AppEngine::Service::StringProto->new;

    $req->set_value($dest_url);
    _do_req('user', 'CreateLoginURL', $req, $resp) or return undef;

    return $resp->value;
}

=pod

=head2 users_create_logout_url(dest_url)

Returns a URL that, when visited, will sign the user out, then redirect the user back to the URL given as dest_url. This URL is suitable for links, buttons and redirects.

dest_url can be full URL or a path relative to your application's domain.

=cut

sub users_create_logout_url {
    my ($dest_url) = @_;
    my $req = AppEngine::Service::StringProto->new;
    my $resp = AppEngine::Service::StringProto->new;

    $req->set_value($dest_url);
    _do_req('user', 'CreateLogoutURL', $req, $resp) or return undef;

    return $resp->value;
}

=pod

=head2 users_get_current_user()

Returns the User object for the current user (the user who made the request being processed) 
if the user is signed in, or None if the user is not signed in.

=cut

sub users_get_current_user {
    return AppEngine::API::Users::User->new;
}

=pod 

=head2 users_is_current_user_admin()

Returns True if the current user is signed in and is currently registered as an administrator of this application.

=cut

sub users_is_current_user_admin {
    return $ENV{USER_IS_ADMIN};
}

1;

package AppEngine::API::Users::User;

=pod

=head1 AppEngine::API::Users::User Class

Provides methods for managing an individual user.

=head2 METHODS

=head3 new($email, $auth_domain)

Constructor.

=cut

sub new {
    my ($class, $email, $auth_domain) = @_;

    $auth_domain = $ENV{AUTH_DOMAIN} unless defined $auth_domain;
    $email = $ENV{USER_EMAIL} unless defined $email;

    die 'User not found.' unless defined $email;

    return bless {
        email => $email,
        auth_domain => $auth_domain
    }, $class;
}

=pod

=head3 nickname()

Returns the "nickname" of the user, a displayable name. The ability for users to change their nickname has not yet been implemented, but an application can use this feature for displayable names now and benefit from it when the feature is implemented.

For a user that does not have a custom nickname, the nickname will be either the "name" portion of the user's email address if the address is in the same domain as the application, or the user's full email address otherwise.

=cut

sub nickname {
    my $self = shift;

    my $suffix = '@' . $self->{auth_domain};

    return ($self->{email} && $self->{auth_domain} && substr($self->{email}, - length($suffix)) eq $suffix)
        ? substr($self->{email}, 0, length($self->{email}) - length($suffix))
        : $self->{email};
}

=pod

=head3 email()

Returns the email address of the user. Applications should use nickname for displayable names.

=cut

sub email {
    return $_[0]->{email};
}

=pod

=head3 auth_domain()

Returns the authentication domain of the user. Applications should use nickname for displayable names.

=cut

sub auth_domain {
    return $_[0]->{auth_domain};
}

1;

=pod

=head1 SEE ALSO

Refer to the Google AppEngine SDK document for detailed descriptions of the classes,
constructors, and public methods of the google.appengine.api.users components.

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

