KA-Lite OSX App
===============
This application installs and monitors the status of KA-Lite.

It sits on the status menu of OS X and uses PyRun instead of the OS X built-in Python.


## Build Requirements:

* OS X 10.10 Yosemite
* Xcode 6.1.x
* KA-Lite
* PyRun==2.7


## Steps
TODO(cpauya): Refer to [Bundle KA Lite into PyRun](https://github.com/learningequality/installers/issues/4) for the initial script.

1. Run `setup.sh` which will:
	1.1. Create the download the KA-Lite source to the `ka-lite` directory.
	1.1. Download PyRun to the `pyrun-2.7` directory.
1. Build the project in Xcode to produce the .app.