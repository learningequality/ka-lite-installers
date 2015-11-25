KA-Lite Monitor Mac OSX App
===========================

This is the KA-Lite Monitor application that sits on the status menu of Mac OSX.  

It's used to install and monitor the [KA-Lite](https://github.com/learningequality/ka-lite/) server by [Foundation for Learning Equality](https://learningequality.org/).

It uses [PyRun](http://www.egenix.com/products/python/PyRun/) to isolate the KA-Lite environment from your system's [Python](https://www.python.org/) application.


## To Install

1. Open the downloaded "KA-Lite Monitor.dmg" package.
1. On the .dmg window, drag the "KA-Lite Monitor" app into the "Applications" folder.
1. Launch "KA-Lite Monitor" from your 'Applications' folder.
1. On first load, it will check for some settings and prompt for the Preferences dialog.
1. Input your preferred admin username and password.
1. Click on the Apply button.
1. You will be prompted that initial setup will take a few minutes, just click on Ok button and wait for the prompt that KA-Lite has been setup and can now be started.
1. Click on the KA-Lite logo icon on the Status Menu Bar and select the "Start KA-Lite" menu option.
1. When prompted that KA-Lite has been started, click on the logo icon again and select "Open in Browser" menu option - this should launch KA-Lite on your preferred web browser.
1. Login using the administrator account you have specified during setup.


## Menu Options

1. Start KA Lite == Starts the KA-Lite web server.
1. Stop KA Lite == Stops the KA-Lite web server.
1. Open in Browser == Opens the installed KA-Lite web app using your preferred web browser, usually at http://127.0.0.1:8008.
1. Preferences == Opens the preferences window where you can customize the admin account, repeat the setup process, or reset the app on the Advanced tab.
1. Quit == Stops the KA-Lite web server and closes the application.

## Advanced Notes

1. You can use the `kalite` executable at the Terminal for advanced commands.
1. If you want to access/backup the KA-Lite database:
    1.1. Go to the `~/.kalite/database/` folder.
    1.2. Copy the `data.sqlite` to your preferred location.  This is a [Sqlite](https://sqlite.org/) database.
1. If you want to access/backup your contents like videos and assessment items:
    1.1. Go to the `~/.kalite/content/` folder.
    1.2. Copy the contents to your preferred location.
1. To change the `KALITE_HOME` environment variable using the `KA Lite` application, follow the steps bellow.
   1. Launch `KA Lite` application
   1. Open the `KA Lite` preferences dialog.
   1. Choose your preferred location in the `KA Lite data path`.
   1. Click `Apply` button.
   1. Navigate to system terminal and run the following commands: (This will create a new black database for the selected `KA Lite data path` location)
   		* `kalite manage syncdb --noinput`
   		* `kalite manage init_content_items --overwrite`
   		* `kalite manage setup --noinput` 
   1. Click `Start KA Lite` button in the `KA Lite` application
1. We suggest you make a backup of your installation contents at `~/.kalite/` before using the controls at the `Advanced` tab.
1. On the `Advanced` tab, you can click on the `Setup` button which will re-setup your KA-Lite installation.  This will take a few minutes and be careful because you may lose data!
1. Also on the `Advanced` tab, there's a `Reset App` button that will clear settings and files that were created by the app.  This will set the KA-Lite environment as if the app was not yet installed.  Please be very careful with this button and only use this in case you encounter issues in your installation.


## Help and Logs

To view the KA-Lite Monitor's application logs (for debugging or tracing), launch the `Console` application and filter by "ka-lite".

You can also open `~/.kalite/server.log` to view access and debug logs of the KA-Lite server.

If you encounter issues, please file them at the [KA-Lite Installers repository](https://github.com/learningequality/installers).

Please note that we have tested this application on MAC OSX Yosemite 10.10.x.


## ToDos

1. Make `Path for Database and Contents` options work.
1. Make `Application Behavior` options work.
1. Confirm the Quit action with a dialog to prevent accidental closing of the application.
