@echo off
setlocal
set PREV_KALITE_DIR=%1
set START_DIR=%~dp0

cd %PREV_KALITE_DIR%\ka-lite\kalite

for /f "tokens=1-2 delims==, " %%I in (version.py) do (
    if "%%I" == "MAJOR_VERSION" ( set major_version=%%J)
    if "%%I" == "MINOR_VERSION" ( set minor_version=%%J)
    if "%%I" == "PATCH_VERSION" ( set patch_version=%%J)
)
set major_version=%major_version:"=%
set minor_version=%minor_version:"=%
set patch_version=%patch_version:"=%

cd %START_DIR%

set final_version=%major_version%.%minor_version%.%patch_version%

echo %final_version% > prev_version.temp
exit
