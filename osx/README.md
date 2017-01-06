KA Lite OS X Installer
======================
This contains the sources to build the OS X installer and application for KA Lite.

The application icon sits on the menu bar of OS X and uses PEX to isolate the KA Lite environment from your system's [Python](https://www.python.org/) application.  It has a preferences dialog for application settings and logs. 


## System Requirements

* Mac OS X 10.10 Yosemite or newer
* Xcode 6.1.x or 7.2
* git
* wget
* Python 2.7.11+
* pex
* [Packages](http://s.sudre.free.fr/Software/Packages/about.html) by Stéphane Sudre
* [KA Lite](https://github.com/learningequality/ka-lite/wiki/Getting-started) - optional but recommended
* [VirtualBox](https://www.virtualbox.org) - optional, for sandboxed installation testing.


## General 

This folder contains the following:

1. `KA-Lite/` - the Xcode project files used to build the application.
2. `KA-Lite-Packages/` - the Packages project files used to build the .pkg package.
3. `release-docs/` - the documentation files that will be installed with the application.
4. `temp/` - will be created by the `build.sh` script as its temporary working folder.  This can be safely deleted.

We used the [Installer package with .pkg file extension](https://en.wikipedia.org/wiki/Installer_(OS_X)#Installer_package) for package distribution with a wizard-type GUI.


## Getting Started

Run the `build.sh` script in your Terminal to build the .pkg package.  It will download the KA Lite packages and other requirements for you:

1. Create a `temp` directory and puts everything else inside it.  This is ignored in the `.gitignore` so any changes will not affect the repository. 
1. Download the KA Lite source archive to the `temp/ka-lite/` directory.  
1. Build the `KA-Lite.app` using `xcodebuild`.  
1. Build the `KA-Lite.pkg` package using `packagesbuild`.  The output can be found at the `temp/temp-output/KA-Lite.pkg`.
1. Build the 'KA-Lite-installer.dmg' file using 'create-dmg'. The output can be found at the 'temp/output/KA-Lite-installer.dmg'

This will take a long time to finish because the content pack archive alone is 500MB+ in size.  There will be an output log for your monitoring.

Refer to the `build.sh` source for details.


## Installation of the built KA Lite package.

This will require your admin password.

Open the built package from the Getting Started section at `temp/output/KA-Lite.pkg` and follow the prompts.  For the curious, you can see installation logs in the `Console` application, just filter the entries with "KA-Lite".

Click "Continue" when prompted about the "This package will run a program to determine if the software can be installed." message.

KA Lite will be installed in the `/Applications/KA-Lite/` folder along with the uninstall.tool, license, readme, release notes, and the support folder.  The `support` folder contains the English content pack archive, the python environment, and the scripts.

When testing locally-built packages, we recommend using VirtualBox for a clean environment.  Making an OS X Virtual Machine for VirtualBox is beyond the scope of this document but you can easily find references on the net.

**Note:** Make sure that the KA Lite application is not loaded during installation.


## Uninstallation of the installed KA Lite package.

This will require your admin password.

There are two ways to uninstall the KA Lite package:

1. Load the KA Lite application then click its menu bar icon and select the Preferences menu item.  In the Preferences dialog, click on the "Uninstall KA Lite" button.
1. Run the `/Applications/KA-Lite/KA-Lite_Uninstall.tool` in your Terminal to remove KA Lite.  It will confirm if you want to keep or delete your KA Lite data folder.


## Use Packages to build the KA Lite installer

Before you can use Packages to build the .pkg you need to run `build.sh` as per Getting Started above.  It will download the needed payloads for the package.

Afterwards, launch Packages and open `KA-Lite-Packages/KA-Lite.pkgproj`.  Select `Build and Run` in the `Build` menu to build and launch the .pkg installer.


## Use Xcode to build and test the Application

Make sure that you can run the `kalite` executable in your Terminal.  There are two ways to achieve this:

1. Follow the "Installation of the built KA Lite package" section.
2. Follow the "Cloning KA Lite..." section.

Launch Xcode and open `KA-Lite/KA-Lite.xcodeproj`.  Build and run the project to produce the .app and test it.


## Cloning KA Lite to test the OS X Application

Clone the [KA Lite](https://github.com/learningequality/ka-lite) repository and follow the [Getting Started](https://github.com/learningequality/ka-lite/wiki/Getting-started) instructions.  

Then symlink the `bin/kalite` into your `/usr/local/bin/` folder so that it will be available in all of your Terminal sessions.  

Lastly, set the `KALITE_PYTHON` environment variable in your Terminal to point to your Python executable.  Example: `launchctl setenv KALITE_PYTHON "/Users/juan/.virtualenvs/ka-lite/bin/python"`.  You must close the Terminal application and re-launch it for it to take effect.  You can check by running this in your Terminal: `env | grep KALITE_PYTHON`.

Obviously, this process is very useful if you want to run and test the OS X application based on your local repo of KA Lite.


## Notes

1. Please note that this has been built and tested on Mac OS X 10.10 Yosemite and 10.11 El Capitan.  It may run on older versions down to 10.8 Mountain Lion but we haven't tested it.
1. `build.sh` downloads the following

    * KA Lite repo on `0.17.x` branch, or the specified repo
    * Python 2.7.12
    * [English Content Packs archive](http://pantry.learningequality.org/downloads/ka-lite/0.17/content/contentpacks/en.zip) - this can take a very long time because it's 500MB+ in size.  We suggest you keep a copy somewhere and copy it in `temp/content/contentpacks/en.zip` to save in build time.
1. You can optionally pass two arguments for the `build.sh` script:

    > ./build.sh \<ka-lite-archive-repository-url> \<content-pack-zip-url>

    Example:

    > ./build.sh "https://github.com/learningequality/ka-lite/archive/0.17.x.zip" "http://pantry.learningequality.org/downloads/ka-lite/0.17/content/contentpacks/en.zip"

    This is useful if you want to try a different fork or branch on your build.  The first argument defaults to the `0.17.x` branch of the KA Lite repository at "https://github.com/learningequality/ka-lite/archive/0.17x.zip".


## References

1. [How to use and build using packages](http://s.sudre.free.fr/Software/documentation/Packages/en/index.html)
1. [OSX legacy packaging redux](http://matthew-brett.github.io/docosx/legacy_package_redux.html)
1. [Use of plist in "Installing Tomcat on Mac OS X"](http://www.joel.lopes-da-silva.com/2008/05/13/installing-tomcat-on-mac-os-x/)
1. [Using launchd](http://trac.buildbot.net/wiki/UsingLaunchd)
1. [HowTo: Set an Environment Variable in Mac OS X](http://www.dowdandassociates.com/blog/content/howto-set-an-environment-variable-in-mac-os-x/)