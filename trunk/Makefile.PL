use strict;
use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME' => 'AppEngine::Server',
    'VERSION_FROM' => 'lib/AppEngine/Server.pm',
    'PREREQ_PM'              => {
        'IPC::Run' => 0,
        'HTTP::Server::Simple' => 0,
        'LWP::UserAgent' => 0,
        'HTTP::Request::Common' => 0,
    },
    'test' => {TESTS => 't/*/*.t'},
);

