@echo off
TITLE Adding task to start KA Lite at system start
schtasks /create /tn "KALite" /tr "\"%KALITE_SCRIPT_DIR%\kalite.bat\" start" /sc onstart /ru SYSTEM
