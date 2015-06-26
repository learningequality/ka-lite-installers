//
//  AppDelegate.m
//  KA-Lite Monitor
//
//  Created by cyril on 1/20/15.
//  Copyright (c) 2015 FLE. All rights reserved.
//

// 
// Notes: Possible issues with OSX 10.10 or higher:
// * http://www.dowdandassociates.com/blog/content/howto-set-an-environment-variable-in-mac-os-x-slash-etc-slash-launchd-dot-conf/
// 

#import "AppDelegate.h"

@import Foundation;

@interface AppDelegate ()
//    @property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

@synthesize stringUsername, stringPassword, stringConfirmPassword, startKalite, stopKalite, openInBrowserMenu;


//<##>applicationDidFinishLaunching
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // Setup the status menu item.
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setImage:[NSImage imageNamed:@"favicon"]];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setToolTip:@"Click to show the KA-Lite menu items."];

    // Set the default status.
    self.status = statusCouldNotDetermineStatus;
    [self getKaliteStatus];
    
    // We need to show preferences if local_settings.py or database does not exist.
    bool mustShowPreferences = false;
    @try {
        checkEnvVars();
        NSString *localSettings = getLocalSettingsPath();
        if (!pathExists(localSettings)) {
            NSLog(@"local_settings.py not found, must show preferences...");
            mustShowPreferences = true;
        } else {
            NSLog([NSString stringWithFormat:@"FOUND local_settings.py at %@!", localSettings]);
        }
        
        NSString *database = getDatabasePath();
        if (!pathExists(database)) {
            NSLog(@"Database not found, must show preferences.");
            mustShowPreferences = true;
        } else {
            NSLog([NSString stringWithFormat:@"FOUND database at %@!", database]);
        }
        showNotification(@"KA Lite is now loaded.");
    }
    @catch (NSException *ex) {
        NSLog(@"KA Lite had an Error: %@", ex);
    }
    
    void *sel = @selector(closeSplash);
    if (mustShowPreferences) {
        sel = @selector(showPreferences);
    }
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:sel userInfo:nil repeats:NO];
    [self startKaliteMonitorTimer];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    // TODO(cpauya): Confirm quit action from user.
    if (kaliteExists()) {
        showNotification(@"Stopping and quitting the application...");
        [self runKalite:@"stop"];
    }
}


/********************
  Useful Methods
********************/


BOOL checkEnvVars() {
    // MUST: Check the KALITE_DIR and KALITE_PYTHON environment variables
    // and default it to the .app Resources folder if not yet set.
    NSString *kaliteDir = getEnvVar(@"KALITE_DIR");
    NSString *pyrun = getEnvVar(@"KALITE_PYTHON");
    if (!(pathExists(kaliteDir) && pathExists(pyrun))) {
        if (!setEnvVars(FALSE)) {
            NSString *msg = @"FAILED to set environment variables!";
            showNotification(msg);
            return FALSE;
        };
    }
    kaliteDir = getKaliteDir(true);
    pyrun = getPyrunBinPath(true);
    NSLog([NSString stringWithFormat:@"KA-Lite value: %@", kaliteDir]);
    NSLog([NSString stringWithFormat:@"Pyrun value: %@", pyrun]);
    return TRUE;
}


void copyLocalSettings() {
    NSString *source = [[NSBundle mainBundle] pathForResource:@"local_settings" ofType:@"default"];
    if (pathExists(source)) {
        NSString *target;
        NSString *kaliteDir = getKaliteDir(true);
        if (kaliteDir) {
            target = [kaliteDir stringByAppendingString:@"/kalite/local_settings.py"];
        } else {
            target = getResourcePath(@"ka-lite/kalite/local_settings.py");
        }
        NSString *command = [NSString stringWithFormat:@"cp \"%@\" \"%@\"", source, target];
        const char *cmd = [command UTF8String];
        int i = system(cmd);
        if (i == 0) {
            showNotification(@"Copied local_settings.default to local_settings.py.");
        } else {
            showNotification(@"Failed to copy `local_settings.default` to `local_settings.py`!");
        }
    } else {
        showNotification(@"The `local_settings.default` file does not exist!");
    }
}


