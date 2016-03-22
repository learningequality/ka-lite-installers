Release Notes for KA Lite Mac OS X Application
==============================================

0.16.0
------

**Mac Installer**

* NEW - We now support Mac OS X 10.11 El Capitan.
* NEW - We now use a .pkg installer which uses a setup wizard GUI.
* NEW - We now bundle the `KA-Lite.app`, `README.md`, `LICENSE`, `RELEASE_NOTES.md`, `KA-Lite_Uninstall.tool` script, and the `support` folder inside the `/Applications/KA-Lite/` folder.
* NEW - We now auto-load the application after installation.
* NEW - We now check if KA Lite is loaded and will not continue with the installation if it is.
* NEW - You can now use the `Console` utility application to view the KA-Lite installer and application logs.
* NEW - We now have a pre-installation script that checks for a previous installation if it exists and does the following:
  - Remove `/Applications/KA-Lite/KA-Lite.app`.
  - Remove `/Applications/KA-Lite-Monitor.app`.
  - Remove `/Library/LaunchAgents/org.learningequality.kalite.plist`.
  - Remove `/usr/bin/kalite` executable.
  - Remove `/usr/local/bin/kalite` executable. 
  - Remove `/Applications/KA-Lite/` directory and its contents.
  - Unset `KALITE_PYTHON` environment variable.
  - Unset `KALITE_HOME` environment variable.
* NEW - We now have a post-installation script that does the following:
  - Set `KALITE_PYTHON` environment variable.
  - Symlink `kalite` executable to `/usr/local/bin/`.
  - Bundle `KA-Lite.app`, `README.md`, `LICENSE`, `RELEASE_NOTES.md`, `KA-Lite_Uninstall.tool` script, and the `support` folder in the `/Applications/KA-Lite/` directory.
  - Put the `content/contentpacks/en.zip`, `pyrun`, and `scripts` inside the `/Applications/KA-Lite/support/` folder to be used as KA Lite installer resources.
  - Run `kalite manage` commands like `syncdb --noinput`, `retrievecontentpack`, and `setup --noinput`.
  - Auto-load the KA Lite application after a successful installation.
* REMOVED - We don't produce and use the `.dmg` disk image anymore.
* REMOVED - We removed the word `Monitor` in the installer name.

**Mac Application**

* NEW - User can now auto-load the application on login.
* NEW - We now auto-start the KA Lite web server when the application is loaded.
* NEW - We have streamlined the preferences dialog and show only the relevant options.
* NEW - User can now set a custom KA Lite data path, instead of the default `~/.kalite/`.
* FIXED - The startup time of the KA Lite server has been greatly reduced to just a few seconds.
* FIXED - We only load the `KA-Lite.app` if the `kalite` executable is available.
* FIXED - We now use the same version as the KA Lite web application for consistency.
* CHANGED - We changed `KA-Lite-Monitor.app` to `KA-Lite.app`.
* REMOVED - We removed the "Monitor" text from the application.
* REMOVED - We removed the `Advanced` tab and its contents.
* REMOVED - We removed the automatic creation of admin account during setup.
 
**Mac Uninstaller**

* NEW - User can uninstall `KA-Lite.app` and it's dependencies using the `KA-Lite_Uninstall.tool` script.
* NEW - User can optionally delete the `~/.kalite/` folder or the custom KA Lite data path.


0.15.0 (14-Oct-2015)
--------------------

**Mac Installer**

* NEW - We now have a confirmation dialog for the terms of the license.

**Mac Application**

* NEW - We now show KA Lite logs in the `KA Lite Preferences` dialog.
* NEW - We now show the logs of the kalite commands in the Console app.
* NEW - We now show a loading indicator during run of `kalite` commands.
* FIXED - We now use `NSTask` to support asynchronous processing of `kalite` commands.  Which means the application does not "hung" when `kalite start` is ran.


0.14.0 (31-Aug-2015)
--------------------

**Mac Installer**

* NEW - We now bundle `Pyrun` into KA Lite.
* FIXED - Restart is not required after the installation.

**Mac Application**

* NEW - We now code sign the Mac application.
* NEW - The `kalite` executable can now be run anywhere in the Terminal.
* NEW - We now show a status icon at the system menu bar.
* NEW - We now provide a `KA Lite Preferences` dialog for the user.
* NEW - User can now create admin account in the `Preferences` tab.
