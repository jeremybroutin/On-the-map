# OnTheMap
## Description
Udacity iOS Developer Nanodegree - 3rd project - Networking<br>
OnTheMap allows Udacity students to scan through a world map,see where other students have pinned themselves and finally to add their own location on the map.
## App content
OnTheMap focused on networking requests and responses and includes the following:
- [Udacity API](https://www.udacity.com/catalog-api) GET and POST requests to handle user identification for Udacity Students
- [Parse](http://parse.com) GET and POST requests used to queryexisting users locations to be added on the map and allowing a user to add or edit its own pin
- [Facebook SDK Login Kit](https://developers.facebook.com/docs/reference/ios/current/) to facilitate users login (requires a Udacity profile to be linked with FB)
- a mapView and a tableView to display the users locations in two formats

## Additional infos
The app does not persist information into the device.
Users locations and related information (name and web link) are queried when necessary.
