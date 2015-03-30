Set oShell = WScript.CreateObject("WSCript.shell")
oShell.run "cmd /K title Building the installation package... |inno-compiler\ISCC.exe /cc installer-source\KaliteSetupScript.iss & exit"