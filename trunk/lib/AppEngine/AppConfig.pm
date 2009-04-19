package AppEngine::AppConfig;

use strict;
use warnings;

use Carp;
use File::Spec::Functions qw(catfile canonpath);
use Readonly;
use YAML;

# Taken from google.appengine.api.appinfo
Readonly my $URL_REGEX   => qr/^(?!\^)\/|\.|(\(.).*(?!\$).$/;
Readonly my $FILES_REGEX => qr/^(?!\^).*(?!\$).$/;

sub new {
    my ($pkg, $filename) = @_;

    my $self = {
        filename => $filename,
        mtime    => undef,
    };
    bless $self, $pkg;

    # Load the file
    $self->_reload;

    return $self;
}

sub _reload {
    my $self = shift;
    my $filename = $self->{filename};

    my $mtime = (stat $filename)[9];

    if ($self->{mtime} && $self->{mtime} == $mtime) {
        # Config hasn't changed since it was last read
        return;
    }
    elsif ($self->{mtime}) {
        warn "Reloading $filename\n";
    }

    # Check the file still exists
    croak "$filename does not exist" unless -e $filename;

    # Reload the file
    my $config = YAML::LoadFile($filename);

    # Check required fields are present
    foreach my $element (qw(application version runtime api_version handlers)) {
        croak "$filename: missing required element '$element'"
            unless $config->{$element};
    }

    # TODO(davidsansome): More validation of runtime, api_version, etc.

    # Load handlers
    $self->{handlers} = [];

    foreach my $handler (@{$config->{handlers}}) {
        my $url = $handler->{url};
        croak "$filename: handler section must contain url element" unless $url;
        croak "$filename: invalid url element: $url"                unless $url =~ $URL_REGEX;

        croak "$filename: handler section does not contain one of: script, static_dir, static_files"
            unless exists $handler->{script} ||
                   exists $handler->{static_dir} ||
                   exists $handler->{static_files};

        # Compile the URL regex and store it for later
        my $end_anchor = (exists $handler->{static_dir} ? '' : '$');
        $handler->{url_re} = qr/^$url$end_anchor/;

        push @{$self->{handlers}}, $handler;
    }

    croak "$filename: no handler sections defined" unless @{$self->{handlers}};

    $self->{mtime} = $mtime;
}

sub handler_for_path {
    my ($self, $path) = @_;

    $self->_reload;

    foreach my $handler (@{$self->{handlers}}) {
        next unless $path =~ $handler->{url_re};
        my $match = $&;

        if (exists $handler->{static_dir}) {
            $path =~ s/^\Q$match//;
            return ('static', canonpath(catfile($handler->{static_dir}, $path)));
        }

        # Do the /1, /2, etc. substitution
        # Yeah, this is a bit nasty...
        my $file = $handler->{script} || $handler->{static_files};
        $file =~ s{/}{\\/}g;
        eval "\$path =~ s/^\$handler->{url}\$/$file/";

        if (exists $handler->{script}) {
            return ('script', canonpath($path));
        }
        elsif (exists $handler->{static_files}) {
            return ('static', canonpath($path));
        }
    }

    return;
}

