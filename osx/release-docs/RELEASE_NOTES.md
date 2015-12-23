Release Notes
=============

0.16.0
------

**Mac Installer**

* NEW - We now have a setup wizard for the installer which use [Packages] (http://s.sudre.free.fr/Software/Packages/about.html) module by Sudre. We now restart the computer after installation.
* NEW - We now support OS X 10.11 El Capitan.
* NEW - We now bundle the `KA-Lite.app`, `README.md`, `LICENSE`, `RELEASE_NOTES.md` and `KA-Lite_Uninstall.tool` script inside the `/Applications/KA-Lite/` folder.
* NEW - We now have pre-installation script that checks the previous installation if exist and does the following:
  - Remove `/Applications/KA-Lite/KA-Lite.app`.
  - Remove `/Library/LaunchAgents/org.learningequality.kalite.plist`.
  - Remove `/usr/bin/kalite` executable.
  - Remove `/usr/local/bin/kalite` executable. 
  - Remove `/Users/Shared/ka-lite` directory.
  - Unset `KALITE_PYTHON` environment variable.
  - Unset `KALITE_HOME` environment variable.
* NEW - We now have post-installation script that does the following:
  - Set environment variable `KALITE_PYTHON`.
  - Symlink `kalite` executable to `/usr/local/bin/`.
  - Bundle `KA-Lite.app` `README.md`, `LICENSE`, `RELEASE_NOTES.md` and `KA-Lite_Uninstall.tool` in `/Applications/KA-Lite/` directory.
  - We now use `/Users/Shared/ka-lite/` which contains the `assessment.zip`, `pyrun`, and `scripts`.
  - Run `kalite manage` commands like (`syncdb --noinput`, `initcontent_items --overwrite`, `unpack_assessment_zip` and `setup --noinput`).
* REMOVED - We don't use the `.dmg` package anymore.
* REMOVED - We removed the word `Monitor` in the installer name.


**Mac Application**

* NEW - User can now auto-start the application on login.
* NEW - User can now set custom `KA-Lite` data path, instead of the default `~/.kalite/`.
* FIXED - Support for OS X 10.11 El Capitan.
* CHANGED - We now changed `KA-Lite-Monitor.app` to `KA-Lite.app`.
* REMOVED - We now removed the `Advanced` tab and it's contents.
* REMOVED - We now removed the creation of admin account during setup.
 
**Mac Uninstaller**

* NEW - User can uninstall `KA-Lite.app` and it's dependencies by using `KA-Lite_Uninstall.tool` script.
* NEW - User can optionally delete `~/.kalite/` folder or custom `KA-Lite` data path.
* REMOVED - Removed `KA-Lite-Monitor.app` in `/Applications/` folder.

0.15.0 (14-Oct-2015)
--------------------

**Mac Installer**

* NEW - Confirmation dialog for terms of the license.

**Mac Application**

* NEW - We now show `ka-lite` logs in `Logs` tab of `KA Lite Preferences` dialog.
* NEW - We now show the logs of the kalite command in the GUI or Console app.
* NEW - We now show an indicator during run of `kalite` command.
* FIXED - Reset `KA-Lite` application must inform user if an anomaly is found in the user's environment.
* FIXED - We now need to restart the app after setup.
* FIXED - We now use `NSTask` to support asynchronous processing of `kalite` commands.  Which means the application does not "hung" when `kalite start` is ran.


0.14.0 (31-Aug-2015)
--------------------

**Mac Installer**

* NEW - We bundle `Pyrun` into `KA Lite`.
* FIXED - Reboot is required after OSX installation.

**Mac Application**

* NEW - Mac installer is already code signed.
* NEW - We make `kalite` executable anywhere. 
* NEW - We show status icon at system menu bar.
* NEW - We provide `KA Lite Preferences` dialog for the user.
* NEW - User can create admin account in `Preferences` tab.