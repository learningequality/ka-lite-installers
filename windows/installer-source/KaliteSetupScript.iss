#define MyAppName "KA Lite"
#define MyAppPublisher "Foundation for Learning Equality"
#define MyAppURL "http://learningequality.org/"
#define MyAppExeName "KA Lite.exe"

#define getKALiteVersion() \
    Local[1] = GetEnv("KALITE_BUILD_VERSION")

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
Source: "..\ka_lite_static-*.whl"; DestDir: "{app}\ka-lite"
Source: "..\en.zip"; DestDir: "{app}"
Source: "..\scripts\*.bat"; DestDir: "{app}\ka-lite\scripts\"
Source: "..\gui-packed\KA Lite.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\gui-packed\guitools.vbs"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\gui-packed\images\logo48.ico"; DestDir: "{app}\images"; Flags: ignoreversion
Source: "..\python-setup\*"; DestDir: "{app}\python-setup"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\images\logo48.ico"
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon ; IconFilename: "{app}\images\logo48.ico"

[Dirs]
Name: "{app}\"; Permissions: everyone-readexec

[InstallDelete]
Type: Files; Name: "{app}\*"

[UninstallDelete]
Type: filesandordirs; Name: "{app}\ka-lite*"
Type: files; Name: "{userstartup}\KA Lite.lnk"
Type: files; Name: "{app}\CONFIG.dat"

[Code]
function GetPreviousVersion : String; Forward;

var
  installFlag : boolean;
  startupFlag : string;
  ServerInformationPage : TInputQueryWizardPage;
  StartupOptionsPage : TOutputMsgWizardPage;
  isUpgrade : boolean;
  stopServerCode: integer;
  removeOldGuiTool: integer;
  uninstallError: integer;
  saveDatabaseTemp : integer;
  cleanOldKaliteFolder : integer;
  restoreDatabaseTemp : integer;
  forceCancel : boolean;

procedure InitializeWizard;
begin
    isUpgrade := False;
    forceCancel := False;

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

    StartupOptionsPage := CreateOutputMsgPage(ServerInformationPage.ID,
        'Startup options', 'Please read the following important information.',
        'In prior versions of KA Lite you could choose to start the server or task-tray program automatically during installation.' #13#13
        'This is no longer possible during installation, but you can set these options using the task-tray program after installation finishes.' #13#13
        'To enable or disable these features, start the task-tray program and right click on it to find a list of options.'
    )
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
function GetPreviousVersion : String;
var
    subkey : String;
