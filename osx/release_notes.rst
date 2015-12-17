Release Notes
=============

0.16.0
------

**Mac Installer**

* NEW - You must restart your computer after installation.
* NEW - We now have a setup wizard for the installer.
* NEW - We now support OS X 10.11 El Capitan.
* NEW - We now bundle application and uninstaller script inside the ``/Applications/KA-Lite/`` folder.
* NEW - We have pre_installation script that do the following:

 * Remove ``KA-Lite.app`` from ``/Applications/KA-Lite``.
 * Remove ``org.learningequality.kalite.plist`` file in ``/Library/LaunchAgents/``.
 * Remove ``kalite`` executable from ``/usr/bin``.
 * Remove ``kalite`` executable from ``/usr/local/bin/kalite``.
 * Unset ``KALITE_PYTHON`` environment variable.
 * Remove ``ka-lite`` directory from ``/Users/Shared/ka-lite`` directory.
 * Unset ``KALITE_HOME`` environment variable and remove ``KA-Lite`` data that was set by user to a specific location.

* NEW - We have post_installation script that do the following:

 * Set environment variable ``KALITE_PYTHON``.
 * Symlink for ``kalite`` executable.
 * Bundle ``KA-Lite.app`` and ``KA-Lite_Uninstall.tool`` in ``/Applications/KA-Lie`` directory.
 * The ``ka-lite`` resources and ``pyrun`` are save in ``/Users/Shared/ka-lite``.
 * Run ``kalite manage`` commands like (``syncdb --noinput``, ``initcontent_items --overwrite``, ``unpack_assessment_zip`` and ``setup --noinput``). This will load the app much faster compared to the previous release. 

* REMOVED - We don't use the ``.dmg`` package anymore.
* REMOVED - We removed the word ``Monitor`` in the installer name.


**Mac Application**

* NEW - User can auto-start the application on login.
* NEW - User can now set custom ``KA-Lite`` data path, instead of the default ``~/.kalite/``.
* FIXED - Support for OS X 10.11 El Capitan.
* CHANGED - We changed ``KA-Lite-Monitor.app`` to ``KA-Lite.app``.
* REMOVED - We have removed the ``Advanced`` tab and it's contents.
* REMOVED - Creation of admin account during setup.
 
**Mac Uninstaller**

* NEW - User can uninstall ``KA-Lite.app`` and it's dependencies by using ``KA-Lite_Uninstall.tool`` script.
* NEW - User can optionally delete ``~/.kalite`` folder or custom ``KA-Lite`` data path.
* REMOVED - Removed ``KA-Lite-Monitor.app`` in ``/Applications`` folder.

0.15.0 (14-Oct-2015)
--------------------

**Mac Installer**

* NEW - Confirmation dialog for terms of the license.

**Mac Application**

* NEW - We show ``ka-lite`` logs in ``Logs`` tab of ``KA Lite Preferences`` dialog.
* NEW - We show the logs / output of the kalite command in the GUI or Console app.
* NEW - Show an indicator during run of ``kalite`` command.
* FIXED - Reset ``KA-Lite`` application must inform user if an anomaly is found in the user's environment.
* FIXED - Need to restart the app after setup.
* FIXED - We now use ``NSTask`` to support asynchronous processing of ``kalite`` commands.  Which means the application does not "hung" when ``kalite start`` is ran.


0.14.0 (31-Aug-2015)
--------------------

**Mac Installer**

* NEW - We bundle ``Pyrun`` into ``KA Lite``.
* FIXED - Reboot is required after OSX installation.

**Mac Application**

* NEW - Mac installer is already code signed.
* NEW - We make ``kalite`` executable anywhere. 
* NEW - We show status icon at system menu bar.
* NEW - We have menu extras in our ``KA-Lite`` menu icon at the menu bar.
* NEW - We provide ``KA Lite Preferences`` dialog for the user.
* NEW - User can create admin account in ``Preferences`` tab. 