NSString *getResourcePath(NSString *pathToAppend) {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:pathToAppend];
    path = [path stringByStandardizingPath];
    return path;
}


NSString *getLocalSettingsPath() {
    // Use the KALITE_DIR environment variable if set.
    NSString *localSettings;
    NSString *kaliteDir = getKaliteDir(true);
    if (kaliteDir) {
        localSettings = [kaliteDir stringByAppendingString:@"/kalite/local_settings.py"];
    } else {
        localSettings = [[NSBundle mainBundle] pathForResource:@"ka-lite/kalite/local_settings" ofType:@"py"];
    }
    return localSettings;
}


NSString *getDatabasePath() {
    // Use the KALITE_DIR environment variable if set.
    NSString *database;
    NSString *kaliteDir = getKaliteDir(true);
    if (kaliteDir) {
        database = [kaliteDir stringByAppendingString:@"/kalite/database/data.sqlite"];
    } else {
        database = [[NSBundle mainBundle] pathForResource:@"ka-lite/kalite/database/data" ofType:@"sqlite"];
    }
    return database;
}


BOOL pathExists(NSString *path) {
    // REF: http://www.exampledb.com/objective-c-check-if-file-exists.htm
    // REF: http://www.digitaledgesw.com/node/31
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    return exists;
}


NSString *thisOrOther(NSString *this, NSString *other) {
    // Accepts two arguments and returns the first if it has a value, else the other.
    if (this.length > 0) {
        return this;
    }
    return other;
}


//<##>getKaliteDir
NSString *getKaliteDir(BOOL useEnvVar) {
    // Returns the path of `ka-lite` directory if it exists or an empty string otherwise.
    // If `useEnvVar` is set, get the `KALITE_DIR` from the environment variables and use it if valid.
    NSString *kaliteDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ka-lite"];
    if (useEnvVar) {
        // Use the KALITE_DIR environment variable if set.
        NSString *var = getEnvVar(@"KALITE_DIR");
        if (pathExists(var)) {
            kaliteDir = var;
        }
    }
    kaliteDir = [kaliteDir stringByStandardizingPath];
    if (pathExists(kaliteDir)){
        return kaliteDir;
    }
    return @"";
}


NSString *getKaliteBinPath() {
    // Returns the path of `bin/kalite` if it exists or an empty string otherwise.
    NSString *kaliteDir = getKaliteDir(true);
    NSString *kalitePath = [kaliteDir stringByAppendingString:@"/bin/kalite"];
    kalitePath = [kalitePath stringByStandardizingPath];
    if (pathExists(kalitePath)){
        return kalitePath;
    }
    return @"";
}


NSString *getPyrunBinPath(BOOL useEnvVar) {
    // Returns the path of `pyrun` binary if it exists or an empty string otherwise.
    // If `useEnvVar` is set, get the `KALITE_PYTHON` from the environment variables and use it if valid.
    NSString *pyrun = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"pyrun-2.7/bin/pyrun"];
    if (useEnvVar) {
        // Use the KALITE_PYTHON environment variable if set.
        NSString *var = getEnvVar(@"KALITE_PYTHON");
        if (pathExists(var) ) {
            pyrun = var;
        }
    }
    pyrun = [pyrun stringByStandardizingPath];
    if (pathExists(pyrun)){
        return pyrun;
    }
    return @"";
}


BOOL kaliteExists() {
    NSString *kalitePath = getKaliteBinPath();
    return pathExists(kalitePath);
}


BOOL pyrunExists() {
    NSString *pyrun = getPyrunBinPath(true);
    return pathExists(pyrun);
}


