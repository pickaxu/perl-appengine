# Development Kit Startup #

## python\_sdk\_partial/dev\_appserver.py apiproxy\_python ##

  * A part of the Python SDK for Google App Engine (i.e. python\_sdk\_partial) is included in the "perl-appengine" project
  * When you run the dev\_appserver.py, you are running the Python server that comes in the SDK, emulating the Google runtime environment for Python applications
  * Supplying the argument "apiproxy\_python" causes it to run an application written in Python which unpacks protocol-buffered requests for Google App Engine services and executes them in the Python environment.
  * This Python server answers to HTTP requests on port 8080.
  * The Perl development server is going to proxy all requests for services to the Python development server.

## dev\_appserver.pl demos/guestbook ##

  * When you run the Perl development server, the "dev\_appserver.pl" program

# Processing an HTTP Request #

  * When an HTTP request comes from a browser (in our case to localhost, port 9000),