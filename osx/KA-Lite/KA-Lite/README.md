KA Lite Mac OS X Application
============================

This is the Xcode project for the KA Lite application.


## Requirements

Xcode 6.x or 7.x
Mac OS X Yosemite or El Capitan


## Features

1. Show status icon at the menu bar.
1. It uses the `/usr/local/bin/kalite` executable to interface with the KA Lite server.
1. Provide menu to Start KA Lite, Stop KA Lite, and open KA Lite in browser.
1. Preferences dialog for admin tasks like setting a custom KA Lite data path.
1. Logs messages so they are accessible at the Logs tab of the Preferences dialog and the Console app.


## Notes:

* The application will not load if the `/usr/local/bin/kalite` executable cannot be found.
* Refer to the `osx/release-docs/README.md` document for more details.
