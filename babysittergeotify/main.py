# Copyright 2016 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import webapp2

import sys
import json

import cloudkit_helper as ck
from cost_of_the_day import CostOfTheDay
from alert_notifications import AlertNotifications

class MainPage(webapp2.RequestHandler):
    def get(self):
        self.response.headers['Content-Type'] = 'text/html'
        self.response.write("welcome")

class ProcessEntry(webapp2.RequestHandler):
    def get(self):

        self.response.headers['Content-Type'] = 'text/html'
        self.response.write("process entry")
        entries = ck.query_records('Entry')
        for entry in entries:
            self.response.write("<li>%s</li>" % entry)


app = webapp2.WSGIApplication([
    ('/', MainPage),
    ('/entry/', ProcessEntry),
    ('/alerts/', AlertNotifications),
    ('/tasks/costoftheday/', CostOfTheDay),

], debug=True)
