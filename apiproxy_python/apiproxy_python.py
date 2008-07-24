#!/usr/bin/env python

import cgi
import wsgiref.handlers

from google.appengine.ext import webapp
from google.appengine.api import apiproxy_stub_map

from google.appengine.api.memcache import memcache_service_pb

MemcacheSetResponse = memcache_service_pb.MemcacheSetResponse
MemcacheSetRequest = memcache_service_pb.MemcacheSetRequest
MemcacheGetResponse = memcache_service_pb.MemcacheGetResponse
MemcacheGetRequest = memcache_service_pb.MemcacheGetRequest
MemcacheDeleteResponse = memcache_service_pb.MemcacheDeleteResponse
MemcacheDeleteRequest = memcache_service_pb.MemcacheDeleteRequest
MemcacheIncrementResponse = memcache_service_pb.MemcacheIncrementResponse
MemcacheIncrementRequest = memcache_service_pb.MemcacheIncrementRequest
MemcacheFlushResponse = memcache_service_pb.MemcacheFlushResponse
MemcacheFlushRequest = memcache_service_pb.MemcacheFlushRequest
MemcacheStatsRequest = memcache_service_pb.MemcacheStatsRequest
MemcacheStatsResponse = memcache_service_pb.MemcacheStatsResponse


class MainPage(webapp.RequestHandler):
  def get(self):
    self.response.out.write('<html><body>')

    self.response.out.write("""
          API proxy interface;
          <form action="/do_req" method="post">
            <div>service: <input name='service' size='20'/></div>
            <div>method: <input name='method' size='20'/></div>
            <div>request:<br/><textarea name="request" rows="20" cols="60"></textarea></div>
            <div><input type="submit" value="submit"></div>
          </form>
        </body>
      </html>""")


class DoRequest(webapp.RequestHandler):
  def post(self):
    service = self.request.get('service')
    method = self.request.get('method')
    request = self.request.get('request')
    apiproxy = apiproxy_stub_map.apiproxy
    stub = apiproxy.GetStub(service)
    if not stub:
      self.response.out.write('<html><body>bogus service</body></html>')
      return

    if method == 'Get':
      response = MemcacheGetResponse()
      request = MemcacheGetRequest();
    elif method == 'Set':
      response = MemcacheSetResponse()
      request = MemcacheSetRequest();
    else:
      raise "Unknown method"

    stub.MakeSyncCall(service, method, 

    self.response.out.write('<html><body>' + request + '</body></html>')


application = webapp.WSGIApplication([
  ('/', MainPage),
  ('/do_req', DoRequest)
], debug=True)


def main():
  wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
  main()
