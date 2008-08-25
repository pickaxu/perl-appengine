=pod

=head1 NAME

AppEngine::API::Mail - Perl version of google.appengine.api.mail

=head1 SYNOPSIS

    #
    #    functional interface
    #
    use AppEngine::API::Mail;

    die 'Invalid address: ' . mail_invalid_email_reason($address, $field)
        unless mail_check_email_valid($address, $field);

    if (mail_is_email_valid($address)) {
        #
        # do something...
        #
    }
        
    mail_send_mail($sender, $to, $subject, $body, %extra_headers);

    mail_send_mail_to_admin($sender, $subject, $body, %extra_headers);
    #
    #    OO interface
    #
    use AppEngine::API::Mail::EmailMessage;
    
    my $msg = AppEngine::API::Mail::EmailMessage->new(%headers);
    
    $msg->initialize(%more_headers);
    
    $msg->send()
        if $msg->is_initialized();

    $msg->send()
        if $msg->check_initialized();

=head1 DESCRIPTION

Implements Perl version of the Google AppEngine API Mail interface.

=head1 METHODS

=cut

use strict;
use warnings;

package AppEngine::API::Mail;

use AppEngine::APIProxy;
use AppEngine::Service::Mail;

use base qw(Exporter);

@EXPORT = qw(
    check_email_valid
    invalid_email_reason
    is_email_valid
    send_mail
    send_mail_to_admins
);

=pod

=head2 mail_check_email_valid()

Checks that an email address is valid, and raises an InvalidEmailError exception if it is not. field is the name of the field containing the address, for use in the error message.

=cut

sub mail_check_email_valid {
    my ($email_address, $field) = @_;
}

=pod

=head2 mail_invalid_email_reason()

Returns a string description of why a given email address is invalid, or None if the address is valid. field is the name of the field containing the address, for use in the error message.

=cut

sub mail_invalid_email_reason {
    my ($email_address, $field) = @_;
}

=pod

=head2 mail_is_email_valid()

Returns True if email_address is a valid email address. This performs the same check as check_email_valid, but does not raise an exception.

=cut

sub mail_is_email_valid {
    my ($email_address) = @_;
}

=pod

=head2 mail_send_mail()

Creates and sends a single email message. sender, to, subject, and body are required fields of the message. Additional fields can be specified as keyword arguments. For the list of possible fields, Email Message Fields.

=cut

sub mail_send_mail {
    my $sender = shift;
    my $to = shift;
    my $subject = shift;
    my $body = shift;
    my %kw = @_;
}

=pod

=head2 mail_send_mail_to_admins()

Creates and sends a single email message addressed to all administrators of the application. sender, subject, and body are required fields of the message. Additional fields can be specified as keyword arguments. For the list of possible fields, Email Message Fields.

=cut

sub mail_send_mail_to_admins {
    my $sender = shift;
    my $subject = shift;
    my $body = shift;
    my %kw = @_;
}

1;

package AppEngine::API::Mail::EmailMessage;

=pod

=head1 AppEngine::API::Mail::EmailMessage Class

Provides OO interface for creating/sending email messages.

=head2 METHODS

=head3 new(%headers)

Constructor.

=cut

sub new {
    my $class = shift;
    my %kw = @_;
    
    return bless { %kw }, $class;
}

=pod

=head3 check_initialized()

Checks if the EmailMessage is properly initialized for sending. If the message is not properly initialized, the method raises an error that corresponds with the first problem it finds. Returns without raising an error if the message is ready to send.

=cut

sub check_initialized{
    my $self = shift;
}

=pod

=head3 initialize()

Sets fields of the email message using keyword arguments. It takes the same arguments as the EmailMessage constructor. 

=cut

sub initialize {
    my $self = shift;
    my %kw = @_;
}

=pod

=head3 is_initialized()

Returns True if the EmailMessage is properly initialized for sending. This performs the same checks as check_initialized(), but does not raise an error. 

=cut

sub is_initialized {
    my $self = shift;
}

=pod

=head3 send()

Sends the email message. 

=cut

sub send{
    my $self = shift;
}

1;

=pod

=head1 SEE ALSO

Refer to the Google AppEngine SDK document for detailed descriptions of the classes,
constructors, and public methods of the google.appengine.api.mail components.

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

