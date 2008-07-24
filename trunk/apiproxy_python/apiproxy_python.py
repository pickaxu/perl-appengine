#!/usr/bin/env python

import cgi
import wsgiref.handlers

from google.appengine.ext import webapp

class MainPage(webapp.RequestHandler):
  def get(self):
    self.response.out.write('<html><body>')

    self.response.out.write("""
          API proxy interface;
          <form action="/do_req" method="post">
            <div><textarea name="request" rows="20" cols="60"></textarea></div>
            <div><input type="submit" value="submit"></div>
          </form>
        </body>
      </html>""")


class DoRequest(webapp.RequestHandler):
  def post(self):
    request = self.request.get('request')
    self.response.out.write('<html><body>' + request + '</body></html>')


application = webapp.WSGIApplication([
  ('/', MainPage),
  ('/do_req', DoRequest)
], debug=True)


def main():
  wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
  main()
