KA-Lite OSX App
===============
This application installs and monitors the status of KA-Lite.

It sits on the status menu of OS X and uses PyRun instead of the OS X built-in Python.


## Build Requirements:

* OS X 10.10 Yosemite
* git
* Xcode 6.1.x
* Run `setup.sh`.
    * KA-Lite repo on develop branch
    * PyRun==2.7


## Steps
TODO(cpauya): Refer to [Bundle KA Lite into PyRun](https://github.com/learningequality/installers/issues/4) for the initial script.

1. Run `setup.sh` which will:
    1.1. Download PyRun to the `pyrun-2.7` directory.
    1.2. Download the KA-Lite source to the `ka-lite` directory.
    1.3. Copy the `pyrun-2.7` and `ka-lite` directories to the `<xcode_source>/Resources/` folder.
    1.4. Build the `KA-Lite Monitor.app`.
    1.5. Build the `KA-Lite Monitor.dmg` package.
2. If you want to manually build the .app, Launch Xcode
    2.1. At the Project Navigator (left-pane), right-click on the Supporting Files folder and select Add Files to "KA Lite Monitor".
    2.2. Select the `pyrun-2.7` and `ka-lite` directories that were copied at the Resources folder.  Make sure to select "Create folder references."!
    2.3. Build the project to produce the .app.
3. To build the .dmg - refer to the README-FOR-DMG.md document or just run `setup.sh` as per above.