- (enum kaliteStatus)runKalite:(NSString *)command {
    // It needs the `KALITE_DIR` and `KALITE_PYTHON` environment variables, so we set them here for every call.
    // TODO(cpauya): Must prompt user on preferences dialog and persist these perhaps on `local_settings.py`?

    // If command != `status`, we also call `bin/kalite status` so we auto-update the
    // menu and icon status for every call to this function.
    
    // Returns the status of `bin/kalite status`.
    // TODO(cpauya): Need a flag so this function can return the result of the `system()` call.
    NSString *kaliteDir;
    NSString *pyrun;
    NSString *kalitePath;
    NSString *kaliteCmd;
    NSString *finalCmd;
    NSString *statusCmd;
    enum kaliteStatus oldStatus = self.status;
    
    @try {
        pyrun = getPyrunBinPath(true);

        kaliteDir = getKaliteDir(true);
        kalitePath = getKaliteBinPath();
        
        // TODO(cpauya): make sure the pyrun and kalite binaries are not empty
        
        // MUST: This will make sure the process to run has access to the environment variables
        // because the .app may be loaded the first time.
        kaliteCmd = [NSString stringWithFormat: @"export KALITE_DIR=\"%@\"; export KALITE_PYTHON=\"%@\"; \"%@\"",
                     kaliteDir, pyrun, kalitePath];
        NSLog([NSString stringWithFormat:@"COMMAND ==> %@", kaliteCmd]);
        
        finalCmd = [NSString stringWithFormat:@"%@ %@", kaliteCmd, command];
        statusCmd = [NSString stringWithFormat:@"%@ %@", kaliteCmd, @"status"];
        
        if (kaliteExists()) {
            // REF: http://stackoverflow.com/a/10284037/845481
            // Convert const char* to NSString * and convert back - _NSAutoreleaseNoPool().
            const char *runCommand = [finalCmd UTF8String];
            int status = system(runCommand);
            
            // If command is not "status", run `kalite status` to get status of ka-lite.
            // We need this check because this may be called inside the monitor timer.
            if ([command isNotEqualTo: @"status"]) {
                NSLog(@"Fetching `bin/kalite status`...");
                runCommand = [statusCmd UTF8String];
                status = system(runCommand);
                // MUST: The result is on the 9th bit of the returned value.  Not sure why this
                // is but maybe because of the returned values from the `system()` call.  For now
                // we shift 8 bits to the right until we figure this one out.  TODO(cpauya): fix later
                if (status >= 255) {
                    status = status >> 8;
                }
            } else {
                if (status >= 255) {
                    status = status >> 8;
                }
            }
            self.status = status;
        } else {
            self.status = statusCouldNotDetermineStatus;
            [self showStatus:self.status];
            showNotification(@"The `bin/kalite` executable does not exist!");
        }
    }
    @catch (NSException *ex) {
        self.status = statusCouldNotDetermineStatus;
        NSLog(@"Error running `bin/kalite` %@", ex);
    }
    if (oldStatus != self.status) {
        [self showStatus:self.status];
    }
    return self.status;
}


void alert(NSString *message) {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
}


BOOL confirm(NSString *message) {
    NSAlert *confirm = [[NSAlert alloc] init];
    [confirm addButtonWithTitle:@"OK"];
    [confirm addButtonWithTitle:@"Cancel"];
    [confirm setMessageText:message];
    if ([confirm runModal] == NSAlertFirstButtonReturn) {
        return TRUE;
    }
    return FALSE;
}


void showNotification(NSString *subtitle) {
    // REF: http://stackoverflow.com/questions/12267357/nsusernotification-with-custom-soundname?rq=1
    // TODO(cpauya): These must be ticked by user on preferences if they want notifications, sounds, or not.
    NSUserNotification* notification = [[NSUserNotification alloc]init];
    notification.title = @"KA-Lite Monitor";
    notification.subtitle = subtitle;
    notification.soundName = @"Basso.aiff";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    // The notification may be optional (based on user preferences) but we must show it on the logs.
    NSLog(subtitle);
}


NSString *getUsernameChars() {
    NSString *chars = @"@.+-_0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    return chars;
}


// REF: http://stackoverflow.com/a/26423271/845481
// Check IF one String contains the same characters as another string
- (BOOL)string:(NSString *)string containsAllCharactersInString:(NSString *)charString {
    NSUInteger stringLen = [string length];
    NSUInteger charStringLen = [charString length];
    for (NSUInteger i = 0; i < charStringLen; i++) {
        unichar c = [charString characterAtIndex:i];
        BOOL found = NO;
        for (NSUInteger j = 0; j < stringLen && !found; j++)
            found = [string characterAtIndex:j] == c;
        if (!found)
            return NO;
    }
    return YES;
}


