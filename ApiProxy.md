# The API Proxy #

The API proxy (or "apiproxy") is how you do restricted actions from Google App Engine.  For instance:  datastore access, URL fetch, memcache, etc.

The API proxy interface is via protocol buffers:   a message for a request and a message for the response.

See [this post](http://groups.google.com/group/google-appengine/browse_frm/thread/56167e89878e471f/54c175eb57075501#54c175eb57075501) for more details.

We'll need to get all the proto2 files first, not just the memcache one above.