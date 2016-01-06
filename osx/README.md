KA Lite OS X Installer
======================
This folder contains the sources to build the OS X installer and application for KA Lite.

The application icon sits on the menu bar of OS X and uses [PyRun](http://www.egenix.com/products/python/PyRun/) to isolate the KA Lite environment from your system's [Python](https://www.python.org/) application.


## System Requirements

* Mac OS X 10.10 Yosemite or newer
* Xcode 6.1.x or 7.2
* git
* wget
* [Packages](http://s.sudre.free.fr/Software/Packages/about.html) by Stéphane Sudre
* [KA Lite](https://github.com/learningequality/ka-lite/wiki/Getting-started) - optional
* [VirtualBox](https://www.virtualbox.org) - optional, for sandboxed installation testing.


## General 

This folder contains the following:

1. `KA-Lite/` - the Xcode project files used to build the application.
2. `KA-Lite-Packages/` - the Packages project files used to build the .pkg package.
3. `release-docs/` - the documentation files that will be installed with the application.
4. `temp/` - created by the `build.sh` script as its temporary working folder.  This can be safely deleted.

We used the [Installer package with .pkg file extension](https://en.wikipedia.org/wiki/Installer_(OS_X)#Installer_package) for package distribution with a wizard-type GUI.


## Getting Started

Run the `build.sh` script which will download the KA Lite packages and other requirements for you:

1. Create a `temp` directory and puts everything else inside it.  This is ignored in the `.gitignore` so any changes will not affect the repository.
1. Download PyRun to the `temp/pyrun-2.7/` directory.  
1. Download the KA Lite source archive to the `temp/ka-lite/` directory.  
1. Build the `KA-Lite.app` using `xcodebuild`.  
1. Build the `KA-Lite.pkg` package using `packagesbuild`.  The output can be found at the `temp/output/KA-Lite.pkg`.  

This will take a long time to finish because the assessment items archive alone is 500MB+ in size.  There will be an output log for your monitoring.

Refer to the `build.sh` source for more comments and details.


## Installation of the built KA Lite package.

Open the built package from the Getting Started section at `temp/output/KA-Lite.pkg` to install KA Lite.

KA Lite will be installed in the `/Applications/KA-Lite/` folder along with the license, readme, and release notes documentation.

When testing package installations, we recommend you use VirtualBox for a clean environment.

**Note:** A computer restart is required to complete the install process, thus our suggestion to use VirtualBox.

Alternatively, you can also clone the [KA Lite](https://github.com/learningequality/ka-lite) repository and follow the [Getting Started](https://github.com/learningequality/ka-lite/wiki/Getting-started) instructions.  Then symlink the `bin/kalite` into your `/usr/local/bin/` folder so that it will be available in all of your Terminal sessions.  Lastly, set a `KALITE_PYTHON` environment variable to point to your Python executable.


## Uninstallation of the built KA Lite package.

Run the `ka-lite-remover.sh` to remove KA Lite.  It will confirm if you want to keep or delete your KA Lite data folder.  It will require your admin password to proceed.


## Use Packages to build and test the Installer

Before you can build the .pkg you need to run `build.sh` as per Getting Started above.

Afterwards, launch Packages and open `KA-Lite-Packages/KA-Lite.pkgproj`.  Select `Build and Run` in the `Build` menu to build and launch the .pkg installer.


## Use Xcode to build and test the Application

Make sure that you can run the `kalite` executable in your Terminal.  If not, you must install KA Lite as per the Installation section above.

Launch Xcode and open `KA-Lite/KA-Lite.xcodeproj`.  Build and run the project to produce the .app.


## Notes

1. Please note that this has been built and tested on Mac OS X 10.10 Yosemite and 10.11 El Capitan.  It may run on older versions down to 10.8 Mountain Lion but we haven't tested it.
1. `build.sh` downloads the following

    * KA Lite repo on `develop` branch, or the specified repo
    * PyRun version 2.7
    * [Assessment](http://pantry.learningequality.org/downloads/ka-lite/) zip - this can take a very long time because it's 500MB+ in size.  We suggest you keep a copy of this in `temp/assessment.zip` to save in build time.
1. You can optionally pass two arguments for the `build.sh` script:

    > ./build.sh \<ka-lite-archive-repository-url> \<assessment-zip-url>

    Example:

    > ./build.sh "https://github.com/learningequality/ka-lite/archive/0.16.x.zip" "http://pantry.learningequality.org/downloads/ka-lite/0.16/content/khan_assessment.zip"

    This is useful if you want to try a different fork or branch on your build.  The first argument defaults to the `develop` branch of the KA Lite repository at "https://github.com/learningequality/ka-lite/archive/develop.zip".
1. The installation process requires a computer restart to complete.


## References

1. [How to use and build using packages](http://s.sudre.free.fr/Software/documentation/Packages/en/index.html)
1. [OSX legacy packaging redux](http://matthew-brett.github.io/docosx/legacy_package_redux.html)
1. [Use of plist in "Installing Tomcat on Mac OS X"](http://www.joel.lopes-da-silva.com/2008/05/13/installing-tomcat-on-mac-os-x/)
1. [Using launchd](http://trac.buildbot.net/wiki/UsingLaunchd)
1. [HowTo: Set an Environment Variable in Mac OS X](http://www.dowdandassociates.com/blog/content/howto-set-an-environment-variable-in-mac-os-x/)