KA-Lite OSX App
===============
This folder contains the script and sources to build the installer for KA-Lite.

The application icon sits on the status menu of OS X and uses [PyRun](http://www.egenix.com/products/python/PyRun/) instead of the OS X built-in Python.


## System Requirements

* Mac OSX 10.10 Yosemite
* git
* Xcode 6.1.x
* wget

## Steps to build the installer
There are two ways to build the installer, automated or manually.

1. To build automatically, run `setup.sh` which will:  
    1.1. Create a `temp` directory (this is ignored in the .gitignore) and puts everything else inside it.  
    1.2. Download PyRun to the `temp/pyrun-2.7` directory.  
    1.3. Download the KA-Lite source to the `temp/ka-lite` directory.  
    1.4. Copy the `pyrun-2.7` directory to the `<xcode_source>/Resources/` folder.  
    1.5. Build the `KA-Lite Monitor.app` using `xcodebuild`.  
    1.6. Build the `KA-Lite Monitor.dmg` package.  The output can be found at the `temp/output/KA-Lite Monitor.dmg`.  
2. To build the .dmg manually - refer to the README-FOR-DMG.md document.  


## Manually build and test the application using Xcode

1. Run `setup.sh` so it will download the `ka-lite` repository and `pyrun`.
2. Launch Xcode
3. Build the project to produce the .app.


## Notes

1. Please note that this has been tested on Mac OSX 10.10 Yosemite.  It may run on older versions down to Mac OSX Mountain Lion 10.8 but we haven't tested it.
1. The `setup-files` folder contains the files to be included on the dmg file.
1. The `ka-lite-pencil.ep` is the [Pencil](https://code.google.com/p/evoluspencil/) file to generate the background image of the dmg file.
1. `setup.sh` downloads the following

    * KA-Lite repo on `develop` branch, or the specified repo
    * PyRun version 2.7
    * Assessment zip

1. You can optionally pass a ka-lite archive repo and assessment url as an arguments like these samples:

    > ./setup.sh "https://github.com/learningequality/ka-lite/archive/0.15.x.zip"

    > ./setup.sh "https://github.com/learningequality/ka-lite/archive/0.15.x.zip" "https://learningequality.org/downloads/ka-lite/0.15/content/assessment.zip"

    These are useful if you want to try a different fork or branch on your build.
    It default to the `develop` branch at "https://github.com/learningequality/ka-lite/archive/develop.zip" if you don't specify the first argument. The second argument will also default to https://learningequality.org/downloads/ka-lite/0.14/content/assessment.zip.


## References

1. [??? Installing Tomcat on Mac OS X](http://www.joel.lopes-da-silva.com/2008/05/13/installing-tomcat-on-mac-os-x/)
1. [??? Using launchd](http://trac.buildbot.net/wiki/UsingLaunchd)
1. [??? HowTo: Set an Environment Variable in Mac OS X](http://www.dowdandassociates.com/blog/content/howto-set-an-environment-variable-in-mac-os-x/)