//<##>runRootCommands
BOOL runRootCommands(NSString *command) {
    NSString *msg = [NSString stringWithFormat:@"Running root command/s: %@...", command];
    showNotification(msg);
    
    NSDictionary *errorInfo = runAsRoot(command);
    if (errorInfo != nil) {
        msg = [NSString stringWithFormat:@"FAILED command/s %@ with ERROR: %@", command, errorInfo];
        showNotification(msg);
        return FALSE;
    }
    msg = [NSString stringWithFormat:@"Done running root command/s %@.", command];
    showNotification(msg);
    return TRUE;
}


//<##>setLaunchAgent
NSString *getLaunchAgentCommand(NSString *source, NSString *target) {
    if (pathExists(source)) {
        return [NSString stringWithFormat:@"cp '%@' '%@'", source, target];
    }
    return nil;
}

// Not used for now but is useful to re-run the command individually later.
BOOL setLaunchAgent(NSString *source, NSString *target) {
    // Needs to run as root.
    NSString *msg;
    if (pathExists(source)) {
        msg = [NSString stringWithFormat:@"Copying %@ to %@...", source, target];
        showNotification(msg);
        
        NSString *command = [NSString stringWithFormat:@"cp '%@' '%@'", source, target];
        NSDictionary *errorInfo = runAsRoot(command);
        if (errorInfo != nil) {
            msg = [NSString stringWithFormat:@"FAILED command %@ with ERROR: %@", command, errorInfo];
            showNotification(msg);
            return FALSE;
        }
        msg = [NSString stringWithFormat:@"Done copying %@ to %@.", source, target];
        showNotification(msg);
    } else {
        msg = [NSString stringWithFormat:@"Source %@ OR target: %@ does not exist!", source, target];
        showNotification(msg);
        return FALSE;
    }
    return TRUE;
}


//<##>symlinkKalite
NSString *getSymlinkKaliteCommand() {
    if (kaliteExists()) {
        NSString *kalitePath = getKaliteBinPath();
        NSString *target = @"/usr/local/bin/kalite";
        NSString *command = [NSString stringWithFormat:@"ln -f '%@' '%@'", kalitePath, target];
        return command;
    }
    return nil;
}

// Not used for now but is useful to re-run the command individually later.
BOOL symlinkKalite() {
    NSString *msg;
    if (kaliteExists()) {
        NSString *kalitePath = getKaliteBinPath();
        NSString *target = @"/usr/local/bin/kalite";
        
        msg = [NSString stringWithFormat:@"Symlinking %@ to %@...", kalitePath, target];
        showNotification(msg);
        
        NSString *command = [NSString stringWithFormat:@"ln -f '%@' '%@'", kalitePath, target];
        NSDictionary *errorInfo = runAsRoot(command);
        if (errorInfo != nil) {
            msg = [NSString stringWithFormat:@"FAILED command %@ with ERROR: %@", command, errorInfo];
            showNotification(msg);
            return FALSE;
        }
        msg = [NSString stringWithFormat:@"Done symlinking %@ to %@.", kalitePath, target];
        showNotification(msg);
    }
    return TRUE;
}


