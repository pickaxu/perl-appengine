# Introduction #

This is the body of an email sent by Brad Fitzpatrick after OSCON 2008.

# Progress #

Now that OSCON is over, and before I get back to work on Monday, let me give everybody here (111 people!) an overview of what we all got done on this project while at OSCON.

Terminology:
  * GAE -- Google App Engine
  * PAE -- Perl App Engine
  * Protos -- protocol buffer files
  * PAE SDK -- this whole project (a dev kit we give to people to test PAE apps)

## First off, the three repos we're hacking in: ##

1) http://code.google.com/p/perl-appengine/
> ... the main project, to provide a perl dev environment that feels like what it'd actually feel like on GAE.  The goal here is to provide a CGI (or future: FastCGI) environment in which people can start porting their apps while the other work goes in parallel.  This is where all the current focus is.  Status: see bottom of this email.

2) http://code.google.com/p/sys-protect/
> ... a Perl XS module which, once loaded, locks down Perl to have the same GAE restrictions as the Python sandbox.  Props to ABERGMAN++ for almost all the work on this module.   It does this by replacing the Perl opcodes and disabling dynamic loading of any future XS modules.  This is _not_ how things will be done in reality in production, but its goal is to make it feel the same as production will feel.   (We didn't want people to need to rebuild their main Perl interpreter just to test their apps on PAE).  Status:  pretty complete.  Artur is still working on overriding the open function to prevent opening new file descriptors for write/fork/pipe, at which point we'll be pretty happy with this module.  Wanted:  people beating the crap out of this, finding holes, and writing more tests (passing or failing tests).  Even though this won't be what's used in production, it'll form the basis of what's used in production.  Basically we'll compiler this into a real Perl, but also removing completely the opcodes we override.

3) http://code.google.com/p/protobuf-perl/
> ... the Perl support for Protocol Buffers, Google's serialization format.  This is the communications format for all privileged operations in GAE, so it's critical that we have good support.  Status:  I've checked in two subdirectories in this project.  See the README:

> http://protobuf-perl.googlecode.com/svn/trunk/
> http://protobuf-perl.googlecode.com/svn/trunk/README

> the notable part so far is perl\_generator.{cc,h}, which emit Perl descriptions of the .proto files from the C++ protoc compiler.  Once all the GAE service files are open sourced (currently just memcache), then we'll compiler them all to Perl and ship them with the PAE SDK above (the "perl-appengine" project).  Also, the PAE SDK will require the "Protobuf" CPAN module.  (which currently depends on Moose, as I experiment with it... I talked with a lot of Moose people at OSCON.  I'm still wavering on it, but I'm willing on giving it a shot.  If it's too heavy or slow or hard to install on different distros I'll go back to catching AUTOLOAD and replacing subs in symbol tables)


# Status/code overview of "perl-appengine": #

Let me give you a walk-through of the perl-appengine codebase....

http://perl-appengine.googlecode.com/svn/trunk/
> .. the root

http://perl-appengine.googlecode.com/svn/trunk/server.pl
> .. the PAE SDK server.  Listens on port 9000 currently hard-coded.  Runs your untrusted app in a Sys::Protect sandbox, in a CGI environment.  Thanks to CLKAO++ for his work at taking my experimental shell and making it provide a proper CGI environment.  Currently the server always runs the same CGI script, "app.pl".  I haven't done the whole "specify your directory and parse the app.yaml" thing which the Python SDK does.  Hackers welcome.  :-)

http://perl-appengine.googlecode.com/svn/trunk/app.pl
> .. the user CGI script which gets run in the hardened environment.  Shows off some features.  Notably, the APIProxy...

http://perl-appengine.googlecode.com/svn/trunk/APIProxy.pm
> .. if you want to do any privileged operation in your hardened CGI environment, you'll need to "use APIProxy" and use it to make "apiproxy requests" out to the container environment (in our case: server.pl).  In production this will be a trusted, closed-source XS module implemented in Google-specific ways.  In the PAE SDK it's implemented as writing requests to/from a file descriptor to our parent process (server.pl) which the parent process opened for us before it invoked us.  It's file descriptor #3, right past stdin/stdout/stderr.  But this is an implementation detail which you can't depend on.  The point is:  use APIProxy to do special operations.  The APIProxy currently works (but no async scatter/gather support yet), but is hard to use due to lack of Protocol Buffer support.  And also because the only GAE service proto file released so far is the memcache one.  I'll ask the GAE team about releasing the rest of them now that we need the.  They're cool with it... we just need to convert it from proto1 syntax to proto2 syntax and make sure there's nothing confidential in the comments.  (Don't worry -- we won't scrub the useful comments)

http://perl-appengine.googlecode.com/svn/trunk/apiproxy_python/
http://perl-appengine.googlecode.com/svn/trunk/run-apiproxy.sh
> .. the Perl APIProxy is implemented in terms of proxying to the Python GAE SDK.  so the apiproxy in PAE SDK is really two layers of proxying:  one from untrusted app to container, and them from Perl container to Python SDK.   Anyway, this directory is a Python GAE app which implements the proxy.  To run this, run "run-apiproxy.sh".  This needs to be running to run server.pl above.  It listens on port 8080.  In the future, server.pl will manage this subprocess transparently.  For now it's separate.

http://perl-appengine.googlecode.com/svn/trunk/python_sdk_partial/
> .. by necessity, I checked in the subset of the Python SDK necessary to run the Python APIProxy app.

http://perl-appengine.googlecode.com/svn/trunk/proto/
> .. where I'm checking in the GAE apiproxy service protos, as they're released.  Currently only the memcache service has been released.  We could reverse engineer them all from the Python SDK (the compiled _**pb2.py files), but I'd rather just wait and get the originals from the GAE team, complete with useful comments.**_

# Things you could hack on... #

I'm going to be working on protocol buffers, but here's other stuff I'd like help on:

**Update the wiki(s) with all this information.**

**FastCGI support in server.pl.**

**Make server.pl take a directory argument (add Getopt::Long) and parse the app.yaml file?  Or at least just run app.pl in the provided directory.**

**Make server.pl take a port argument, and automatically run apiproxy\_python as well on another provided port, as a child process.**

**Make your own app.pl and test POSTs.  We've only done GETs so far.  Also, try using CGI.pm and see that it works in the sandbox / CGI environment.**

**Since CLKAO switched to using HTTP::Server, we're now losing stderr from app.pl.  It was nice having it go to the real stderr for debugging.  In the future, server.pl should gobble up app.pl's stderr and log it (perhaps just to the console), but having it go nowhere is really hard for debugging right now.  Especially when opcodes are denied and we don't see the Perl\_die to stderr w/ which opcode/line/file was denied.**

**Beat up Sys::Protect and find holes, add code, add tests (either passing or failing tests)**

**Try to run your big fancy webapp as an app.pl in CGI environment.  See if it runs.  (if you can do without database access for now)**

**....**


In any case, just coordinate on the list with what you're working on, so we don't duplicate effort too much.

And let me know if you want commit access. Just sign the CLA first and give me your Google email address:  (no need to sign/fax:  electronic form at bottom)
> http://code.google.com/legal/individual-cla-v1.0.html

Hopefully this update was understandable.  (It's hard when the audience has a very wide spectrum of background knowledge about all this stuff...)  Let me know if you have any questions.

- Brad