KA-Lite OSX App
===============
This folder contains the script and sources to build the installer for KA-Lite.

The application icon sits on the status menu of OS X and uses [PyRun](http://www.egenix.com/products/python/PyRun/) instead of the OS X built-in Python.


## Requirements

* OS X 10.10 Yosemite
* git
* Xcode 6.1.x


## Steps to build the installer
There are two ways to build the installer, automated or manually.

1. To build automatically, run `setup.sh` which will:
    1.1. Create a `temp` directory (this is ignored in the .gitignore) and puts everything else inside it.
    1.2. Download PyRun to the `pyrun-2.7` directory.
    1.3. Download the KA-Lite source to the `ka-lite` directory.
    1.4. Copy the `pyrun-2.7` and `ka-lite` directories to the `<xcode_source>/Resources/` folder.
    1.5. Build the `KA-Lite Monitor.app` using `xcodebuild`.
    1.6. Build the `KA-Lite Monitor.dmg` package.  The output can be found at the `temp/output/KA-Lite Monitor.dmg`.
2. To build the .dmg manually - refer to the README-FOR-DMG.md document.

### To manually build and test the application

1. Run `setup.sh` so it will download the `ka-lite` repository and `pyrun`.
2. Launch Xcode
3. At the Project Navigator (left-pane), right-click on the Supporting Files folder and select Add Files to "KA Lite Monitor".
4. Select the `pyrun-2.7` and `ka-lite` directories that were copied at the Resources folder by `setup.sh` above.  Make sure to select "Create folder references."!
5. Build the project to produce the .app.


## Notes

1. The `setup-files` folder contains the files to be included on the dmg file.
1. The `ka-lite-pencil.ep` is the [Pencil](https://code.google.com/p/evoluspencil/) file to generate the background image of the dmg file.
1. `setup.sh` downloads the following

    * KA-Lite repo on `develop` branch
    * PyRun version 2.7
