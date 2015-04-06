KA-Lite Monitor OS X App
========================

This is the KA-Lite Monitor application that sits on the status menu of OS X.  

It also contains the source for [KA-Lite](https://github.com/learningequality/ka-lite/).


## To install:

1. Drag the "KA-Lite Monitor" app into the "Applications" folder.
1. Launch "KA-Lite Monitor" from your 'Applications' folder.
1. On first load, it will check for some settings and prompt for the Preferences dialog.
1. Input your preferred admin username and password.
1. Click on the Apply button.
1. You will be prompted that initial setup will take a few minutes, just click on Ok button and wait for the prompt that KA-Lite has been setup and can now be started.
1. Click on the KA-Lite logo icon on the Status Bar and select the "Start KA-Lite" menu option.
1. When prompted that KA-Lite has been started, click on the logo icon again and select "Open in Browser" menu option - this should launch KA-Lite on your preferred web browser.
1. Login using the administrator account you have specified during setup.


## Operations

1. Start KA Lite == Starts the KA-Lite web server.
1. Stop KA Lite == Stops the KA-Lite web server.
1. Open in Browser == Opens the installed KA-Lite web app using your preferred web browser, usually at http://127.0.0.1:8008.
1. Preferences == Opens the preferences window where you can customize the admin account or repeat the setup process.
1. Quit == Stops the KA-Lite web server and closes the application.


## Advanced Notes

1. On the `Advanced` tab, you can click on the `Setup` button which will re-setup your KA-Lite installation.  This will take a few minutes and be careful because you may lose data!
1. If you want to access the KA-Lite source:
    1.1. Right-click on the "KA-Lite Monitor.app" on your `Applications` folder.
    1.2. Select `Show Package Contents -> Contents -> Resources`.
    1.3. The `ka-lite` folder contains the source code of KA-Lite.
    1.4. The `pyrun-2.7` folder contains [PyRun](http://www.egenix.com/products/python/PyRun/) that is used to isolate KA-Lite from your system's Python application.
1. If you want to access/backup the KA-Lite database:
    1.1. Right-click on the "KA-Lite Monitor.app" on your `Applications` folder.
    1.2. Select `Show Package Contents -> Contents -> Resources -> ka-lite -> kalite -> database`.
    1.3. Copy the `data.sqlite` to your preferred location.  This is a [Sqlite](https://sqlite.org/) database.


## Help

1. To view the KA-Lite Monitor's application logs (for debugging or tracing), launch the `Console` application and filter by "ka-lite".


## ToDos

1. Make `Path for Database and Contents` options work.
1. Make `Application Behavior` options work.
1. Confirm the Quit action with a dialog to prevent accidental closing of the application.
