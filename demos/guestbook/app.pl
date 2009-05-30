#!/usr/bin/perl
#
# This is the untrusted app, running in a hardened CGI environment.
#
# Guestbook app.
#

use strict;
use warnings;

use AppEngine::API::Datastore;
use AppEngine::API::Datastore::Entity;
use AppEngine::API::Datastore::Query;
use AppEngine::API::Users;
use AppEngine::APIProxy;
use CGI;
use Data::Dumper;

my $cgi = CGI->new;
print $cgi->header;

if ($ENV{REQUEST_METHOD} eq 'POST') {
    my $greeting = AppEngine::API::Datastore::Entity->new('Greeting');
    $greeting->{content} = $cgi->param('content');
    $greeting->{author} = users_get_current_user();

    AppEngine::API::Datastore::put($greeting);
}

print '<html><body>';

my $query = AppEngine::API::Datastore::Query->new('Greeting');
while (my $greeting = $query->fetch) {
    if ($greeting->{author}) {
        print '<b>' . $greeting->{author}->nickname . '</b> wrote:';
    } else {
        print 'An anonymous person wrote:';
    }
    # TODO(davidsansome): encode html entities
    print '<blockquote>', $greeting->{content}, '</blockquote>';
}

print '<form action="/" method="post">';
print '  <div><textarea name="content" rows="3" cols="60"></textarea></div>';
print '  <div><input type="submit" value="Sign Guestbook"></div>';
print '</form>';

if (users_get_current_user()) {
    print '<a href="' . users_create_logout_url('/') . '">Logout</a>';
} else {
    print '<a href="' . users_create_login_url('/') . '">Login</a>';
}

print '</body></html>';
