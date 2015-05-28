# Goals #

The goal of the [Perl-AppEngine](PerlAppEngine.md) project is
  * to get Perl implemented on [Google App Engine](http://code.google.com/appengine/docs/whatisgoogleappengine.html)

# Get Involved #
  * Anyone who is interested in following the discussion should sign up on the mailing lists.
    * Please sign up on the [Perl-AppEngine mailing list](http://groups.google.com/group/perl-appengine)
    * Please also sign up on the more general [Cloud Perl mailing list](http://groups.google.com/group/cloud-perl), regarding anything having to do with [Cloud Computing in Perl](http://code.google.com/p/cloud-perl).
  * Start discussing your ideas of how to move this project forward.
    * Ideas can be floated on the mailing list. However, to make meaningful progress on an idea, it should be documented on the wiki. Discussion on the mailing list will be centered around updating those documented ideas.
    * When ideas mature, they should definitely be documented on the wiki on this project site.

# Getting Started with the Code #

  * GettingStarted - describes how to check out the code and get started

# Project Status #

  * 2010-10-12 - SEEKING DEVELOPERS/CHAMPIONS. After a blip of activity last year, the project is again stalled. When three people with a desire to reactivate it appear, it can move out of dormant state again.
  * 2009-07-01 - The project is live again. We are in a code sprint in July to get it functional. (Of course, it may take longer than a month, but the mailing list is waking up and the developers are active.)
  * 2009-05-28 - [Status from David Sansome](http://groups.google.com/group/perl-appengine/msg/bc1394c379894bd8) prior to a proposed July 2009 code sprint
  * 2008-07-26 - [PerlAppEngineProgress200807](PerlAppEngineProgress200807.md) reported by Brad after OSCON 2008
  * 2008-07-22 - Some Googlers are [now working on this project too](http://brad.livejournal.com/2388824.html)
  * 2008-07-22 - The related project [Sys::Protect](http://code.google.com/p/sys-protect/) has started.
  * 2008-06-20 - This project is just starting up. Help us get the word out.

# Active Developers #
i.e. People involved in writing doc, writing test cases, or writing code.

  * SA - Stephen Adkins (spadkins)
  * BF - Brad Fitzpatrick (brad) - Google employee, Protobuf-Perl
  * AB - Artur Bergman (abergman) - Perl Core, Sys::Protect
  * JL - Jonathan Leto (jaleto) - Sys::Protect
  * CK - Chia-liang Kao (clkao) - Sys::Protect
  * RU - Reini Urban (reini.urban) - Sys::Protect
  * YK - Yuval Kogman (nothingmuch) - Catalyst
  * JR - Jon Rockway (jon) - Catalyst
  * DA - Dean Arnold (renodino) - porting Google App Engine API's

# Components #

  * [sys-protect](http://code.google.com/p/sys-protect/) - Create a protected/hardened/restricted Perl language runtime where Perl opcodes which would not be allowed in the Google compute farm are also not allowed
  * [protobuf-perl](http://code.google.com/p/protobuf-perl/) - Enable the serialization of API input and output arguments according to the "protocol buffers" standard, which is in use at Google. Arguments encoded in protocol buffers can be passed through an API to invoke services provided by Google.
  * [perl-appengine](http://code.google.com/p/perl-appengine/) - The dev kit for Perl applications which will run in the Google compute farm.

# Background #

  * Perl is not currently supported by Google App Engine ([only Python](http://code.google.com/appengine/docs/whatisgoogleappengine.html#The_Application_Environment)).
  * Google wants to (eventually) support other languages on App Engine.
    * _"[Although Python is currently the only language supported by Google App Engine, we look forward to supporting more languages in the future.](http://code.google.com/appengine/docs/whatisgoogleappengine.html#The_Application_Environment)"_
  * Google knows that there is [a significant community](http://code.google.com/p/googleappengine/issues/list) that would like Perl to be supported on App Engine (including a variety of Google employees, some of which I know).
    * If you would like to communicate your support for Perl on App Engine to Google, go to the [issues list](http://code.google.com/p/googleappengine/issues/list) and click the star next to "[Issue 34](https://code.google.com/p/perl-appengine/issues/detail?id=34): Add Perl Support". (You must logged in to Google in order to see the star and select it.)
    * NOTE: Do **not** post a general message to the list. Simply click on the star.
  * There are a variety of PerlAppEngineDiscussions around the web.
  * Support for Perl on App Engine will require modifications to the Perl language itself, a task which the Perl community would most likely need to get involved in. (see the [Language discussion](http://code.google.com/appengine/kb/general.html#language) under General Questions)
  * Support for Perl on App Engine will obviously never occur before the Google App Engine team gets involved.
  * The Google App Engine team is currently very busy with things besides Perl support.
  * A variety of overtures have been made to the App Engine team to organize the community support to do the work. ([an example](http://code.google.com/p/googleappengine/issues/detail?id=34#c436))
  * Neither Google nor the Google App Engine Team initiated this project. This is a community-sponsored project to do all of the work necessary to make it easy for the Google App Engine team to embrace and support Perl.  **Edit**:  some Googlers have now joined but it's still not a Google-official project.
  * Because there is [no guarantee](AnnouncementFAQ.md) that Google will pick up on the assistance that we are offering, another project has been created called [Cloud Perl](http://code.google.com/p/cloud-perl). This other project is devoted to the use of Perl in all kinds of cloud computing environments.

# Links #
ApiProxy PerlAppEngine PerlAppEngineDiscussions PerlAppEngineDesign GettingStarted