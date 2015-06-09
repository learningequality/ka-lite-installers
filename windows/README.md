KA Lite Installer for Windows
==========

This project provides a smoother way to install and run KA Lite in a Windows Machine.

---
#### This project was built using the following software:
* Inno Setup 5.5.3 [Download] (http://files.jrsoftware.org/is/5/)
* Microsoft Visual Studio Express 2012 [Download] (https://www.microsoft.com/en-us/download/details.aspx?id=34673)
* Git (note: install with the option to place the `git` executable in the path, so it can be run within `cmd`)

---
#### Instructions to update Microsoft Visual Studio 2012
###### Steps to update:
* Click on TOOLS menu
* Select Extensions and Updates... then another dialog will appear.
* Click on Update.

###### Install the downloaded update in your machine
* Click on BUILD.
* Select Build Solution.

---
#### Instructions to build "KALiteSetup.exe":
To build in Linux, first install `wine`.
* Clone this repository;
* Copy `ka-lite` folder from KA Lite's repository, to the root of this repository;
* Ensure the assessment items have been unpacked in the `ka-lite` directory.
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
##### To clone this repository, run the following line:
    git clone https://github.com/learningequality/installers.git
######
