use strict;
use ExtUtils::MakeMaker;
WriteMakefile( 'NAME' => 'AppEngine::Server',
               'VERSION_FROM' => 'server.pl',
               'PREREQ_PM'              => {
                   'IPC::Run' => 0,
                   'HTTP::Server::Simple' => 0,
                                           } );

