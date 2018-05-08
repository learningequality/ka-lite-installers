@echo off
rem Execute python based on machine architecture.
:Check_Architecture
if /i "%processor_architecture%"=="x86" (
    IF NOT DEFINED PROCESSOR_ARCHITEW6432 (
        msiexec /i "python-2.7.13.msi" /passive

    ) ELSE (
        msiexec /i "python-2.7.13.amd64.msi" /passive
    )           
) else (
        msiexec /i "python-2.7.13.amd64.msi" /passive
)