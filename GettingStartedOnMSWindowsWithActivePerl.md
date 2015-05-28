# Introduction #

First read the GettingStartedWithMSWindows page for the recommended way to get going on MS Windows with Strawberry Perl.

**IMPORTANT**: I was not able to get Moose and Sys::Protect installed with ActivePerl. This page exists so that other people can enhance it with their more successful experiences.

# Installation of Tools #

## Active Perl ##

If you don't have Perl for Windows, get it here and install it. (It is free of charge.)

  * http://www.activestate.com/store/activeperl/
  * Click on "Download", skip the Contact Details and push "Continue"
  * I would choose "Download ActivePerl 5.10.0.1003 for Windows (x86): MSI - 15.4MB" for my Windows XP laptop
  * However, I have Perl 5.8.8 installed and I didn't actually bother to upgrade.
  * Download the Windows installer file to some location, then run it to install.

See also

  * http://www.activestate.com/Products/activeperl/index.mhtml
  * http://www.activestate.com/Products/languages.mhtml
  * http://www.activestate.com/index.mhtml

and the documentation ...

  * http://aspn.activestate.com/ASPN/docs/ASPNTOC-APERL_5.10/

The rest of this document will assume that you install it in C:\Perl, the default location.

## nmake ##

Install nmake.exe from Microsoft.

The method of installing software which is most native to Perl is through the CPAN shell. In order for this to work, you need a "make" tool. Microsoft provides "nmake" for this purpose.

I found reference to "nmake" on Microsoft's site here.

  * http://support.microsoft.com/default.aspx?scid=kb;en-us;132084

Then I downloaded the most recent version (a self-extracting archive) here.

  * http://download.microsoft.com/download/vc15/patch/1.52/w95/en-us/nmake15.exe

After saving it on your disk, run the program to extract three files.

> README.TXT
> NMAKE.EXE
> NMAKE.ERR

Move these files to C:\Perl\bin. This should put them in the PATH so that they will be found by the CPAN shell.

# Installing Required Perl Modules from CPAN #

Here's how to get started.
I had to install the following modules and their dependencies on my system.

First, go the Windows Command shell. Install what you can through PPM.

```
   ppm-shell
   ppm> install IPC::Run
   ppm> install Net::Server
   ppm> install namespace::clean
   ppm> exit
```

The remaining modules still need to be installed with the CPAN shell.

```
   perl -MCPAN -e shell
   cpan> install HTTP::Server::Simple::CGI
   cpan> install Moose
   cpan> install Moose::Policy
   cpan> exit
```

However, they fail without a compiler. If anyone has a different experience,
please update this page.