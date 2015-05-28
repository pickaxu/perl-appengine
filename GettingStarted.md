# Introduction #

The code for Perl App Engine is completely in its formative stages (pre-alpha)
and changing quickly.  We are trying to keep documentation up to date. Please
let us know if you find an error or discrepancy.

  * [Background](Background.md)
  * SoftwareExecutionFlow

# Status of this Documentation #

  * 2009-07-03 spadkins - I executed these instructions on my Ubuntu Linux laptop with Perl 5.8.8, and they worked. I was able to run the sample guestbook application.

# Installing Required Perl Modules from CPAN #

Here's how to get started.
I had to install the following modules and their dependencies on my system.
(You may have to install more.)

```
   su -   # become root
   perl -MCPAN -e shell
   cpan> install IPC::Run
   cpan> install HTTP::Server::Simple::CGI
   cpan> install Net::Server::Fork
   cpan> install namespace::clean
   cpan> install Readonly
   cpan> install Inline
   cpan> install Inline::C
   cpan> install Inline::Python
   cpan> install File::Type
   cpan> install YAML
   cpan> install Moose
   cpan> install Moose::Policy
   cpan> exit
   exit   # become a normal user again

NOTE: The following may not be necessary for Perl App-Engine, but it is necessary
      for the sample guestbook application.

   cpan> install MIME::Base64::URLSafe

NOTE: Before you install Moose (above), you might want to install the following modules.
      Some will be drawn in automatically by installing Moose.
      Others are useful in the Moose tests.

   cpan> install DateTime
   cpan> install DateTime::Calendar::Mayan
   cpan> install Regexp::Common
   cpan> install Locale::US
   cpan> install HTTP::Headers
   cpan> install Params::Coerce
   cpan> install URI
   cpan> install File::Temp
   cpan> install Test::Tester
   cpan> install Test::Output
   cpan> install IO::String
   cpan> install IO::File
   cpan> install Module::Refresh
   cpan> install Test::Deep
   cpan> install DBM::Deep
   cpan> install Declare::Constraints::Simple
   cpan> install Class::MOP

```

# Ensure Python is Installed and Up-to-Date #

The Perl App Engine development server builds on the Google App Engine development
kit written in Python. It proxies all Google-specific API's to the Python development
server.  Therefore, Python must be installed on your system and it must be at least
Python 2.5.  If you see this message, you need to upgrade Python.

```
   cd $HOME/src/perl-appengine/
   ./python_sdk_partial/dev_appserver.py apiproxy_python
   Error: Python 2.3 is not supported. Please use version 2.5 or greater.
   python -v
```

# Installing perl-appengine Software #

Then you check out the existing projects.
(I am assuming you will do this in a HOME directory on a Linux system.)

```
   cd $HOME/src
   svn checkout http://sys-protect.googlecode.com/svn/trunk/     sys-protect
   svn checkout http://protobuf-perl.googlecode.com/svn/trunk/   protobuf-perl
   svn checkout http://perl-appengine.googlecode.com/svn/trunk/  perl-appengine
```

Then do the initial compilation. (Do this once.)
Note: These do not need to be installed via "make install" as the
perl-appengine dev kit includes relative paths to the appropriate directories.

```
   cd $HOME/src/sys-protect
   perl Makefile.PL
   make

   cd $HOME/src/protobuf-perl/protobuf
   ./configure
   make

   cd $HOME/src/protobuf-perl/perl
   perl Makefile.PL
   make
```

Then do the following to update and compile. (Do this regularly to
keep up to date.)

```
   cd $HOME/src/sys-protect
   svn update
   perl Makefile.PL
   make

   cd $HOME/src/protobuf-perl
   svn update
   cd $HOME/src/protobuf-perl/perl
   make

   cd $HOME/src/perl-appengine
   svn update
   make
```

# Running the Development Server #

The code currently checked in to the perl-appengine subversion repository is
targeted to be the development kit.

To run one of the demos, choose a demo such as "demos/guestbook".
Then in a second terminal window, type the following.

```
   cd $HOME/src/perl-appengine
   dev_appserver.pl demos/guestbook
```

The server output is something like the following.

```
 2008/07/28-22:52:38 AppEngine::Server::NetServer0 (type Net::Server::Fork) starting! pid(14736)
 Binding to TCP port 9000 on host *
 Group Not Defined.  Defaulting to EGID '205 3000 217 10 205'
 User Not Defined.  Defaulting to EUID '102'
```

Then in another terminal window, go to lynx to access the test page.

```
   lynx localhost:9000
```

or view the application from a local web browser by browsing to http://localhost:9000.

Note: In the background, the Perl program has kicked off
the Python version of the development server
running an API proxy application.
It used to be required that you kick this off separately, but that has
been changed.