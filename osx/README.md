KA-Lite OS X App
================
This folder contains the script and sources to build the installer for KA-Lite.

The application icon sits on the status menu of OS X and uses [PyRun](http://www.egenix.com/products/python/PyRun/) instead of the OS X built-in Python.


## System Requirements

* Mac OSX 10.10 Yosemite or later.
* Xcode 6.4.x or later.
* git
* wget
* [Packages](http://s.sudre.free.fr/Software/Packages/about.html) by Sudre.

## Steps to build the installer
There are two ways to build the installer, automated or manually.

1. To build automatically, run `build.sh` which will:  
    1.1. Create a `temp` directory (this is ignored in the .gitignore) and puts everything else inside it.  
    1.2. Download PyRun to the `/temp/pyrun-2.7/` directory.  
    1.3. Download the KA-Lite source to the `/temp/ka-lite/` directory.  
    1.4. Build the `KA-Lite.app` using `xcodebuild`.  
    1.5. Build the `KA-Lite.pkg` package.  The output can be found at the `/temp/output/KA-Lite.pkg`.  
2. To build the .pkg manually - refer to the [Packages](http://s.sudre.free.fr/Software/documentation/Packages/en/index.html) documentation.  


## Manually build and test the application using Xcode

1. Run `build.sh` so it will download the `ka-lite` repository and `pyrun`.
1. Launch Xcode
1. Build the project to produce the .app.

## Notes

1. Please note that this has been tested on Mac OSX 10.10 Yosemite and Mac OSX 10.11.1 El Capitan. It may run on older versions down to Mac OSX Mountain Lion 10.8 but we haven't tested it.
1. `build.sh` downloads the following:
    * KA-Lite repo on `develop` branch, or the specified repo.
    * PyRun version 2.7.
    * [Assessment](http://pantry.learningequality.org/downloads/ka-lite/) zip. 
1. You can optionally pass a ka-lite archive repo url as an argument in this format:

    > ./build.sh "https://github.com/learningequality/ka-lite/archive/0.16.x.zip" "http://pantry.learningequality.org/downloads/ka-lite/0.15/content/khan_assessment.zip"

    This is useful if you want to try a different fork or branch on your build.
    It defaults to the `develop` branch at "https://github.com/learningequality/ka-lite/archive/develop.zip".


## Changes on installer
 
 * Set environment variable `KALITE_PYTHON`.
 * Symlink `kalite` executable.
 * Unpack assessment items.
 * Bundle `KA-Lite.pkg` and `KA-Lite_Uninstall.tool` in `/Applications/KA-Lite/` directory.
 * `ka-lite` resources and `pyrun` are save in `/Users/Shared/`.


## Uninstaller
   
* `KA-Lite_Uninstall.tool` and `KA-Lite.app` are bundled in `/Applications/KA-Lite/` folder.  
* `KA-Lite_Uninstall.tool` do the following:
    * Checks the following list below even if it doesn't exist there.
    * Use to uninstall `KA-Lite.app` and it's dependencies. 

During uninstall it removes the following:
  
  * `KA-Lite.app` from `/Applications/KA-Lite/`.
  * `org.learningequality.kalite.plist` file in `/Library/LaunchAgents/`.
  * `kalite` executable from `/usr/bin/`. The old release symlink `kalite` executable to `/usr/bin/`.
  * `kalite` executable from `/usr/local/bin/`. For this release, we symlink `kalite` executable to `/usr/local/bin/`.
  * `KALITE_PYTHON` environment variable.
  * `kalite` folder from `/Users/Shared/`.
  * `KALITE_HOME` environment variable and `KA-Lite` data path.


## References

1. [??? How to use and build using packages] (http://s.sudre.free.fr/Software/documentation/Packages/en/index.html)
1. [??? Installing Tomcat on Mac OS X](http://www.joel.lopes-da-silva.com/2008/05/13/installing-tomcat-on-mac-os-x/)
1. [??? Using launchd](http://trac.buildbot.net/wiki/UsingLaunchd)
1. [??? HowTo: Set an Environment Variable in Mac OS X](http://www.dowdandassociates.com/blog/content/howto-set-an-environment-variable-in-mac-os-x/)