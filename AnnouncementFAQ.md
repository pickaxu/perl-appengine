# Announcement FAQ #

## Why is this just a 20% project and not an official App Engine thing?  Or why not just do this internally? ##

The App Engine team (and Google as a whole) doesn't have Perl expertise, and the handful of Perl enthusiasts here who want to see this happen are also spread pretty thin.  We figure we could use any potential help we could get.  The Perl Googlers can work on the closed-source bits that require integration with App Engine, and the non-Google Perl hackers can work on the open source bits with us.

## So if this gets done, Google will ship Perl support? ##

No, the App Engine team can't make any promises.  They're just giving us (some Google Perl hackers) permission to work on this out in the open.  They do want to see more languages on App Engine, though, and they're willing to help us a little, time permitting.

## So what's in it for me if I hack on this? ##

Nothing, for sure.  But maybe you should want to follow the project from the sidelines.  Or maybe you want to hack on a fun project. Or maybe you're a web host and want to flesh this out all the way to offer Perl support to your customers.

## What about $OTHER\_LANGUAGE? ##

This is really two questions.  See the following:

## Will Google ship $OTHER\_LANGUAGE? ##

I both have no clue and don't speak for the App Engine team.  Sorry.  They have publicly stated their intention to support more languages, though.

The GAE might be working on other languages internally, or they might do this with community-style development for other languages.  No clue.

## Would this project and its proposed App Engine clone help $OTHER\_LANGUAGE? ##

If you go make a hardened Ruby or TCL or Erlang or something, and add Protocol Buffer support, there's no reason you couldn't reuse the same App Engine Server clone that the Perl community develops.  Then you could give that to your favorite ISP or Webhost and they could offer an App Engine-like environment for your favorite language.  Note that this has nothing to do with whether Google would support your favorite language.  See previous question.

## When will this be done? ##

Sorry, we have no schedule.  It's a fun 20% side project.  Things are always more fun (and move quicker) with more people, though, so we'd love more participation.