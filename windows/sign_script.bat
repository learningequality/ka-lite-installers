@echo off
rem This script is a template for signing the windows installer.
rem You will need to get our primary certificate and our additional certificate files, and then
rem substitute them below where you see "PrimaryCertificate.p12" and "AdditionalCertificate.cert", respectively.
rem You will need to get the password for our primary certificate and substitute it where you see "YourPasswordHere".
rem Depending on your system, you may need to change the path to the signtool executable.
rem >>>>>>>>>> USAGE:
rem Once you have made the necessary substitutions run this script with one argument, the file that you wish to sign.
set filename=%1
set signtool_exe="C:\Program Files (x86)\Windows Kits\8.1\bin\x64\signtool.exe"
set signcmd=%signtool_exe% sign /f PrimaryCertificate.p12 /p YourPasswordHere /ac AdditionalCertificate.cert %filename%
echo "Running the command:"
echo %signcmd%
%signcmd%