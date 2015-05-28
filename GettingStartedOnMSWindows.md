# Introduction #

First read the GettingStarted page for appropriate background information.

# Installation of Tools #

## Strawberry Perl ##

I used Strawberry Perl rather than Active Perl because it includes a compiler.
If you don't have Perl for Windows, get it here and install it. (It is free of charge.)

  * http://strawberryperl.com/
  * Download the Windows installer file to some location, then run it to install.

See also

  * http://win32.perl.org/wiki/index.php?title=Strawberry_Perl

The rest of this document will assume that you install it in C:\strawberry, the default location.

NOTE: If you already had Active State Perl installed, then C:\Perl\bin (Active State) might be before C:\strawberry\perl\bin in the PATH. If so, go to Control Panel->System->Advanced->Environment Variables->System Variables->Path and remove "C:\Perl\bin".

## Python 2.5 ##

If you don't have Python 2.5 installed, get it here.

  * http://www.python.org/

Download the Windows installer file to some location, then run it to install.
The rest of this document will assume you have TortoiseSVN.

## Subversion ##

If you don't have a Subversion client, get the command line client subversion tools here.

  * http://www.collab.net/downloads/subversion/

You need to register for an account at CollabNet in order to download the software,
but registration is free.

Download the Windows installer file to some location, then run it to install.

# Installing Required Perl Modules from CPAN #

Here's how to get started.
I had to install the following modules and their dependencies on my system.
(You may have to install more.)

First, go to the Windows Command shell.

```
   perl -MCPAN -e shell
   cpan> install Net::Server
   cpan> install namespace::clean
   cpan> install Moose
   cpan> install Moose::Policy
   cpan> exit

   perl -MCPAN -e shell
   cpan> install IPC::Run
   cpan> force install IPC::Run
   cpan> install HTTP::Server::Simple
   cpan> exit

   cd \strawberry\cpan\build
   dir
   cd IPC-Run-0.80-nUzol5
   dmake install
   cd ..
   dir
   cd HTTP-Server-Simple-0.34-OkyRHT
   dmake install
   cd ..
```

Notes:
  * The first set of installs should go cleanly
  * When installing Moose, you will be prompted to install lots of dependencies. Go ahead and install them. However, if you are given a choice whether to install the optional module Class::C3::XS, say "no". If it gets installed, you will have to uninstall it.
  * I was not given a chance to avoid installing Class::C3::XS, but it appears not to have been installed, so I didn't have to uninstall it.
  * The test for IPC::Run hung up and then failed on Windows. I used "force" to get it to install. If that doesn't work for you, do the commands under the "build" directory as described.
  * The test for HTTP::Server::Simple hung up forever on Windows. I had to kill it. I tried using "force" but it did no good. I resorted to using the commands under the "build" directory as described.
  * The CPAN shell downloads and unpacks the distributions under C:\strawberry\cpan\build. However, the directory names have six random characters at the end to make them unique. Your directory names will not be the same as I show here. Do the "dir" to find out what your directory names are, and do the "dmake install" in the appropriate directory.

# Installing perl-appengine Software #

Go to the Windows Command shell.

```
   cd \strawberry\perl
   mkdir src
   cd src
   svn checkout http://sys-protect.googlecode.com/svn/trunk/     sys-protect
   svn checkout http://protobuf-perl.googlecode.com/svn/trunk/   protobuf-perl
   svn checkout http://perl-appengine.googlecode.com/svn/trunk/  perl-appengine
```

NOTE: I actually had a problem with this. Both the command line subversion command
(svn) and Tortoise SVN gave me the same problem. The non-anonymous checkout works
fine on Windows (using https) and the same command works on Linux. Someone, please
help.

```
   C:\strawberry\perl\src>svn checkout http://perl-appengine.googlecode.com/svn/trunk/  perl-appengine
   svn: PROPFIND of '/svn/trunk': 200 OK (http://perl-appengine.googlecode.com)
```

Then do the initial compilation. (Do this once.)
Note: These do not need to be installed via "make install" as the
perl-appengine dev kit includes relative paths to the appropriate directories.

```
   cd sys-protect
   perl Makefile.PL
   dmake
```

Then do the following to update and compile. (Do this regularly to
keep up to date.)

```
   cd \strawberry\perl\src\sys-protect
   svn update
   perl Makefile.PL
   dmake

   cd \strawberry\perl\src\protobuf-perl
   svn update

   cd \strawberry\perl\src\perl-appengine
   svn update
```

# Running the Development Server #

The code currently checked in to the perl-appengine subversion repository is
targeted to be the development kit.

First you have to fire up the Python version of the development server along
running an API proxy application.  In a separate Windows Command window,
type the following.

```
    cd \strawberry\perl\src\perl-appengine
    python_sdk_partial\dev_appserver.py apiproxy_python
```

To run one of the demos, choose a demo such as "demos/guestbook".
Then type the following.

```
   cd \strawberry\perl\src\perl-appengine
   dev_appserver.pl demos/guestbook
```

The server output is something like the following.

```
 2008/07/28-22:52:38 AppEngine::Server::NetServer0 (type Net::Server::Fork) starting! pid(14736)
 Binding to TCP port 9000 on host *
 Group Not Defined.  Defaulting to EGID '205 3000 217 10 205'
 User Not Defined.  Defaulting to EUID '102'
```

Then go to Firefox (or your browser of choice) to access the test page at

```
   http://localhost:9000
```