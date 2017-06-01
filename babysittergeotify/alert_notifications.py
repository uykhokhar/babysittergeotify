import webapp2
import json

import cloudkit_helper as ck

class AlertNotifications(webapp2.RequestHandler):
    def post(self):
        message = self.request.get('message')
        new_joke_of_the_day_data = {
        'operations': [{
            'operationType': 'create',
            'record': {
                'recordType': 'Alert',
                'fields': {
                    'message': {'value': message},
                }
            }
        }]
        }

        result_modify_jokes = ck.cloudkit_request(
        '/development/public/records/modify',
        json.dumps(new_joke_of_the_day_data))

        self.response.headers['Content-Type'] = 'text/json'
        self.response.write(result_modify_jokes['content'])
        #self.redirect('/alerts/')

    def get(self):
        self.response.headers['Content-Type'] = 'text/html'
        html = """
        <form action="/alerts/" method="post">
        <b>Alert Notifcation Message</b><br>
        <input type="text" name="message" value=""><br>
        <input type="submit" value="Submit">
        </form>
        """
        self.response.write(html)
