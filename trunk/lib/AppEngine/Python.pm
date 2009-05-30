package AppEngine::Python;

use warnings;
use strict;

sub perl_setenv {
    $ENV{$_[0]} = $_[1];
}

sub perl_getenv {
    return $ENV{$_[0]};
}

sub perl_env_contains {
    return exists $ENV{$_[0]};
}


use Inline 'Python' => <<'END';

import os
import sys

# If perl isn't compiled with PERL_USE_SAFE_PUTENV, perl_destruct will try to
# free the contents of the environment when the interpreter closes.  If we let
# python set variables in the environment then perl will segfault when it tries
# to free them.

def safe_set_item(key, value):
  os.environ.data[key] = value
  perl.AppEngine.Python.perl_setenv(key, value)

def safe_get_item(key, default=None):
  ret = perl.AppEngine.Python.perl_getenv(key)
  if ret:
    return ret
  else:
    return default

os.environ.__setitem__ = safe_set_item
os.environ.__getitem__ = safe_get_item
os.environ.__contains__ = perl.AppEngine.Python.perl_env_contains
os.environ.get = safe_get_item


# Set the pythonpath to find the appengine sdk

sys.path = [
  'python_sdk_partial',
  os.path.join('python_sdk_partial', 'lib', 'antlr3'),
  os.path.join('python_sdk_partial', 'lib', 'django'),
  os.path.join('python_sdk_partial', 'lib', 'webob'),
  os.path.join('python_sdk_partial', 'lib', 'yaml', 'lib'),
] + sys.path


from google.appengine.api import apiproxy_stub_map

from google.appengine.api.memcache import memcache_service_pb
from google.appengine.api.images import images_service_pb
from google.appengine.api import mail_service_pb
from google.appengine.api import urlfetch_service_pb
from google.appengine.api import user_service_pb
from google.appengine.api.datastore import datastore_pb
from google.appengine.api.datastore import entity_pb
from google.appengine.api import api_base_pb
from google.appengine.runtime import apiproxy_errors

from google.appengine.tools import dev_appserver
from google.appengine.tools import dev_appserver_main
from google.appengine.tools import dev_appserver_login

# Some aliases:
datastore = datastore_pb
base = api_base_pb
entity = entity_pb
memcache = memcache_service_pb

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
  "user": {
    "CreateLoginURL": (base.StringProto, base.StringProto),
    "CreateLogoutURL": (base.StringProto, base.StringProto),
    },
  "urlfetch": {
    "Fetch": (urlfetch_service_pb.URLFetchRequest,
              urlfetch_service_pb.URLFetchResponse),
    },
  "mail": {
    # TODO(bradfitz): proto files not yet released
    },
  "memcache": {
    "Get": (memcache.MemcacheGetRequest, memcache.MemcacheGetResponse),
    "Set": (memcache.MemcacheSetRequest, memcache.MemcacheSetResponse),
    "Delete": (memcache.MemcacheDeleteRequest, memcache.MemcacheDeleteResponse),
    "Increment": (memcache.MemcacheIncrementRequest, memcache.MemcacheIncrementResponse),
    "FlushAll": (memcache.MemcacheFlushRequest, memcache.MemcacheFlushResponse),
    "Stats": (memcache.MemcacheStatsRequest, memcache.MemcacheStatsResponse),
    },
  "images": {
    "Transform": (images_service_pb.ImagesTransformRequest,
                  images_service_pb.ImagesTransformResponse),
    },
  }

def initialize(app_name, args={}):
  option_dict = dev_appserver_main.DEFAULT_ARGS
  option_dict.update(args)

  dev_appserver.SetupStubs(app_name, **option_dict)

  email, admin = dev_appserver_login.GetUserInfo(os.environ['COOKIE'])
  os.environ['USER_EMAIL'] = email
  if admin:
    os.environ['USER_IS_ADMIN'] = '1'

def handle_login():
  dev_appserver_login.main();
  sys.stdout.flush()

def make_request(service, method, request_bytes):
  apiproxy = apiproxy_stub_map.apiproxy
  stub = apiproxy.GetStub(service)
  if not stub:
    raise Exception('bogus service')

  if not method in proto_class[service]:
    raise Exception('unknown/unmapped method')

  ctors = proto_class[service][method]
  request = ctors[0]()
  response = ctors[1]()

  request.ParseFromString(request_bytes)
  stub.MakeSyncCall(service, method, request, response)

  return response.Encode()

END

1;
