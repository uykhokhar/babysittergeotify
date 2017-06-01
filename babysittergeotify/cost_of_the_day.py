import webapp2
import json
import cloudkit_helper as ck
import datetime



class CostOfTheDay(webapp2.RequestHandler):

    def get(self):
        self.response.headers['Content-Type'] = 'text/html'
        self.response.write("***************these are the fields for the cost of the day")


        date = datetime.datetime.utcnow().isoformat()[:-7] + 'Z'
        date = '2017-05-22 15:41:10'

        costs = self.calc_cost()
        #costs.append([babySitterName, startTime, endTime, totalTime, rate, cost])
        print("***************ALL Costs************", costs)

        for cost in costs:
            print("***************ALL Costs************", cost)
            new_cost_of_the_day_data = {
            'operations': [{
                'operationType': 'create',
                'record': {
                    'recordType': 'Cost',
                    'fields': {'babySitterName': {'value': cost[0]},
                               'startTime': {'value': cost[1]},
                               'endTime': {'value': cost[2]},
                               'totalTime': {'value': cost[3]},
                               'rate': {'value': cost[4]},
                               'cost': {'value': cost[5]}
                               }
                }
            }]
            }

            result_modify_cost = ck.cloudkit_request(
            '/development/public/records/modify',
            json.dumps(new_cost_of_the_day_data))

            #self.response.headers['Content-Type'] = 'text/json'
            self.response.write("The result of the modify request {}".format(result_modify_cost['content']))


    def calc_cost(self):
        self.response.headers['Content-Type'] = 'text/html'
        self.response.write("these are the fields for the cost of the day")

        entries = ck.query_records('Entry')
        print(entries)
        babySittersNextEntryDict = {}

        costs = []

        for entry in entries:
            fields = entry['fields']
            babySitterName = fields['babySitterName']['value']
            pickupOrDropoff = fields['pickupOrDropoff']['value']
            rate = fields['rate']['value']
            inputTime = fields['inputTime']['value']

            self.response.write("<li>entry: babySitterName: {},  {}, rate {}, inputTime {}</li>".format(babySitterName, pickupOrDropoff, rate,
                                                                             inputTime))
            if babySitterName not in babySittersNextEntryDict:
                print("not in", babySitterName)
                babySittersNextEntryDict[babySitterName] = [(pickupOrDropoff, rate, inputTime)]
                print(babySittersNextEntryDict)
            else:
                prev_pickupOrDropOff = babySittersNextEntryDict[babySitterName][-1][0] #get last entry and get pickupOrDropoff
                if prev_pickupOrDropOff == 'Dropoff' and pickupOrDropoff == 'Pickup': #pickup dropoff pair found, all other combinations ignored
                    prev_event = babySittersNextEntryDict[babySitterName][-1] #get last tuple
                    print('pickupDropoff pair found', prev_event)
                    #create cost entry
                    startTime = prev_event[2]
                    endTime = inputTime
                    totalTime = (inputTime - prev_event[2])/3.6e6
                    print(totalTime)
                    cost = rate * totalTime

                    costs.append([babySitterName, startTime, endTime, totalTime, rate, cost])
                    self.response.write(
                        "<li>Dropoff/pickup Pair costs: babySitterName: {}, startTime {}, endTime {}, totalTime {}, rate {}, cost {}</li>".format(
                            babySitterName, startTime, endTime, totalTime, rate, cost))
                babySittersNextEntryDict[babySitterName].append((pickupOrDropoff, rate, inputTime))
        return costs

    def return_date_from_timestamp(self, timestamp):
        date = datetime.datetime.fromtimestamp(timestamp / 1e3)
        date = date.isoformat()[:-7] + 'Z'
        return date