NSDictionary *runAsRoot(NSString *command) {
    // This will run an AppleScript command with admin privileges, thereby prompting the user to
    // input the admin password so script can continue.
    // REF: http://stackoverflow.com/questions/4599447/cocoa-gaining-root-access-for-nsfilemanager
    // REF: https://developer.apple.com/library/mac/samplecode/EvenBetterAuthorizationSample/Introduction/Intro.html
    
    // TODO(cpauya): This was supposed to be the approach but doesn't work since we need
    // admin privileges for symlinking to the target /usr/local/bin/.
    // This seemed hard, so resorted to running an Apple script for now.
    // REF: http://stackoverflow.com/questions/4599447/cocoa-gaining-root-access-for-nsfilemanager
    //        BOOL result = [fileMgr linkItemAtPath:kalitePath toPath:target error:&err];
    //        BOOL result = [fileMgr createSymbolicLinkAtPath:kalitePath withDestinationPath:target error:&err];
    //        msg = [NSString stringWithFormat:@"RESULT: %hhd, ERROR: %@", result, err];
    //        NSLog(msg);
    NSString *msg;
    NSDictionary *errorInfo;
    command = [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", command];
    command = [NSString stringWithFormat:@"%@", command];
    [[[NSAppleScript alloc]initWithSource:command] executeAndReturnError:&errorInfo];
    if (errorInfo != nil) {
        return errorInfo;
    }
    return nil;
}


NSString *getEnvVar(NSString *var) {
    // Get environment variables as per var argument.
    NSString *path = [[[NSProcessInfo processInfo]environment]objectForKey:var];
    return path;
}


//<##>setEnvVars
BOOL setEnvVars(BOOL createPlist) {
    // TODO(cpauya): For now, get the values from current .app Resources folder.  In the future,
    // it must be taken from user-defined values on the Preferences dialog.

    // Set environment variables using the `launchctl setenv` command for immediate use.
    // REF: http://stackoverflow.com/questions/135688/setting-environment-variables-in-os-x/588442#588442
    
    showNotification(@"Setting KALITE_DIR environment variable...");
    NSString *kaliteDir = getKaliteDir(false);
    if (kaliteExists()) {
        NSString *command = [NSString stringWithFormat:@"launchctl setenv KALITE_DIR \"%@\"", kaliteDir];
        const char *cmd = [command UTF8String];
        int i = system(cmd);
        if (i == 0) {
            NSString *msg = [NSString stringWithFormat:@"Successfully set KALITE_DIR env to %@.", kaliteDir];
            showNotification(msg);
        } else {
            showNotification(@"Failed to set KALITE_DIR env.");
            return FALSE;
        }
    } else {
        showNotification(@"Failed to set KALITE_DIR env, kalite does not exist!");
        return FALSE;
    }

    showNotification(@"Setting KALITE_PYTHON environment variable...");
    NSString *pyrun = getPyrunBinPath(false);
    if (pyrun) {
        NSString *command = [NSString stringWithFormat:@"launchctl setenv KALITE_PYTHON \"%@\"", pyrun];
        const char *cmd = [command UTF8String];
        int i = system(cmd);
        if (i == 0) {
            NSString *msg = [NSString stringWithFormat:@"Successfully set KALITE_PYTHON env to %@.", pyrun];
            showNotification(msg);
        } else {
            showNotification(@"Failed to set KALITE_PYTHON env.");
            return FALSE;
        }
    } else {
        showNotification(@"Failed to set KALITE_PYTHON env, pyrun does not exist!");
        return FALSE;
    }
    
    if (!createPlist) {
        NSLog(@"Not creating a .plist file, this may be the first time the .app is loaded.");
        return TRUE;
    }
    /*
     MUST: Let's create a org.learningequality.kalite.plist at the /tmp/ folder
     then use an AppleScript script to combine it with the symlink script
     with admin privileges so we only ask for the root password once.
     
     This is the format:

     NSString *str = [NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF-8'?>" \
     "    <!DOCTYPE plist PUBLIC '-//Apple//DTD PLIST 1.0//EN' 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'>" \
     "    <plist version='1.0'>" \
     "    <dict>" \
     "      <key>Label</key>" \
     "      <string>org.learningequality.kalite</string>" \
     "      <key>ProgramArguments</key>" \
     "      <array>" \
     "          <string>sh</string>" \
     "          <string>-c</string>" \
     "          <string>" \
     "              launchctl setenv KALITE_DIR %@" \
     "              launchctl setenv KALITE_PYTHON" \
     "          </string>" \
     "      </array>" \
     "      <key>RunAtLoad</key>" \
     "      <true/>" \
     "    </dict>" \
     "    </plist>", kaliteDir];
     */
    NSString *org = @"org.learningequality.kalite";
    NSString *path = [NSString stringWithFormat:@"/tmp/%@.plist", org];
    NSString *target = [NSString stringWithFormat:@"/Library/LaunchAgents/%@.plist", org];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] init];
    [plistDict setObject:org forKey:@"Label"];
    NSString *launchStr = [NSString stringWithFormat:@"%@;%@",
                           [NSString stringWithFormat:@"launchctl setenv KALITE_DIR \"%@\"", kaliteDir],
                           [NSString stringWithFormat:@"launchctl setenv KALITE_PYTHON \"%@\"", pyrun]
                          ];
    NSArray *arr = @[@"sh", @"-c", launchStr];
    [plistDict setObject:arr forKey:@"ProgramArguments"];
    [plistDict setObject:[NSNumber numberWithBool:TRUE] forKey:@"RunAtLoad"];
    showNotification([NSString stringWithFormat:@"Setting KALITE_DIR and KALITE_PYTHON environment variables... %@", plistDict]);
    BOOL ret = [plistDict writeToFile:path atomically: YES];
    if (ret == YES) {
        NSLog([NSString stringWithFormat:@"SAVED initial .plist file to %@", path]);
    } else {
        NSLog([NSString stringWithFormat:@"CANNOT save initial .plist file!  Result: %hhd", ret]);
    }
    
    //TODO(cpauya): As root, copy the .plist into /Library/LaunchAgents/
    NSString *launchAgentCommand = getLaunchAgentCommand(path, target);
    NSString *symlinkCommand = getSymlinkKaliteCommand();
    NSString *command = [NSString stringWithFormat:@"%@; %@;", launchAgentCommand, symlinkCommand];
    return runRootCommands(command);
}


