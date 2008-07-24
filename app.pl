#!/usr/bin/perl
use strict;
#
# This should eventually feel like a CGI (or FastCGI?) environment.
# same filedescriptors, etc.  Probably use another fd (3?) for the
# apiproxy interface for now, a socketpair to parent process or
# something.

open(my $apiproxy, "<&=3") or die "Failed to open apiproxy fd: $!";

#my $response = make_sync_call( $apiproxy, { foo => 'moose', 'hola' => 'orzorz' } );

#use YAML::Syck;

sub make_sync_call {
    my ($sock, $data) = @_;
    my $serialized = YAML::Syck::Dump($data);
    my $length = length $serialized;
    my $buf;
    syswrite($sock, pack('N', $length), 4);
    syswrite($sock, $serialized);

    sysread($sock, $buf, 4);
    $length = unpack('N', $buf);
    sysread($sock, $buf, $length);
    return YAML::Syck::Load($buf);
}

use CGI;

my $cgi = CGI->new;


print "<h1>Hello!</h1>You requested: $ENV{PATH_INFO}\n";


print "Welcome to 1995, the era of the great technology of CGI!\n";
warn "this is test from stderr";

print "<p>Your cgi parameters:</p>";
print "<ul>";
for ($cgi->param) {
    print "<li>$_: ".$cgi->param($_)."</li>";
}

print "</ul>";


syswrite($apiproxy, "Hello from app!\n");


my $apiproxy_response = <$apiproxy>;

print "<p>Apiproxy says: [$apiproxy_response]</p>\n";

my $rv = eval qq{unlink "/etc/passwd"};

print "The end.  unlink=$rv, error=$@\n";

print "yatta!!\n";


syswrite($apiproxy, "Hello from app again, we are at $ENV{PATH_INFO}!\n");

my $x = <$apiproxy>;

print "got ($x) back from apiproxy";

