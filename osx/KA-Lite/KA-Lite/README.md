KA-Lite OS X App
========================

This is the KA-Lite status menu app with the source and PyRun in one package.

To install:

* Drag the "KA-Lite" app into the "Applications" folder.


## Features

1. Show status icon at system status menu.
1. Preferences dialog to customize admin account and run the setup process.
1. Makes the `kalite` executable runnable from anywhere on the terminal.
1. Logs terminal messages so they are accessible at the Console app.


## Use of the app

When the app is run, it will automatically show the preferences dialog if the following do not exist:

1. `/usr/bin/kalite` symlink
2. database at `~/.kalite/database/data.sqlite` - the `~/.kalite/` location can be overridden by setting a `KALITE_HOME` environment variable

The app shows an icon at the system status menu and it uses User Preferences saved at `~/Library/Preferences/FLE.KA-Lite.plist` to save the following:

1. admin username
2. admin password (encoded)
3. (TODO) KALITE_PYTHON environment variable - defaults to the `<Resources directory>/pyrun-2.7/bin/pyrun`.

Note that the "Start KA Lite" menu is disabled if the `/usr/bin/kalite` cannot be found.


### Use of the preferences dialog

When the `Apply` button is clicked, the app will ask for an admin password so it can symlink the `<pyrun-directory>/bin/kalite` executable to `/usr/bin/kalite` to make it runnable from anywhere on the Mac.

Click on the `Setup` button at the `Advanced` tab to repeat the setup process.  This will call `kalite manage setup --username=%@ --password=%@ --noinput` with the username and password values coming from the textboxes.

The `Reset App` button at the `Advanced` tab will reset all files/settings as if the app was never installed.