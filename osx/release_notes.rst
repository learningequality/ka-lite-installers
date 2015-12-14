Release Notes
=============

0.16.0
------

General
^^^^^^^

**Closed issues in this release:**

* 301_. Help text for the custom data path control.
* 290_. Fix develop branch merge error.
* 288_. Implement auto start on login.
* 276_. OS X Application UX changes.
* 273_. Use kalite executable when running commands in NSTASK class. 
* 266_. OS X Application changes.
* 240_. Change dock icon of OS X app.
* 238_. Remove creation of admin account during setup.
* 225_. Update the LICENCE copyright.
* 197_. Mac installer status check must increment the process counter and set the icon properly.
* 308_. Topic tree items are greyed-out during first install.
* 282_. plist files are not deleted during the upgrade to 0.16.x.
* 264_. OS X Installer changes.
* 239_. Make an OS X uninstaller app.
* 144_. Implement Mac Packages.

.. _301: https://github.com/learningequality/installers/issues/301
.. _290: https://github.com/learningequality/installers/issues/290
.. _288: https://github.com/learningequality/installers/issues/288
.. _276: https://github.com/learningequality/installers/issues/276
.. _273: https://github.com/learningequality/installers/issues/273
.. _266: https://github.com/learningequality/installers/issues/266
.. _240: https://github.com/learningequality/installers/issues/240
.. _238: https://github.com/learningequality/installers/issues/238
.. _225: https://github.com/learningequality/installers/issues/225
.. _197: https://github.com/learningequality/installers/issues/197
.. _308: https://github.com/learningequality/installers/issues/308
.. _282: https://github.com/learningequality/installers/issues/282
.. _264: https://github.com/learningequality/installers/issues/264
.. _239: https://github.com/learningequality/installers/issues/239
.. _144: https://github.com/learningequality/installers/issues/144

**Changes on installer:**

 * Setting up environment variable ``KALITE_PYTHON``.
 * Symlink for ``kalite`` executable will be done during installation.
 * Unpack assessment items.
 * Bundle ``KA-Lite.pkg`` and ``KA-Lite_Uninstall.tool`` in ``/Applications/KA-Lite`` directory.
 * The ``ka-lite`` resources and ``pyrun`` are save in ``/Users/Shared/ka-lite``.


**Uninstaller**

In order to uninstall ``KA-Lite.app`` and it's dependencies, use ``KA-Lite_Uninstall.tool``.
The ``KA-Lite.app`` and ``KA-Lite_Uninstall.tool`` are bundled in ``/Applications/KA-Lite`` folder. In this setup the user can simply locate the uninstaller script and uninstall the ``KA-Lite.app``.

**Changes on application:**

* **Removed features:**

 * Symlink of ``kalite`` executable.
 * Set environment variable for ``KALITE_PYTHON``.
 * Unpack assessment items.
 * Reset the application.
 * The app shows an icon at the system status menu and it uses User Preferences saved at ``~/Library/Preferences/FLE.KA-Lite.plist`` to save the admin username and admin password (encoded).

* **Added features:**

 * Auto start on login.
 * Set a custom ``KA Lite`` data path.
 * Help text for custom path.

0.15.0
------

General
^^^^^^^

**Closed issues in this release:**

* 202_. Mac installer must add LICENSE to ``setup-files``.
* 187_. Mac installer menu bar icon not set to "processing" while setup is running.
* 154_. Reset App must inform user if an anomaly is found in the user's environment.
* 153_. Need to restart the app after setup.
* 161_. Clean-up setup.sh comments and steps.
* 150_. KA-Lite documentation for Mac installer is not available.
* 182_. Check if assessment.zip was successfully downloaded.
* 169_. MAC 0.15 dev, assets are not compiled.
* 142_. Cannot build the Xcode project without the code signing identity.
* 129_. OSX application performance issues.

.. _202: https://github.com/learningequality/installers/issues/202
.. _187: https://github.com/learningequality/installers/issues/187
.. _154: https://github.com/learningequality/installers/issues/154
.. _153: https://github.com/learningequality/installers/issues/153
.. _161: https://github.com/learningequality/installers/issues/161
.. _150: https://github.com/learningequality/installers/issues/150
.. _182: https://github.com/learningequality/installers/issues/182
.. _169: https://github.com/learningequality/installers/issues/169
.. _142: https://github.com/learningequality/installers/issues/142
.. _129: https://github.com/learningequality/installers/issues/129

0.14.0
------

General
^^^^^^^

**Closed issues in this release:**

* 135_. Shebang checker corrupts the kalite executable.
* 126_. Run `kalite manage compileymltojson` when building the installer.
* 121_. Reboot is required after OSX installation.
* 118_. Include a dummy assessment.zip to make the OSX build succeed.
* 108_. Bad interpreter: No such file or directory.
* 102_. Setup script extracts ka-lite source outside the working directory.
* 91_. There's a bug that always shows the user preferences dialog.
* 31_. Only download the ka-lite zip if there's no ka-lite folder in build directory.
* 30_. Make kalite executable anywhere.
* 26_. Deploy ka-lite data folders to another location outside of the .app.
* 24_. Generate new local_settings.py based on user values at preferences dialog.
* 21_. Code sign the OS X installer.
* 13_. Provide user a way to "force" start ka-lite.
* 7_. Cannot watch video on develop branch.
* 4_. Bundle KA Lite into PyRun.


.. _135: https://github.com/learningequality/installers/issues/135
.. _126: https://github.com/learningequality/installers/issues/126
.. _121: https://github.com/learningequality/installers/issues/121
.. _118: https://github.com/learningequality/installers/issues/118
.. _108: https://github.com/learningequality/installers/issues/108
.. _102: https://github.com/learningequality/installers/issues/102
.. _95: https://github.com/learningequality/installers/issues/95
.. _91: https://github.com/learningequality/installers/issues/91
.. _31: https://github.com/learningequality/installers/issues/31
.. _30: https://github.com/learningequality/installers/issues/30
.. _26: https://github.com/learningequality/installers/issues/26
.. _24: https://github.com/learningequality/installers/issues/24
.. _21: https://github.com/learningequality/installers/issues/21
.. _13: https://github.com/learningequality/installers/issues/13
.. _7: https://github.com/learningequality/installers/issues/7
.. _4: https://github.com/learningequality/installers/issues/4



