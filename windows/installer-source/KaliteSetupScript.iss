#define MyAppName "KA Lite"
#define MyAppPublisher "Foundation for Learning Equality"
#define MyAppURL "http://learningequality.org/"
#define MyAppExeName "KA Lite.exe"

#define getKALiteVersion() \
    Local[1] = Exec(SourcePath+"\getversion.bat") == 0 ? StringChange(FileRead(FileOpen(SourcePath+"\version.temp")), " ", "") : "null"

#define TargetVersion = getKALiteVersion();

#expr DeleteFile(SourcePath+"\version.temp")

[Setup]
AppId={#MyAppName}-{#MyAppPublisher}
AppName={#MyAppName}
AppVersion={#TargetVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
LicenseFile=..\ka-lite\LICENSE
OutputDir=..\
OutputBaseFilename=KALiteSetup-{#TargetVersion}
SetupIconFile=logo48.ico
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin
UsePreviousAppDir=yes
ChangesEnvironment=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\ka-lite\*"; DestDir: "{app}\ka-lite"; Excludes: ".KALITE_SOURCE_DIR"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\ka-lite\content\*"; DestDir: "{app}\ka-lite\content"; Flags: ignoreversion recursesubdirs createallsubdirs uninsneveruninstall
Source: "..\gui-packed\KA Lite.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\gui-packed\guitools.vbs"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\gui-packed\images\logo48.ico"; DestDir: "{app}\images"; Flags: ignoreversion
Source: "..\python-setup\*"; DestDir: "{app}\python-setup"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "Uninstall KA Lite"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon ; IconFilename: "{app}\images\logo48.ico"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: shellexec postinstall skipifsilent

[Dirs]
Name: "{app}\"; Permissions: everyone-modify


[InstallDelete]
Type: Files; Name: "{app}\ka-lite\kalite\updates\utils.*"

[UninstallDelete]
Type: filesandordirs; Name: "{app}\ka-lite\python-packages"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\ab_testing"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\basetests"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\caching"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\central"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\coachreports"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\config"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\contact"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\control_panel"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\contentload"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\distributed"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\django_cherrypy_wsgiserver"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\dynamic_assets"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\facility"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\faq"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\foo"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\i18n"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\khanload"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\knowledgemap"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\loadtesting"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\main"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\management"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\playlist"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\registration"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\remoteadmin"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\securesync"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\shared"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\static"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\store"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\student_testing"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\templatetags"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\templates"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\tests"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\testing"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\topic_tools"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\updates"
Type: filesandordirs; Name: "{app}\ka-lite\kalite\utils"
Type: Files; Name: "{app}\ka-lite\kalite\*.pyc"
Type: Files; Name: "{userstartup}\KA Lite.lnk"
Type: Files; Name: "{app}\CONFIG.dat"

[Code]
var
  installFlag : boolean;
  startupFlag : string;
  ServerInformationPage : TInputQueryWizardPage;
  StartupPage : TInputOptionWizardPage;
  isUpgrade : boolean;
  stopServerCode: integer;
  removeOldGuiTool: integer;
  uninstallError: integer;
  saveDatabaseTemp : integer;
  cleanOldKaliteFolder : integer;
  restoreDatabaseTemp : integer;
  forceCancel : boolean;
  prevVerStr : string;
  prevAppBackupDir : string;
  runGitmigrate : boolean;

procedure InitializeWizard;
begin
    isUpgrade := False;
    forceCancel := False;
    runGitmigrate := False;
    
    if WizardForm.PrevAppDir <> nil then
    begin
        ShellExec('open', 'taskkill.exe', '/F /T /im "KA Lite.exe"', '', SW_HIDE, ewWaitUntilTerminated, stopServerCode);
        ShellExec('open', 'tskill.exe', '"KA Lite"', '', SW_HIDE, ewWaitUntilTerminated, stopServerCode);
        Exec(ExpandConstant('{cmd}'),'/C ka-lite\bin\windows\kalite.bat stop', WizardForm.PrevAppDir, SW_HIDE, ewWaitUntilTerminated, stopServerCode);
        Exec(ExpandConstant('{cmd}'),'/C del winshortcut.vbs', WizardForm.PrevAppDir, SW_HIDE, ewWaitUntilTerminated, removeOldGuiTool);
    end;
    
    // Server data
    ServerInformationPage := CreateInputQueryPage(wpSelectDir,
    'Server Information', 'General data',
    'Please specify the server name and a description, then click Next. (you can leave blank both fields if you want to use the default server name or if you do not want to insert a description)');
    ServerInformationPage.Add('Server name:', False);
    ServerInformationPage.Add('Server description:', False);

    // Run at windows startup.
    StartupPage := CreateInputOptionPage(ServerInformationPage.ID,
    'Server Configuration', 'Startup configuration',
    'The server can run automatically. You may choose one of the following options:', True, False);
    StartupPage.Add('Run the server at windows startup');
    StartupPage.Add('Run the server when this user logs in');
    StartupPage.Add('Do not run the server at startup.');
    StartupPage.SelectedValueIndex := 2;
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  if forceCancel = True then
  begin
    Confirm := False;
  end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
    result := False;
    if isUpgrade = True then
    begin
        if PageID = ServerInformationPage.ID then
        begin
            result := True;
        end;
        if PageID = wpSelectDir then
        begin
            result := True;
        end;
    end;
end;

procedure RemoveOldInstallation(targetPath : String);
begin
    WizardForm.Hide;
    if Not Exec(ExpandConstant('{cmd}'),'/C ( dir /b "unins***.exe" | findstr /r "unins[0-9][0-9][0-9].exe" ) > tempu & ( for /f "delims=" %A in ( tempu ) do call %A /SILENT /SUPPRESSMSGBOXES ) & del tempu', targetPath, SW_HIDE, ewWaitUntilTerminated, uninstallError) then
    begin
        Exec(ExpandConstant('{cmd}'),'/C mkdir '+ExpandConstant('{tmp}')+'\ka-lite\kalite\database & xcopy /y /s ka-lite\kalite\database\data.sqlite '+ExpandConstant('{tmp}')+'\ka-lite\kalite\database', targetPath, SW_HIDE, ewWaitUntilTerminated, saveDatabaseTemp);
        Exec(ExpandConstant('{cmd}'),'/C cd .. & del /q "'+targetPath+'\*" & for /d %x in ( "'+targetPath+'\*" ) do @rd /s /q "%x"', targetPath, SW_HIDE, ewWaitUntilTerminated, cleanOldKaliteFolder);
        Exec(ExpandConstant('{cmd}'),'/C mkdir ka-lite\kalite\database & xcopy /y /s '+ExpandConstant('{tmp}')+'\ka-lite\kalite\database\data.sqlite ka-lite\kalite\database', targetPath, SW_HIDE, ewWaitUntilTerminated, restoreDatabaseTemp);
    end;
    WizardForm.Show;
end;

{ Get the previous version number by checking the uninstall key registry values. }
{ IS writes quite a bit of information to the registry by default: https://github.com/jrsoftware/issrc/blob/5203240a7de9b83c5432bee0b5b09d467869a02b/Projects/Install.pas#L434 }
procedure GetPreviousVersion;
var
    subkey : String;
begin
    subkey := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\KA Lite-Foundation for Learning Equality_is1';
    prevVerStr := ''
    { 32-bit programs have a virtualized registry on 64-bit windows. So check all possible root keys. }
    if Not RegQueryStringValue(HKLM, subkey, 'DisplayVersion', prevVerStr) then
    begin
        if Not RegQueryStringValue(HKCU, subkey, 'DisplayVersion', prevVerStr) then
        begin
            if IsWin64 then
            begin
                if Not RegQueryStringValue(HKLM64, subkey, 'DisplayVersion', prevVerStr) then
                begin
                    if Not RegQueryStringValue(HKCU64, subkey, 'DisplayVersion', prevVerStr) then
                    begin
                        { Couldn't determine the previous version, so prevVerStr is '' }
                    end;
                end;
            end;
        end;
    end;
end;

procedure ConfirmUpgradeDialog;
begin
    if MsgBox('We have detected an existing KA Lite installation; would you like to upgrade?', mbInformation,  MB_YESNO or MB_DEFBUTTON1) = IDYES then
    begin
        isUpgrade := True;
    end
    else if MsgBox('Installing fresh will delete all of your existing data; is this what you really want to do?', mbInformation,  MB_YESNO or MB_DEFBUTTON2) = IDYES then
    begin
        isUpgrade := False;
    end
    else
    begin
        isUpgrade := True;
    end;
end;

procedure Backup013Files;
var
    prevDBDir, prevContentDir: String;
    resCode: integer;
begin
    { Copy the old database and content folders, preserving the dir structure, then after installing then new files... }
    { ...run gitmigrate management command and delete the old stuff. }
    prevAppBackupDir := ExpandConstant('{tmp}') + '\prev-ka-lite';  // Expand this when we use it, instead of earlier.
    prevDBDir := WizardForm.PrevAppDir + '\ka-lite\kalite\database';
    prevContentDir := WizardForm.PrevAppDir + '\ka-lite\content';

    if Not ForceDirectories(prevAppBackupDir + '\kalite\') then
    begin
        MsgBox('Fatal error' #13#13 'Failed to create backup directories at: ' + prevAppBackupDir, mbError, MB_OK);
        forceCancel := True;
        WizardForm.Close;
    end;

    MsgBox('Setup will now copy your prior user data for migration. If you have a lot of data, this may take some time!', mbInformation, MB_OK);

    Exec(ExpandConstant('{cmd}'), '/S /C "xcopy "' + prevDBDir + '" "' + prevAppBackupDir + '\kalite\database\" /E "', '', SW_HIDE, ewWaitUntilTerminated, resCode);
    if resCode <> 0 then
    begin
        MsgBox('Fatal error' #13#13 'Failed to backup database directory.', mbError, MB_OK);
        forceCancel := True;
        WizardForm.Close;
    end;
    Exec(ExpandConstant('{cmd}'), '/S /C "xcopy "' + prevContentDir + '" "' + prevAppBackupDir + '\content\" /E"', '', SW_HIDE, ewWaitUntilTerminated, resCode);
    if resCode <> 0 then
    begin
        MsgBox('Fatal error' #13#13 'Failed to backup content directory.', mbError, MB_OK);
        forceCancel := True;
        WizardForm.Close;
    end;

    runGitmigrate := True;
end;

procedure HandleUpgrade(targetPath : String);
begin
    GetPreviousVersion;
    if FileExists(targetPath + '\ka-lite\kalite\database\data.sqlite') then
    begin
        ConfirmUpgradeDialog;
        if Not isUpgrade then
        begin
            if Not DeleteFile(targetPath + '\ka-lite\kalite\database\data.sqlite') then
            begin
                MsgBox('Error' #13#13 'Failed to delete the old database as requested; aborting the install.', mbError, MB_OK);
                forceCancel := True;
                WizardForm.Close;
            end;
        end
        else
        begin
            { This is where version-specific migration stuff should happen. }
            if CompareStr(prevVerStr, '0.13.99') < 0 then
            begin
                if CompareStr('{#TargetVersion}', '0.14.0') >= 0 then
                begin
                    Backup013Files;
                end;
            end;
        end;
    { forceCancel will be true if something went awry in Backup013Files... abort instead of trampling the user's data. }
    if Not forceCancel then
        RemoveOldInstallation(targetPath);
    end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
    result := True;

    if CurPageID = wpLicense then
    begin
        if WizardForm.PrevAppDir <> nil then
            HandleUpgrade(WizardForm.PrevAppDir);
    end;
    
    if CurPageID = wpSelectDir then
    begin
        { Unclear what the logic here is. This is only executed if HandleUpgrade was not previously run. }
        if Not isUpgrade then
            HandleUpgrade(ExpandConstant('{app}'));
    end;
end;

procedure HandlePythonSetup;
var
    installPythonErrorCode : Integer;
begin
    if(MsgBox('Python error' #13#13 'Python 2.7.9+ is required to install KA Lite on Windows; do you wish to first install Python 2.7.10, before continuing with the installation of KA Lite?', mbConfirmation, MB_YESNO) = idYes) then
    begin
        ExtractTemporaryFile('python-2.7.10.msi');
        ShellExec('open', ExpandConstant('{tmp}')+'\python-2.7.10.msi', '', '', SW_SHOWNORMAL, ewWaitUntilTerminated, installPythonErrorCode);
    end
    else begin
        MsgBox('Error' #13#13 'You must have Python 2.7.9+ installed to proceed! Installation will now exit.', mbError, MB_OK);
        forceCancel := True;
        WizardForm.Close;
    end;
end;

{ Used in GetPipPath below }
const
    DEFAULT_PATH = '\Python27\Scripts\pip.exe';

{ Returns the path of pip.exe on the system. }
{ Tries several different locations before prompting user. }
function GetPipPath: string;
var
    path : string;
    i : integer;
begin
    for i := Ord('C') to Ord('H') do
    begin
        path := Chr(i) + ':' + DEFAULT_PATH;
        if FileExists(path) then
        begin
            Result := path;
            exit;
        end;
    end;
    MsgBox('Could not find pip.exe. Please select the location of pip.exe to continue installation.', mbInformation, MB_OK);
    if GetOpenFileName('Please select pip.exe', path, '', 'All files (*.*)|*.*', 'exe') then
    begin
        Result := path;
    end
    else begin
        MsgBox('Fatal error'#13#13'Please install pip and try again.', mbError, MB_OK);
        forceCancel := True;
        Result := '';
    end;
end;

procedure HandlePipSetup;
var
    PipCommand: string;
    PipPath: string;
    ErrorCode: integer;

begin
    PipPath := GetPipPath;
    if PipPath = '' then
        exit;
    PipCommand := 'install "' + ExpandConstant('{app}\ka-lite\dist\ka-lite-static-')  + '{#TargetVersion}' + '.zip"';

    MsgBox('Setup will now unpack dependencies for your installation.', mbInformation, MB_OK);
    if not ShellExec('open', PipPath, PipCommand, '', SW_HIDE, ewWaitUntilTerminated, ErrorCode) then
    begin
      MsgBox('Critical error.' #13#13 'Dependencies have failed to install. Error Number: ' + IntToStr(ErrorCode), mbInformation, MB_OK);
      forceCancel := True;
      WizardForm.Close;
    end;
end;

function InitializeSetup(): Boolean;
var
  PythonVersionCodeCheck: integer;
  killErrorCode: integer;
begin
    installFlag:=true;
    Result := true;
    startupFlag:=''; 
  
    ShellExec('open', 'taskkill.exe', '/F /T /im "KA Lite.exe"', '', SW_HIDE, ewWaitUntilTerminated, killErrorCode)
    ShellExec('open', 'tskill.exe', ' "KA Lite"', '', SW_HIDE, ewWaitUntilTerminated, killErrorCode);

    RegDeleteValue(HKCU, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run', ExpandConstant('{#MyAppName}'));
   
    if ShellExec('open', 'python.exe','-c "import sys; (sys.version_info >= (2, 7, 9,) and sys.version_info < (3,) and sys.exit(0)) or sys.exit(1)"', '', SW_HIDE, ewWaitUntilTerminated, PythonVersionCodeCheck) then
    begin
        if PythonVersionCodeCheck = 1 then
        begin
            HandlePythonSetup();
        end;
    end
    else 
    begin
        HandlePythonSetup();
    end;  
end;

function InitializeUninstall(): Boolean;
var
ErrorCode: Integer;
begin
  ShellExec('open', 'taskkill.exe', '/F /T /im "KA Lite.exe"', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
  ShellExec('open', 'tskill.exe', '"KA Lite"', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
  ShellExec('open', ExpandConstant('{app}') + '\ka-lite\bin\windows\kalite.bat stop', '', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
  result := True;
end;

{ Runs the gitmigrate management command introduced in 0.14 on the backup of a 0.13 installation }
procedure DoGitMigrate;
var
    retCodeContent, retCodeDB, retCode : integer;
begin
    MsgBox('Migrating old data to current user''s %USERPROFILE%\.kalite\ directory.', mbInformation, MB_OK);
    Exec(ExpandConstant('{cmd}'), '/S /C "mkdir "%USERPROFILE%\.kalite""', '', SW_SHOW, ewWaitUntilTerminated, retCode);
    Exec(ExpandConstant('{cmd}'), '/S /C "xcopy "' + prevAppBackupDir + '\content" "%USERPROFILE%\.kalite\content\" /E /Y"', '', SW_SHOW, ewWaitUntilTerminated, retCodeContent);
    Exec(ExpandConstant('{cmd}'), '/S /C "xcopy "' + prevAppBackupDir + '\kalite\database" "%USERPROFILE%\.kalite\database\" /E /Y"', '', SW_SHOW, ewWaitUntilTerminated, retCodeDB);
    if (retCodeContent <> 0) or (retCodeDB <> 0) then
    begin
        Exec(ExpandConstant('{cmd}'), '/S /C "xcopy "' + prevAppBackupDir + '" "' + ExpandConstant('{app}') + '\kalite-backup\" /E /Y"', '', SW_SHOW, ewWaitUntilTerminated, retCode);
        MsgBox('Unable to migrate your data. Your data is still backed up at the directory: ' + ExpandConstant('{app}') + '\kalite-backup', mbError, MB_OK);
    end;
end;

{ Completes the setup with bundled empty database file. }
procedure DoSetup;
var
    setupCommand: string;
    retCode: integer;
begin
    { Copy the bundled empty db to the proper location. }
    Exec(ExpandConstant('{cmd}'), '/S /C "xcopy "' + ExpandConstant('{app}') + '\ka-lite\kalite\database" "%USERPROFILE%\.kalite\database\" /E /Y"', '', SW_HIDE, ewWaitUntilTerminated, retCode);
    MsgBox('Setup will now configure the database. This operation may take a few minutes. Please be patient.', mbInformation, MB_OK);
    setupCommand := 'kalite manage setup --noinput --hostname="'+ServerInformationPage.Values[0]+'" --description="'+ServerInformationPage.Values[1]+'"';
    if Not ShellExec('open', 'python.exe', setupCommand, ExpandConstant('{app}')+'\ka-lite\bin', SW_HIDE, ewWaitUntilTerminated, retCode) then
    begin
        MsgBox('Critical error.' #13#13 'Setup has failed to initialize the database; aborting the install.', mbInformation, MB_OK);
        forceCancel := True;
        WizardForm.Close;
    end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  StartupCode: integer;
  moveKaliteFolderTemp: integer;
  moveContentFolderTemp: integer;
  cleanKaliteFolder: integer;
  restoreKaliteFolder: integer;
  restoreContentFolder: integer;
  informationBoxFlagged: boolean;

begin
    if CurStep = ssInstall then
    begin
        informationBoxFlagged :=False;
        
        ShellExec('open', 'taskkill.exe', '/F /T /im "KA Lite.exe"', '', SW_HIDE, ewWaitUntilTerminated, stopServerCode);
        ShellExec('open', 'tskill.exe', '"KA Lite"', '', SW_HIDE, ewWaitUntilTerminated, stopServerCode);
        Exec(ExpandConstant('{cmd}'),'/C ka-lite\bin\windows\kalite.bat stop', ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, stopServerCode);
        Exec(ExpandConstant('{cmd}'),'/C del winshortcut.vbs', ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, removeOldGuiTool);
    
        if DirExists(ExpandConstant('{app}') + '\kalite') then
        begin
            MsgBox('KA Lite old data structure' #13#13 'Setup detected that you have the old file structure. Setup will now move data to update the structure. Please be patient; this may take some time.', mbInformation, MB_OK);
            informationBoxFlagged :=True;      
            Exec(ExpandConstant('{cmd}'),'/C mkdir '+ExpandConstant('{tmp}')+'\ka-lite\kalite & xcopy /y /s kalite\* '+ExpandConstant('{tmp}')+'\ka-lite\kalite', ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, moveKaliteFolderTemp);      
        end; 
      
        if DirExists(ExpandConstant('{app}') + '\content') then
        begin
            if Not informationBoxFlagged then
            begin
                MsgBox('KA Lite old data structure' #13#13 'Setup detected that you have the old file structure. Setup will now move data to update the structure. Please be patient; this may take some time.', mbInformation, MB_OK);
                informationBoxFlagged :=True;
            end;      
            Exec(ExpandConstant('{cmd}'),'/C mkdir '+ExpandConstant('{tmp}')+'\ka-lite\content & xcopy /y /s content\* '+ExpandConstant('{tmp}')+'\ka-lite\content', ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, moveContentFolderTemp);      
        end;      
    
        if informationBoxFlagged then
        begin
            Exec(ExpandConstant('{cmd}'),'/C cd .. & del /q "'+ExpandConstant('{app}')+'\*" & for /d %x in ( "'+ExpandConstant('{app}')+'\*" ) do @rd /s /q "%x"', ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, cleanKaliteFolder);
    
            if DirExists(ExpandConstant('{tmp}')+'\ka-lite\kalite') then
            begin
                Exec(ExpandConstant('{cmd}'),'/C mkdir ka-lite\kalite & xcopy /y /s '+ExpandConstant('{tmp}')+'\ka-lite\kalite\* ka-lite\kalite', ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, restoreKaliteFolder);
            end;

            if DirExists(ExpandConstant('{tmp}')+'\ka-lite\content') then
            begin
                Exec(ExpandConstant('{cmd}'),'/C mkdir ka-lite\content & xcopy /y /s '+ExpandConstant('{tmp}')+'\ka-lite\content\* ka-lite\content', ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, restoreContentFolder);
            end;
        end;
        
    end;

    if CurStep = ssPostInstall then
    begin
        if installFlag then
        begin
            HandlePipSetup();

            { Add KALITE_ROOT_DATA_PATH to environment variables. A workaround for setting kalite.ROOT_DATA_PATH }
            { In the future, the windows installer should use setuptools to avoid OS-dependent workarounds like this. }
            RegWriteStringValue(
                HKLM,
                'System\CurrentControlSet\Control\Session Manager\Environment',
                'KALITE_ROOT_DATA_PATH',
                ExpandConstant('{app}\ka-lite\')
            );

            { Migrate old database if applicable, otherwise create a new one }
            if runGitmigrate and Not forceCancel then
            begin
                DoGitMigrate;
            end
            else if Not forceCancel then
            begin
                DoSetup;
            end;
      
            if StartupPage.SelectedValueIndex = 0 then
            begin
                if ShellExec('open','guitools.vbs','4', ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, StartupCode) then
                begin
                    if Not SaveStringToFile(ExpandConstant('{app}')+'\CONFIG.dat', 'RUN_AT_STARTUP:TRUE;' + #13#10, False) then
                    begin
                        MsgBox('Configuration file error.' #13#13 'Setup has failed to add the entry in the configuration file to run KA Lite at Windows startup. The installation may proceed and you can set this option later while using KA Lite.', mbError, MB_OK);
                    end;
                end
                else begin
                    MsgBox('GUI tools error.' #13#13 'Setup has failed to register a task to run KA Lite at Windows startup. The installation may proceed and you can set this option later while using KA Lite.', mbError, MB_OK);
                end;      
            end
            else if StartupPage.SelectedValueIndex = 1 then
            begin
                if ShellExec('open', 'guitools.vbs', '0', ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, StartupCode) then
                begin
                    if Not SaveStringToFile(ExpandConstant('{app}')+'\CONFIG.dat', 'RUN_AT_USER_LOGIN:TRUE;' + #13#10, False) then
                    begin
                        MsgBox('Configuration file error.' #13#13 'Setup has failed to add the entry in the configuration file to run KA Lite on user login. The installation may proceed and you can set this option later while using KA Lite.', mbError, MB_OK);
                    end;
                end
                else begin
                    MsgBox('GUI tools error.' #13#13 'Setup has failed to add the shortcut at the startup folder to run KA Lite on user login. The installation may proceed and you can set this option later while using KA Lite.', mbError, MB_OK);
                end;
            end;
        end;
    end;
    
end;