begin
    subkey := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\KA Lite-Foundation for Learning Equality_is1';
    result := '';
    { 32-bit programs have a virtualized registry on 64-bit windows. So check all possible root keys. }
    if Not RegQueryStringValue(HKLM, subkey, 'DisplayVersion', result) then
    begin
        if Not RegQueryStringValue(HKCU, subkey, 'DisplayVersion', result) then
        begin
            if IsWin64 then
            begin
                if Not RegQueryStringValue(HKLM64, subkey, 'DisplayVersion', result) then
                begin
                    if Not RegQueryStringValue(HKCU64, subkey, 'DisplayVersion', result) then
                    begin
                        { Couldn't determine the previous version, so result is '' }
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

{ Copy files a la the gitmigrate management command, but use native windows executables instead. }
{ We assume the installing user is the main user of the app, so content goes into that user's .kalite dir}
procedure DoGitMigrate;
var
    retCodeContent, retCodeDB, retCode : integer;
begin
    MsgBox('Migrating old data to current user''s %USERPROFILE%\.kalite\ directory.', mbInformation, MB_OK);
    Exec(ExpandConstant('{cmd}'), '/S /C "mkdir "%USERPROFILE%\.kalite""', '', SW_SHOW, ewWaitUntilTerminated, retCode);
    Exec(ExpandConstant('{cmd}'), '/S /C "xcopy "' + WizardForm.PrevAppDir + '\ka-lite\content" "%USERPROFILE%\.kalite\content\" /Y"', '', SW_SHOW, ewWaitUntilTerminated, retCodeContent);
    Exec(ExpandConstant('{cmd}'), '/S /C "xcopy "' + WizardForm.PrevAppDir + '\ka-lite\kalite\database" "%USERPROFILE%\.kalite\database\" /Y"', '', SW_SHOW, ewWaitUntilTerminated, retCodeDB);
    if (retCodeContent <> 0) or (retCodeDB <> 0) then
    begin
        MsgBox('Something went wrong! Unable to backup your data. Continuing installation.', mbError, MB_OK);
    end;
end;

{ In version 0.13.x or below, users who selected the "Run KA Lite at system startup" option ran KA Lite as the }
{ SYSTEM user. Starting in 0.16.0, it will be run as the current user. Consequently, data must be migrated from the }
{ SYSTEM user's profile to the new location. }
procedure MoveSystemKaliteData;
var
    systemKaliteDir: String;
    userKaliteDir: String;
    userKaliteDirBackup: String;
    resultCode: Integer;
begin
    systemKaliteDir := 'C:\Windows\System32\config\systemprofile\.kalite';
    if DirExists(systemKaliteDir) then
    begin
        if(MsgBox('You may need to migrate data from the SYSTEM user''s profile to the current user''s profile.' #13#13
                  'This is because of a change in the behavior of KA Lite using the "Run KA Lite at system startup" option.' #13
                  'If you use this option, we recommend clicking yes. Your data will be backed up.' #13#13
                  'Would you like to migrate data from the SYSTEM user''s profile to the current user''s profile?', mbConfirmation, MB_YESNO) = idYes) then
        begin
            userKaliteDir := ExpandConstant('{%USERPROFILE}\.kalite');
            userKaliteDirBackup := userKaliteDir + '.backup';
            if DirExists(userKaliteDir) then
            begin
                MsgBox(userKaliteDir + ' already exists, backing up to ' + userKaliteDirBackup, mbInformation, MB_OK);
                if not Exec(ExpandConstant('{cmd}'), '/C "xcopy  "' + userKaliteDir +'" "' + userKaliteDirBackup +'\" /Y /S"', '', SW_SHOW, ewWaitUntilTerminated, resultCode) then
                begin
                    MsgBox('Backup .kalite file copy fail.', mbInformation, MB_OK);
                end;
            end;
            if not Exec(ExpandConstant('{cmd}'), '/C "xcopy  "' + systemKaliteDir +'" "' + userKaliteDir +'\" /Y /S"', '', SW_SHOW, ewWaitUntilTerminated, resultCode) then
            begin
                MsgBox('System .kalite file copy fail.', mbInformation, MB_OK);
            end;
        end;
    end;
end;

procedure HandleUpgrade(targetPath : String);
var
    prevVerStr : String;
    retCode: Integer;
begin
    prevVerStr := GetPreviousVersion();
    if (CompareStr('{#TargetVersion}', prevVerStr) >= 0) and not (prevVerStr = '') then
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
                    DoGitMigrate;
                end;
            end;

            { A special case where we'd like to remove a scheduled task, since it should now be run as current user }
            { instead of the SYSTEM user. }
            if CompareStr(prevVerStr, '0.15.99') < 0 then
            begin
                if CompareStr('{#TargetVersion}', '0.16.0') >= 0 then
                begin
                    Exec(ExpandConstant('{cmd}'),'/C "schtasks /delete /tn "KALite" /f"', '', SW_SHOW, ewWaitUntilTerminated, retCode);
                end;
            end;

            { Migrating from 0.14.x and 0.15.x to 0.16.x }
            if (CompareStr(prevVerStr, '0.14.0') >= 0) and (CompareStr(prevVerStr, '0.15.99') < 0) then
            begin
                if CompareStr('{#TargetVersion}', '0.16.0') >= 0 then
                begin
                    MoveSystemKaliteData;
                end;
            end;
        end;

        { forceCancel will be true if something went awry in DoGitMigrate... abort instead of trampling the user's data. }
        if Not forceCancel then
        begin
            RemoveOldInstallation(targetPath);
        end;
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
    if(MsgBox('Python 2.7.11+ is required to install KA Lite on Windows; do you wish to first install Python 2.7.11, before continuing with the installation of KA Lite?', mbConfirmation, MB_YESNO) = idYes) then
    begin
        ExtractTemporaryFile('python-2.7.11.msi');
        ExtractTemporaryFile('python-2.7.11.amd64.msi');
        ExtractTemporaryFile('python-exe.bat');
        ShellExec('open', ExpandConstant('{tmp}')+'\python-exe.bat', '', '', SW_HIDE, ewWaitUntilTerminated, installPythonErrorCode);
    end
    else begin
        MsgBox('Error' #13#13 'You must have Python 2.7.11+ installed to proceed! Installation will now exit.', mbError, MB_OK);
        forceCancel := True;
        WizardForm.Close;
    end;
end;

{ Used in GetPipPath below }
const
    DEFAULT_PIP_PATH = '\Python27\Scripts\pip.exe';
    DEFAULT_PYTHON_PATH = '\Python27\python.exe';

{ Returns the path of pip.exe on the system. }
{ Tries several different locations before prompting user. }
function GetPipPath: string;
var
    kalitePythonEnv: string;
    path : string;
    i : integer;
begin
    kalitePythonEnv := GetEnv('KALITE_PYTHON');
    Log(kalitePythonEnv)
    if kalitePythonEnv = '' then 
      begin
        path := DEFAULT_PIP_PATH;
        if FileExists(path) then
        begin
            Result := path;
            exit;
        end
      end
    else
      begin
        if FileExists(kalitePythonEnv) then 
            Result := ExtractFileDir(kalitePythonEnv) + '\Scripts\pip.exe';
            exit;
      end

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
    pythonPath: string;
    checkEnc: string;
    ErrorCode: integer;

begin
    PipPath := GetPipPath;
    if PipPath = '' then
        exit;
    PipCommand := 'install "' + ExpandConstant('{app}') + '\ka-lite\ka_lite_static-' + '{#TargetVersion}' + '-py2-none-any' + '.whl"';

    MsgBox('Setup will now install kalite source files to your Python site-packages.', mbInformation, MB_OK);
    if not Exec(PipPath, PipCommand, '', SW_SHOW, ewWaitUntilTerminated, ErrorCode) then
    begin
      MsgBox('Critical error.' #13#13 'Dependencies have failed to install. Error Number: ' + IntToStr(ErrorCode), mbInformation, MB_OK);
      forceCancel := True;
      WizardForm.Close;
    end

    { Must set this environment variable so the systray executable knows where to find the installed kalite.bat script}
    { Should by in the same directory as pip.exe, e.g. 'C:\Python27\Scripts' }
    RegWriteStringValue(
        HKLM,
        'System\CurrentControlSet\Control\Session Manager\Environment',
        'KALITE_SCRIPT_DIR',
        ExtractFileDir(PipPath)
    );
    pythonPath := ExtractFileDir(ExtractFileDir(PipPath)) + '\python.exe';
    FileCopy(ExpandConstant('{app}') + '\ka-lite\scripts\kalite.bat', ExtractFileDir(PipPath) + '\kalite.bat', False);
    RegWriteStringValue(
        HKLM,
        'System\CurrentControlSet\Control\Session Manager\Environment',
        'KALITE_PYTHON',
        pythonPath
    );
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
   
    if ShellExec('open', 'python.exe','-c "import sys; (sys.version_info >= (2, 7, 11,) and sys.version_info < (3,) and sys.exit(0)) or sys.exit(1)"', '', SW_HIDE, ewWaitUntilTerminated, PythonVersionCodeCheck) then
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

procedure DoSetup;
var
    retCode: integer;
begin
    { Used to have more responsibility, but we delegated those to the app itself! }
    { Unpacks the English content pack. }
    Exec(ExpandConstant('{cmd}'), '/S /C "' + ExpandConstant('"{reg:HKLM\System\CurrentControlSet\Control\Session Manager\Environment,KALITE_SCRIPT_DIR}\kalite.bat"') + ' manage retrievecontentpack local en en.zip --foreground"', ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, retCode);
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
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
            begin
                DoSetup;
            end;
        end;
    end;
end;

{ Called just prior to uninstall finishing. }
{ Clean up things we did during uninstall: }
{ * Remove environment variable KALITE_SCRIPT_DIR, which is set starting in version 0.16.x }
{ * Previously (versions 0.13.x to 0.15.x) KALITE_ROOT_DATA_PATH was set -- it should be unset by the respective }
{   uninstallers of those versions }
procedure DeinitializeUninstall();
begin
    RegDeleteValue(
        HKLM,
        'System\CurrentControlSet\Control\Session Manager\Environment',
        'KALITE_SCRIPT_DIR'
    )
end;