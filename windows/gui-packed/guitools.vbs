'This script sets a link at the windows startup folder for KA Lite. The options are 0, 1 and 2.

Dim value : value = WScript.Arguments(0)
Set oShell = CreateObject("WScript.Shell")
sPath = oShell.SpecialFolders("Startup")

' Detect the version of Windows.
Set SystemSet = GetObject("winmgmts:").InstancesOf("Win32_OperatingSystem") 
for each System in SystemSet
    WinMajorVersion = Left(System.Version, 1)
next

'Option 0 is to create the startup link at the windows startup folder.
If value = 0 Then
    
    Set oShortcut = oShell.CreateShortcut(sPath & "\KA Lite.lnk")
    oShortcut.TargetPath = oShell.CurrentDirectory & "\KA Lite.exe"
    oShortcut.WorkingDirectory = oShell.CurrentDirectory
    oShortcut.Save
   
'Option 1 is to delete the startup link at the window startup folder.   
ElseIf value = 1 Then

    Set objFSO = CreateObject("Scripting.FileSystemObject")
    If objFSO.FileExists(sPath & "\KA Lite.lnk") Then
        objFSO.DeleteFile(sPath & "\KA Lite.lnk")
    End if
    
'Option 2 is to check if the link exists in the windows startup folder. If it exists, the script return 0. It will return 1 if it doesn't exist.
ElseIf value = 2 Then

    Set objFSO = CreateObject("Scripting.FileSystemObject")
    If objFSO.FileExists(sPath & "\KA Lite.lnk") Then
        WScript.Quit(0)
    End if
    WScript.Quit(1)
 
 'Option 3 is to check if the server is running by finding the files where the pid's are stored.
ElseIf value = 3 Then

    Set objFSO = CreateObject("Scripting.FileSystemObject")
    If objFSO.FileExists(oShell.CurrentDirectory & "\ka-lite\kalite\runcherrypyserver.pid") Then
        WScript.Quit(0)
    End if
    If objFSO.FileExists(oShell.CurrentDirectory & "\ka-lite\kalite\cronserver.pid") Then
        WScript.Quit(0)
    End if
    WScript.Quit(1)

'Option 4 will add the system start task.
ElseIf value = 4 Then  
    Set objShell = CreateObject("Shell.Application")
    If WinMajorVersion >= 6 Then
        ' Windows Vista or greater
        runas = "runas"
    Else
        ' Windows XP or lower
        runas = ""
    End If
    objShell.ShellExecute "cmd.exe", "/c """ & oShell.CurrentDirectory & "\ka-lite\scripts\add_systemstart_task.bat""", "", runas, 1

'Option 5 will remove the system start task.    
ElseIf value = 5 Then
    Set objShell = CreateObject("Shell.Application")
    If WinMajorVersion >= 6 Then
        ' Windows Vista or greater
        runas = "runas"
    Else
        ' Windows XP or lower
        runas = ""
    End If
    objShell.ShellExecute "cmd.exe", "/c """ & oShell.CurrentDirectory & "\ka-lite\scripts\remove_systemstart_task.bat""", "", runas, 1
    
End If

WScript.Quit(2)