/********************
 END Useful Methods
 ********************/


- (void)showStatus:(enum kaliteStatus)status {
    // Enable/disable menu items based on status.
    switch (status) {
        case statusFailedToStart:
            [self.startKalite setEnabled:YES];
            [self.stopKalite setEnabled:NO];
            [self.openInBrowserMenu setEnabled:NO];
            break;
        case statusStartingUp:
            [self.startKalite setEnabled:NO];
            [self.stopKalite setEnabled:NO];
            [self.openInBrowserMenu setEnabled:NO];
            break;
        case statusOkRunning:
            [self.startKalite setEnabled:NO];
            [self.stopKalite setEnabled:YES];
            [self.openInBrowserMenu setEnabled:YES];
            [self.statusItem setImage:[NSImage imageNamed:@"stop"]];
            [self.statusItem setToolTip:@"KA-Lite is running."];
            showNotification(@"You can now click on 'Open in Browser' menu");
            break;
        case statusStopped:
            [self.startKalite setEnabled:YES];
            [self.stopKalite setEnabled:NO];
            [self.openInBrowserMenu setEnabled:NO];
            [self.statusItem setImage:[NSImage imageNamed:@"favicon"]];
            [self.statusItem setToolTip:@"KA-Lite is stopped."];
            showNotification(@"Stopped");
            break;
        default:
            [self.startKalite setEnabled:YES];
            [self.stopKalite setEnabled:NO];
            [self.openInBrowserMenu setEnabled:NO];
            if (kaliteExists()){
                [self.statusItem setImage:[NSImage imageNamed:@"favicon"]];
            }else{
                [self.statusItem setImage:[NSImage imageNamed:@"exclaim"]];
            }
            [self.statusItem setToolTip:@"KA-Lite has encountered an error, pls check the Console."];
            showNotification(@"Has encountered an error, pls check the Console.");
            break;
    }
}


- (IBAction)start:(id)sender {
    showNotification(@"Starting...");
    [self showStatus:statusStartingUp];
    [self runKalite:@"start"];
}


- (IBAction)stop:(id)sender {
    showNotification(@"Stopping...");
    [self runKalite:@"stop"];
}


- (IBAction)open:(id)sender {
    // TODO(cpauya): Get the ip address and port from `local_settings.py` or preferences.
    // REF: http://stackoverflow.com/a/7129543/845481
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8008/"];
    if( ![[NSWorkspace sharedWorkspace] openURL:url] ) {
        NSString *msg = [NSString stringWithFormat:@" Failed to open url: %@",[url description]];
        showNotification(msg);
    }
}


- (IBAction)closeSplash:(id)sender {
    [self closeSplash];
}


- (IBAction)showPreferences:(id)sender {
    [self showPreferences];
}


- (IBAction)hidePreferences:(id)sender {
    [window orderOut:[window identifier]];
}


