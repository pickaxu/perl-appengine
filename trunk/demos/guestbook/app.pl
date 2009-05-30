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
use AppEngine::APIProxy;
use CGI;
use Data::Dumper;

my $cgi = CGI->new;
print $cgi->header;

if ($ENV{REQUEST_METHOD} eq 'POST') {
    my $greeting = AppEngine::API::Datastore::Entity->new('Greeting');
    $greeting->{content} = $cgi->param('content');

    AppEngine::API::Datastore::put($greeting);
}

print '<html><body>';

my $query = AppEngine::API::Datastore::Query->new('Greeting');
while (my $greeting = $query->fetch) {
    print 'An anonymous person wrote:';
    # TODO(davidsansome): encode html entities
    print '<blockquote>', $greeting->{content}, '</blockquote>';
}

print q(<form action="/" method="post">
          <div><textarea name="content" rows="3" cols="60"></textarea></div>
          <div><input type="submit" value="Sign Guestbook"></div>
        </form>
      </body>
    </html>
);
