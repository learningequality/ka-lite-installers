KA Lite Installer for Windows
==========

This project provides a smoother way to install and run KA Lite in a Windows Machine.

---
#### This project was built using the following software:
* Inno Setup 5.5.3 [Download] (http://files.jrsoftware.org/is/5/)
* Microsoft Visual Studio Community 2015 [Website] (https://www.visualstudio.com/)
* Git (note: install with the option to place the `git` executable in the path, so it can be run within `cmd`)

---
#### Instructions to build the GUI:
* Open `gui-source/KA Lite.sln` using Visual Studio.
* Click on the "Build" menu and then choose the "Build Solution" option.
* Copy the resulting `KA Lite.exe` from its output location to `gui-packed/KA Lite.exe`

Note: If you have made no changes to `gui-source`, you don't have to build `KA Lite.exe`. Just use the version in this repo.

Note: If you *do* make changes to anything in `gui-source`, be sure to build and commit `KA Lite.exe`.


---
#### Instructions to build "KALiteSetup.exe":
To build in Linux, first install `wine`.
* Clone this repository;
* Copy `ka-lite` folder from KA Lite's repository, to the root of this repository;
* Ensure the assessment items have been unpacked in the `ka-lite` directory.
* Follow the _Instructions to download pip dependency zip files_ above
* Create an empty db for distribution as per the section _Creating an Empty DB_
* Run `kalite manage collectstatic` to create the `ka-lite/static-libraries` directory; this is a work-around until the windows installer uses setuptools.
* Run the `compileymltojson` management command.
* Include built documentation in the appropriate directory -- `docs\_build\html`, but this can be configured. See `STATICFILES_DIRS` setting.
* In Windows, run the following command from this directory:
```
> make.vbs
```
* In Linux, run the following command in this directory using `wine`:
```bash
> wine inno-compiler/ISCC.exe installer-source/KaliteSetupScript.iss
```
* The output file named "KALiteSetup-X.X.X.exe" will appear within this project folder.


---
#### Instructions to download pip dependency zip files
* Clone the `ka-lite` repository.
* Clone this repository.
* Install `python-2.7.10.msi` at `/installer/windows/python-setup` directory.
* Make sure `python.exe` is in your path, or you will have to invoke it using an absolute path below.
* On your command line navigate to `ka-lite` directory that contain `setup.py`.
* Run this command `python.exe setup.py sdist --static` to download zip files .

On Linux, ensure you have python 2.7 installed, then:
* On your command line navigate to `ka-lite` directory that contain `setup.py`.
* Run this command `python setup.py sdist --static` to download zip files .

---
#### Creating an Empty DB
After installing `ka-lite`:
* Ensure the file `ka-lite/kalite/database/data.sqlite` doesn't already exist.
* Run the command `kalite manage syncdb`. You will see this prompt:

    You just installed Django's auth system, which means you don't have any superusers defined.
    Would you like to create one now? (yes/no):

* Choose "no".
* Run the command `kalite manage migrate`.
* This should create the file `ka-lite/kalite/database/data.sqlite`, which will be copied to the target system by the installer.

---
#### To clone ka-lite and this repository, run the following lines:
* git clone https://github.com/learningequality/ka-lite.git
* git clone https://github.com/learningequality/installers.git
