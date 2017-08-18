# BabySitter Geotification

Use Case
I’d like to automatically record the time that I drop off or pick up the kids from the babysitter. These start and end times are used to calculate payment. These recordings need to be shared amongst my wife and I. When I drop off the kids and she picks them up, the app should calculate the start and end time from two different users.
When the user approaches the babysitter’s home, the app should notify the user (a geo based notification —> a ‘geotification'). The notification should enable the user to select wether the user is dropping off or picking up the kids.
iOS App
The app has three main tabs and a notification interface.
Geotification Tab
The initial screen displays a map of the baby sitters.


The user can add a new geofence, radius and hourly rate

Notifications
Even if the app is closed, the user gets a notification when he enters the geofence.



The user can pull the notification down to record a drop-off or pickup.
Events Tab
These drop-offs and pickups are recorded and synced amongst users. They appear in the Events Tab. Only the drop-offs and pickup for the day are displayed here. CloudKit is used to store these events and CloudKit query populates the events for today.

Summary Tab
The summary tab displays the babysitter, the start, end times, total time, rate and cost for that service. A new summary is calculated daily by the GAE backend.


Backend
CloudKit
Data are stored in CloudKit to enable users to sync events and day summaries.
Google App Engine
A GAE cron job pulls all the events and finds Dropoff and pickup pairs for each babysitter. Multiple babysitters can be used in a day and there can be multiple pickups and dropoffs to each of them.
Additionally, the cron job ignores erroneously entered data. If the user enters two drop-offs or two pickups for the same time, the extra drop-off or pickup is ignored.
The cron job can be triggered by: http://localhost:8080/tasks/costoftheday/

Here is a sample printout in the web browser.

Attributions
https://www.raywenderlich.com/136165/core-location-geofencing-tutorialw
for today's date https://stackoverflow.com/questions/40312105/core-data-predicate-filter-by-todays-date
https://stackoverflow.com/questions/42524651/convert-nsdate-to-string-in-ios-swift


https://www.raywenderlich.com/136165/core-location-geofencing-tutorialw

for today's date
https://stackoverflow.com/questions/40312105/core-data-predicate-filter-by-todays-date

https://stackoverflow.com/questions/42524651/convert-nsdate-to-string-in-ios-swift

