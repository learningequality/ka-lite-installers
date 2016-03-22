README for KA Lite Mac OS X Application
=======================================

This is the [KA Lite](https://github.com/learningequality/ka-lite/) application that sits on the menu bar of Mac OS X.

It is used to control and monitor the [KA Lite](https://github.com/learningequality/ka-lite/) server by [Foundation for Learning Equality](https://learningequality.org/).

It uses [PyRun](http://www.egenix.com/products/python/PyRun/) to isolate the KA Lite environment from your system's [Python](https://www.python.org/) application.


## Install KA Lite

1. Download the [KA Lite Mac OS X Installer for 0.16](http://pantry.learningequality.org/downloads/ka-lite/0.16/installers/mac/).
1. Double-click the downloaded `KA-Lite.pkg` package and click "Continue" when prompted about the "This package will run a program to determine if the software can be installed." message.
1. Follow the setup wizard.  The installation requires admin privileges.
1. This package will run a program to determine if the software can be installed.
1. The installer will create the `/Applications/KA-Lite/` folder that contains the KA-Lite application, uninstall tool, licence, readme, release notes, and the support folder.
1. The install process is quite lengthy because the installer had to copy content items and run some management commands including the setup process.  Please be patient.
1. After a successful installation, the KA Lite application will be auto-loaded and it will also auto-start the KA Lite web server.
1. You should see the notification "Running, you can now click on 'Open in Browser' menu.".

**Note:** Make sure that the KA Lite application is not loaded during installation.


## Using the KA Lite OS X Application


### To start the KA Lite server

1. Launch `KA-Lite` from the `/Applications/KA-Lite/` folder.  It should auto-start the KA Lite server and notify you of it's status.
1. When notified that KA Lite is running, click on the menu bar icon and select the `Open in Browser` menu option - this should launch KA Lite in your preferred web browser.


### Menu Options

1. `Start KA Lite` - Starts the KA Lite web server.
1. `Stop KA Lite` - Stops the KA Lite web server.  This is available when the KA Lite server has started.
1. `Open in Browser` - Opens the installed KA Lite web app using your preferred web browser, usually at `http://127.0.0.1:8008`.  This is available when the KA Lite server has started.
1. `Preferences` - Opens the preferences window where you can customize the KA Lite data folder, view application logs in the `Logs` tab, or uninstall KA Lite.
1. `Quit` - Stops the KA Lite web server and closes the application.


### How to set a custom KA Lite data folder:

 1. Stop the KA Lite server from running.
 2. Set your custom KA Lite data folder in the `Preferences` dialog.
 3. Click `Apply`.  This will update the `KALITE_HOME` environment variable.
 4. Launch a new Terminal session to use the updated `KALITE_HOME` environment variable.
 5. Run `kalite manage syncdb --noinput`.
 7. Run `kalite manage setup --noinput`.
 8. Run `kalite manage retrievecontentpack local en /Applications/KA-Lite/support/content/contentpacks/en.zip`.
 9. Start the server again by clicking on `Start KA Lite` in the menu option.

**Note:** You can specify another content pack archive that you've downloaded from http://pantry.learningequality.org/downloads/ka-lite at the `retrievecontentpack` step above.  Make sure you download the content pack archive for the installed version of KA Lite.


## Uninstall KA Lite

* This will require admin privileges.
* Double-click the `/Applications/KA-Lite/KA-Lite_Uninstall.tool`, this is a bash script that will do the following:
  - uninstall `KA-Lite.app` and remove its dependencies, then unset the environment variables.
  - optionally remove the KA Lite data folder.
* Alternatively, you can also click the Uninstall KA Lite button at the Preferences dialog of the KA Lite application.  Check the "Delete KA Lite data folder" if you want to also remove your KA Lite data.


## Help and Logs

To view the KA Lite installer and application logs, launch the `Console` application and filter by "ka-lite".  You can also view the KA Lite application logs in the `Preferences` dialog by clicking on the `Logs` tab.

To view the KA Lite web server logs, open `~/.kalite/server.log` to view access and debug logs.  If you have set a custom KA Lite data folder in the Preferences dialog, use this format: `$KALITE_HOME/server.log`.

If you encounter issues, please file them at the [KA Lite repository](https://github.com/learningequality/ka-lite/issues/) or at the [KA Lite Installers repository](https://github.com/learningequality/installers).

Please note that we have tested this application on the following Mac OS X versions:

* OS X El Capitan - version 10.11.3
* OS X Yosemite - version 10.10.5
* OS X Mavericks - version 10.9.5


## ToDos

1. Check for updates automatically.
1. Set an action when the notifications are clicked by the user.
1. Use a consistent icon set (for status stopped, running, busy, etc) based on the "leaf" or "official" icon.