- (IBAction)savePreferences:(id)sender {
    [self savePreferences];
}


- (IBAction)discardPreferences:(id)sender {
    [self discardPreferences];
}


- (IBAction)setupAction:(id)sender {
    if (kaliteExists()) {
        NSString *message = @"Are you sure you want to run setup?  This will take a few minutes to complete.";
        if (confirm(message)) {
            [self setupKalite];
        }
    } else {
        alert(@"Sorry but the `bin/kalite` executable was not found!");
    }
}


- (IBAction)resetAppAction:(id)sender {
    NSString *message = @"This will reset app.  Are you sure?";
    if (confirm(message)) {
        [self resetApp];
    }
}


- (void)closeSplash {
    [splash orderOut:self];
}


- (void)showPreferences {
    [splash orderOut:self];
    [self loadPreferences];
    [window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}


- (NSString *)getUsernamePref {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *username = [prefs stringForKey:@"username"];
    return username;
}


- (void)loadPreferences {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.username = [self getUsernamePref];

    // TODO(cpauya): We must encrypt the password!
    NSString *password = [prefs stringForKey:@"password"];
    if (password != nil || [password isNotEqualTo:@""]) {
        // NSData from the Base64 encoded str
        NSData *nsdataFromBase64String = [[NSData alloc]
                                          initWithBase64EncodedString:password options:0];
        // Decoded NSString from the NSData
        NSString *decodePassword = [[NSString alloc]
                                    initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
        self.password = decodePassword;
        self.confirmPassword = decodePassword;
    }
}


- (void)savePreferences {
    /*
     1. Validate the following:
        * username length max of 30 characters
        * password length max of 128 characters
        * username allowed characters are "letters, numbers and @/./+/-/_ characters" based on django.contrib.auth.models.AbstractUser
     2. Save the preferences: REF: http://stackoverflow.com/questions/10148788/xcode-cocoa-app-preferences
     3. Copy local_settings_sample.py to local_settings.py
     4. Run `kalite manage setup` if no database was found.
     */
    
    NSString *username = self.stringUsername.stringValue;
    NSString *password = self.stringPassword.stringValue;
    NSString *confirmPassword = self.stringConfirmPassword.stringValue;
    
    self.username = username;
    self.password = password;
    self.confirmPassword = confirmPassword;

    if (self.username == nil || [self.username isEqualToString:@""]) {
        alert(@"Username must not be blank and can only contain letters, numbers and @/./+/-/_ characters.");
        return;
    }

    NSString *usernameChars = getUsernameChars();
    if ([self string:usernameChars containsAllCharactersInString:self.username] == NO) {
        alert(@"Invalid username characters found, please use letters, numbers and @/./+/-/_ characters.");
        return;
    }
    
    if ([self.username length] > 30) {
        alert(@"Username must not exceed 30 characters.");
        return;
    }

    if (self.password == nil || [self.password isEqualToString:@""]) {
        alert(@"Invalid password or the password does not match on both fields.");
        return;
    }

    if (![self.password isEqualToString:self.confirmPassword]) {
        alert(@"The password does not match on both fields.");
        return;
    }

    if ([self.password length] > 128) {
        alert(@"Password must not exceed 128 characters.");
        return;
    }
    
    // Save the preferences.
    // REF: http://iosdevelopertips.com/core-services/encode-decode-using-base64.html
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // Get NSString from NSData object in Base64
    NSData *nsdata = [self.password dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedPassword = [nsdata base64EncodedStringWithOptions:0];
    
    [prefs setObject:self.username forKey:@"username"];
    [prefs setObject:encodedPassword forKey:@"password"];
    // REF: https://github.com/iwasrobbed/Objective-C-CheatSheet#storing-values
    [prefs synchronize];
    
    // Copy `local_settings.default` if no `local_settings.py` was found.
    NSString *localSettingsPath = getLocalSettingsPath();
    if (!pathExists(localSettingsPath)) {
        copyLocalSettings();
    }

    if (!setEnvVars(TRUE)) {
        alert(@"Either the set environment variables or symlink of kalite failed to complete!  Please check the Console.");
        return;
    }
    
    // Automatically run `kalite manage setup` if no database was found.
    NSString *databasePath = getDatabasePath();
    if (!pathExists(databasePath)) {
        if (kaliteExists()) {
            alert(@"Will now run KA-Lite setup, it will take a few minutes.  Please wait until prompted that setup is done.");
            enum kaliteStatus status = [self setupKalite];
            showNotification(@"Setup is finished!  You can now start KA-Lite.");
            // TODO(cpauya): Get the result of running `bin/kalite manage setup` not the
            // default result of `bin/kalite status` so we can alert the user that setup failed.
            //        if (status != statusStopped) {
            //            alert(@"Running 'manage setup' failed, please see Console.");
            //            return;
            //        }
        }
    }
    // Close the preferences dialog after successful save.
    [window orderOut:[window identifier]];
}


-(enum kaliteStatus)setupKalite {
    // Get admin account credentials from preferences.
    
    // MUST: The order of the arguments must be followed or the username / password
    // will not have the same value!
    NSString *cmd = [NSString stringWithFormat:@"manage setup -o '' -d '' -u %@ -p %@ --noinput",
                     self.username, self.password];
    NSString *msg = [NSString stringWithFormat:@"Running `kalite manage setup` with %@", cmd];
    showNotification(msg);
    enum kaliteStatus status = [self runKalite:cmd];
    [self getKaliteStatus];
    return status;
}


-(BOOL)resetApp {
    // This will reset the app like it was never installed.
    // 1. reset the environment variables: KALITE_DIR, KALITE_PYTHON
    // 2. remove the .plist file, need admin
    // 3. delete the symlinked /usr/local/bin/kalite command, need admin
    // 4. TODO(cpauya): delete/reset the user preferences

    showNotification(@"Resetting the app...");
    NSString *msg;

    // This unsets the KALITE_DIR and KALITE_PYTHON environment variables used by the app.
    NSString *command = @"launchctl unsetenv KALITE_DIR; launchctl unsetenv KALITE_PYTHON;";
    const char *cmd = [command UTF8String];
    int i = system(cmd);
    if (i != 0) {
        showNotification(@"Failed to unset KALITE_DIR and KALITE_PYTHON env vars.");
        return FALSE;
    }

    // MUST: Run the root commands as one so it only prompts the user once.

    // Delete the .plist files.
    NSString *org = @"org.learningequality.kalite";
    NSString *tempPath = [NSString stringWithFormat:@"/tmp/%@.plist", org];
    NSString *agentPath = [NSString stringWithFormat:@"/Library/LaunchAgents/%@.plist", org];
    NSString *deletePlistCommand = [NSString stringWithFormat:@"rm %@; rm %@;", tempPath, agentPath];

    // Delete the symlinked `kalite` executable.
    NSString *path = @"/usr/local/bin/kalite";
    NSString *deleteSymlinkCommand = [NSString stringWithFormat:@"rm %@;", path];

    command = [NSString stringWithFormat:@"%@ %@", deletePlistCommand, deleteSymlinkCommand];
    if (!runRootCommands(command)) {
        showNotification(@"Failed to delete .plist or symlinked kalite executable.");
        return FALSE;
    }
    showNotification(@"Done resetting the app.");
    return TRUE;
}


- (void)discardPreferences {
    // TODO(cpauya): Discard changes and load the saved preferences.
    [window orderOut:[window identifier]];
}


- (void)startKaliteMonitorTimer {
    // Setup a timer to monitor the result of `kalite status` after 5 minutes
    // TODO(cpauya): then every 2 minutes thereafter.

    // Monitor only if preferences are set.
    NSString *username = [self getUsernamePref];
    if (username != nil) {
        // TODO(cpauya): Use initWithFireDate of NSTimer instance.
        [NSTimer scheduledTimerWithTimeInterval:300.0
                                         target:self
                                       selector:@selector(getKaliteStatus)
                                       userInfo:nil
                                        repeats:YES];
    } else {
        NSLog(@"Not running timer because there are no preferences yet.");
    }
}


- (enum kaliteStatus)getKaliteStatus {
    return [self runKalite:@"status"];
}


@end
