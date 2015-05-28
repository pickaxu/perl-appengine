# Introduction #

I normally use TortoiseSVN for Subversion on Windows.
However, I could not get anonymous checkout to work to code.google.com.

This page exists so that those who have better luck than I can document what
they did to make it work.

## Tortoise SVN ##

If you don't have a Subversion client, get TortoiseSVN here.

  * http://www.tortoisesvn.net/

Download the Windows installer file to some location, then run it to install.
The rest of this document will assume you have TortoiseSVN.

# Installing perl-appengine Software #

Go to the Windows Command shell.

```
   cd \strawberry\perl
   mkdir src
```

From Windows Explorer (My Computer), go to C:\strawberry\perl\src.

Right click in the "src" directory and select "SVN Checkout".
You are using TortoiseSVN to check out source code.
In the dialog box, enter

```
   URL of repository: http://sys-protect.googlecode.com/svn/trunk/
   Checkout directory: sys-protect
   Checkout Depth: Fully recursive
   HEAD Revision: [checked]
```

Push the [OK](OK.md) button. Then answer [Yes](Yes.md) the question of whether you would like
to create the "sys-protect" directory.

Do the same for the other two projects.

Right click in the "src" directory and select "SVN Checkout".
In the dialog box, enter

```
   URL of repository: http://protobuf-perl.googlecode.com/svn/trunk/
   Checkout directory: protobuf-perl
   Checkout Depth: Fully recursive
   HEAD Revision: [checked]
```

Push the [OK](OK.md) button. Then answer [Yes](Yes.md) the question of whether you would like
to create the "protobuf-perl" directory.

Right click in the "src" directory and select "SVN Checkout".
In the dialog box, enter

```
   URL of repository: http://perl-appengine.googlecode.com/svn/trunk/
   Checkout directory: perl-appengine
   Checkout Depth: Fully recursive
   HEAD Revision: [checked]
```

Push the [OK](OK.md) button. Then answer [Yes](Yes.md) the question of whether you would like
to create the "perl-appengine" directory.

## ERROR ON CHECKOUT ##

The above instructions worked for me if I used the "https" URL instead and
supplied a username and password. However, when I tried doing anonymous
checkouts (with "http") as described above, I always got the following error.

> Command: Checkout from http://sys-protect.googlecode.com/svn/trunk, revision HEAD, Fully recursive, Externals included
> Error: PROPFIND of '/svn/trunk': 200 OK (http://sys-protect.googlecode.com)
> Finished!:

Therefore, I am turning to the command-line subversion tools from subversion.tigris.org.

## Updating the Perl App Engine Software ##

Periodically, do the following to update and compile. (Do this regularly to
keep up to date as the software evolves.)

In Windows Explorer (My Computer), go into each of the three project directories
in order. Right click in the directory, choose "TortoiseSVN->Update to revision",
and click the [OK](OK.md) button. This will get the latest ("HEAD") software from the
subversion repository.

Then, if sys-protect has changed, you will need to compile it.

```
   cd \strawberry\perl\src\sys-protect
   perl Makefile.PL
   dmake
```