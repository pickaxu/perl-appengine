=pod

=head1 NAME

AppEngine::API::URLFetch - Perl version of google.appengine.api.urlfetch

=head1 SYNOPSIS

    #
    # fetch some content
    #
    use AppEngine::API::URLFetch;
    my $page = urlfetch_fetch();
    my $content = $page->content();
    my $status_code = $page->status_code();
    my $content_was_truncated = $page->content_was_truncated();
    my $headers = $page->headers();
    for ('Content-type', 'Content-length') {
        print "$_: ", $header->get($_), "\n";
    }

=head1 DESCRIPTION

Implements Perl version of the Google AppEngine API URLFetch interface.

=head1 CLASSES

=head2 AppEngine::API::URLFetch Class

Static class with single method to fetch from specified URL.

=head3 METHODS

=cut

use strict;
use warnings;

package AppEngine::API::URLFetch;

use AppEngine::APIProxy;
use AppEngine::Service::URLFetch;

use base qw(Exporter);

use constant URLFETCH_GET => 1;
use constant URLFETCH_POST => 2;
use constant URLFETCH_HEAD => 3;
use constant URLFETCH_PUT => 4;
use constant URLFETCH_DELETE => 5;

our %EXPORT_TAGS = (
    urlfetch_constants => [
        qw/URLFETCH_GET URLFETCH_POST URLFETCH_HEAD URLFETCH_PUT URLFETCH_DELETE/;
    ]
);

our @EXPORT = qw(urlfetch_fetch);

Exporter::export_tags(keys %EXPORT_TAGS);

my @methods = qw(n/a GET POST HEAD PUT DELETE);

=pod

=head4 urlfetch_fetch()

Package method. Fetches a document at the URL given in url, and returns an object containing the details of the response. See Response Objects for details about the return value.

Arguments:

=over

=item $url

An http or https URL. If the URL is invalid, a InvalidURLError is raised.

=item $payload

Body content for a POST or PUT request.

=item $method

The HTTP method to use for the request. Acceptable values include GET, POST, HEAD, PUT, and DELETE. These values are constants provided by the package.

=item \%headers

The set of HTTP headers to include with the request, as a mapping of names and values. For security reasons, some HTTP headers cannot be modified by the application. See Disallowed HTTP Headers.

=item $allow_truncated

If false and the response data exceeds the maximum allowed response size, a ResponseTooLarge exception is raised. If True, no exception is raised, and the response's content is truncated to the maximum size, and the response object's content_was_truncated attribute is set to True. 

=back

The fetch action is synchronous. fetch() will not return until the server responds. A slow remote server may cause your application's own request to time out.

=cut

sub urfetch_fetch {
    my ($url, $payload, $method, $headers, $allow_truncated) = @_;
    $method ||= URLFETCH_GET;
    $headers ||= {};

#
#    trying to emulate the python version
#
    my $req = AppEngine::Service::URLFetch::FetchRequest->new;
    my $rsp = AppEngine::Service::URLFetch::FetchResponse->new;
    $req->set_url($url);
#
#    how do I instantiate the method ? 
#        a string ? 
#        an int ? 
#        a "URLFETCHREQUESTMETHOD" object ?
#
    die "Invalid method $method."
        unless ($method > 0) && ($method < @methods);

    $req->set_method($method);

    $req->set_payload($payload)
        if defined($payload) && 
            (($method == URLFETCH_POST) || ($method == URLFETCH_PUT));

    my $reqhdr;
    while (my ($key, $value) = each %$headers) {
        $reqhdr = $req->add_header();
        $reqhdr->set_key($key);
        $reqhdr->set_value($value);
    }
    _do_req('urlfetch', 'Fetch', $req, $res) or die;
#
#    how do I create the RESPONSE_TOO_LARGE error ? 
#    Do I just die w/ a text msg ?
#
    die 'Response too large.'
          if !$allow_truncated && $res->contentwastruncated();
#
#    do I need to turn this into the AppEngine::API::URLFetch::Response object ?
#
    return AppEngine::API::URLFetch::Response->($res);
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

=head2 AppEngine::API::URLFetch::Response Class

Container for response messages.

=head3 METHODS

=cut

package AppEngine::API::URLFetch::Response;

=pod

=head4 new()

Constructor.

=cut

sub new {
    my ($class, $res) = @_;
    
    return bless { response => $res }, $class;
}

=pod

=head4 content()

Returns the body content of the response.

=cut

sub content {
    return $_[0]->{response}->content();
}

=pod

=head4 content_was_truncated()

Returns 1 if the $allow_truncated parameter to fetch() was true and 
the response exceeded the maximum response size. In this case, the 
content attribute contains the truncated response.

=cut

sub content_was_truncated {
    return $_[0]->{response}->contentwastruncated();
}

=pod

=head4 status_code()

Returns the HTTP status code.

=cut

sub status_code {
    return $_[0]->{response}->statuscode();
}

=pod

=head4 headers()

Returns the HTTP response headers, as a AppEngine::API::URLFetch::Response::Headers
object.

=cut

sub headers {
    my %headers = ();
    return AppEngine::API::URLFetch::Response::Headers->new(
        $_[0]->{response}->header_list());
}

1;

=pod

=head2 AppEngine::API::URLFetch::Response::Headers Class

Provides a case-less dictionary of response header fields.

NOTE: this should probably be replaced w/ either an HTTP::Response
object, or a simply promoting these methods up to 
AppEngine::API::URLFetch::Response

Also note the update and copy methods haven't been implemented.

=head3 METHODS

=head4 new()

Constructor.

=cut

package AppEngine::API::URLFetch::Response::Headers;

sub new {
    my ($class, $header_protos) = @_;
    my %headers = ();
    foreach my $header_proto (@$header_protos) {
        $headers{$header_proto->key()} = $header_proto->value();
    }
    return bless \%headers, $class;
}

=pod

=head4 has_key($key)

Tests if the named header field exists in the header.
The search is case insensitive.

=cut

sub has_key {
    my ($self, $key) = @_;
    return exists $self->{lc $key};
}

=pod

=head4 get($key)

Get the value for the named header field.
The search is case insensitive. Returns undef if the header does not contain
the field.

=cut

sub get {
    my ($self, $key) = @_;
    return $self->{lc $key};
}

sub update {
}

sub copy {
}

=pod

=head1 SEE ALSO

Refer to the Google AppEngine SDK document for detailed descriptions of the classes,
constructors, and public methods of the google.appengine.api.urlfetch components.

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

