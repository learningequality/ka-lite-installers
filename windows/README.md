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
##### Steps to update:
* Click on TOOLS menu
* Select Extensions and Updates... then another dialog will appear.
* Click on Update.

---
#### Instructions to build "KALiteSetup.exe" in Windows:
* Clone the `ka-lite` repository.
* Clone this repository;
* Copy `ka-lite` folder from `ka-lite` repository, to the `installers/windows` of this repository;
* Run `installers/windows/make.vbs` and wait until the output file is built;
* The output file named "KALiteSetup-X.X.X.exe" will appear within this project folder.

---
#### To clone ka-lite and this repository, run the following line:
* git clone https://github.com/learningequality/ka-lite.git
* git clone https://github.com/learningequality/installers.git
####

---
##### Instructions to build "KALiteSetup-X.X.X.exe" in Linux:
First, install `wine`. Then in the base directory run the following commands:
```bash
> wine inno-compiler/ISCC.exe installer-source/KaliteSetupScript.iss
```
