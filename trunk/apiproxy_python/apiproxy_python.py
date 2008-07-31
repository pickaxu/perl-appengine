#!/usr/bin/env python

import cgi
import wsgiref.handlers
import logging

from google.appengine.ext import webapp
from google.appengine.api import apiproxy_stub_map

from google.appengine.api.memcache import memcache_service_pb
from google.appengine.api.images import images_service_pb
from google.appengine.api import mail_service_pb
from google.appengine.api import urlfetch_service_pb
from google.appengine.api import user_service_pb
from google.appengine.api.datastore import datastore_pb
from google.appengine.api.datastore import entity_pb
from google.appengine.api import api_base_pb

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
            <div>service: <select name='service'>
                 <option></option>
                 <option>datastore_v3</option>
                 <option>images</option>
                 <option>mail</option>
                 <option>memcache</option>
                 <option>urlfetch</option>
                 <option>user</option>
              </select>
            </div>
            <div>method: <input name='method' size='20'/></div>
            <div>request:<br/><textarea name="request" rows="20" cols="60"></textarea></div>
            <div><input type="submit" value="submit"></div>
          </form>
        </body>
      </html>""")


class DoRequest(webapp.RequestHandler):
  def post(self):
    # This is required so we get binary data, and not an implict
    # upconversion to Unicode, losing our \xff bytes and such.
    # I'd argue that this is a bug.  Took me hours to trace.
    self.request.charset = None

    service = self.request.get('service')
    method = self.request.get('method')
    request_bytes = self.request.get('request')
    apiproxy = apiproxy_stub_map.apiproxy
    stub = apiproxy.GetStub(service)
    if not stub:
      self.response.out.write('<html><body>bogus service</body></html>')
      return

    # Some aliases:
    datastore = datastore_pb
    base = api_base_pb
    entity = entity_pb

    # This is lame that I have to manually maintain this table.  Is
    # there a better way?  At least we don't have to implement all
    # these ourselves. :)
    proto_class = {
      "datastore_v3": {
        "Get": (datastore.GetRequest, datastore.GetResponse),
        "Put": (datastore.PutRequest, datastore.PutResponse),
        "Delete": (datastore.DeleteRequest, base.VoidProto),
        "RunQuery": (datastore.Query, datastore.QueryResult),
        "Next": (datastore.NextRequest, datastore.QueryResult),
        "Count": (datastore.Query, base.Integer64Proto),
        "Explain": (datastore.Query, datastore.QueryExplanation),
        "DeleteCursor": (datastore.Cursor, base.VoidProto),
        "BeginTransaction": (base.VoidProto, datastore.Transaction),
        "Commit": (datastore.Transaction, base.VoidProto),
        "Rollback": (datastore.Transaction, base.VoidProto),
        "GetSchema": (base.StringProto, base.VoidProto),
        "CreateIndex": (entity.CompositeIndex, base.Integer64Proto),
        "UpdateIndex": (entity.CompositeIndex, base.VoidProto),
        "GetIndices": (base.StringProto, datastore.CompositeIndices),
        "DeleteIndex": (entity.CompositeIndex, base.VoidProto),
        },
      "user": {},
      "urlfetch": {},
      "mail": {},
      "memcache": {
        "Get": (MemcacheGetRequest, MemcacheGetResponse),
        "Set": (MemcacheSetRequest, MemcacheSetResponse),
        },
      "images": {},
      }

    if not method in proto_class[service]:
      self.response.out.write('<html><body>unknown/unmapped method'
                              + '</body></html>')
      return

    ctors = proto_class[service][method]
    request = ctors[0]()
    response = ctors[1]()

    try:
      request.ParseFromString(request_bytes)
      stub.MakeSyncCall(service, method, request, response)
    except Exception, e:
      self.response.out.write('Error doing sync-call: ' + str(type(e))
                              + " on request: " + request_bytes
                              + " (of length " + str(len(request_bytes)) + ")")
      return
    
    self.response.out.write('Response: [' + response.Encode() + ']')


application = webapp.WSGIApplication([
  ('/', MainPage),
  ('/do_req', DoRequest)
], debug=True)


def main():
  wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
  main()
