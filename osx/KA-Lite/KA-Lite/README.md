KA-Lite OS X App
========================

To install:

* Double click the "KA-Lite.pkg" and follow the steps of the setup wizard.


## Features

1. Show status icon at system status menu.
1. Can customize KA-Lite data path.
1. Logs terminal messages so they are accessible at the Console app.
1. Set auto start on login.


## Use of the app using `Prefernces` dialog or in `KA-Lite` menu option.

 1. `Start KA Lite`
 1. `Open it Browser`
 1. `Stop KA Lite`


For setting up custom KA Lite data path:

 1. Stop the server from running.
 2. Set your custom path from `Prefernces` dialog.
 3. Click `Apply`.
 4. Go to terminal and run command `kalite manage syncdb --noinput`.
 5. Run `kalite manage init_content_items --overwrite`.
 6. Run `kalite manage setup --noinput`.
 7. Start the server again by clicking on `Start KA-Lite` in the menu option.

 Note that the "Start KA Lite" menu is disabled if the `/usr/local/bin/kalite` cannot be found.