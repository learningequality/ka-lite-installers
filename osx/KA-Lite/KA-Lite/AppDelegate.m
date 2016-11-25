//
//  AppDelegate.m
//  KA-Lite
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

@implementation AppDelegate

@synthesize startKalite, stopKalite, openInBrowserMenu, kaliteVersion, customKaliteData, loadOnLogin, startOnLoad, autoStartOnLoad, kaliteDataHelp, popover, popoverMsg, version, isLoaded;


// REF: http://objcolumnist.com/2009/08/09/reopening-an-applications-main-window-by-clicking-the-dock-icon/
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    if(flag == NO) {
        [self showPreferences];
    }
    return YES;	
}


// TODO(amodia): Show menu bar on dock icon.
//- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
//    return self.statusMenu;
//}


- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    // TODO(cpauya): Get version from the project's .plist file or from `kalite --version`.
    self.version = @"0.16";
    self.isLoaded = NO;
    self.autoStartOnLoad = YES;
    self.status = statusCouldNotDetermineStatus;
    self.lastStatus = statusCouldNotDetermineStatus;
    self.quitReason = quitByUnknown;
}


//<##>applicationDidFinishLaunching
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    // Set the delegate to self to make sure notifications work properly.
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    // MUST: Let's check the setup if everything is good!
    if ([self checkSetup:YES] == NO) {
        // The application must terminate if setup is not good.
        void *sel = @selector(closeSplash);
        alert(@"The KA Lite installation is not complete, please re-install KA Lite. \n\nRefer to the Console app for details.");
        [[NSApplication sharedApplication] terminate:nil];
        return;
    }
    
    // Setup is good, let's continue.
    
    // Make sure to register default values for the user preferences.
    [self registerDefaultPreferences];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setImage:[NSImage imageNamed:@"favicon"]];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setToolTip:@"Click to show the KA Lite menu items."];
    
    [self.kaliteDataHelp setToolTip:@"This will set the KALITE_HOME environment variable to the selected KA Lite data location. \n \nClick the 'Apply' button to save your changes and click the 'Start KA Lite' button to use your new data location. \n \nNOTE: To use your existing KA Lite data, manually copy it to the selected KA Lite data location."];
    [self.kaliteUninstallHelp setToolTip:@"This will uninstall the KA Lite application. \n \nCheck the `Delete KA Lite data folder` option if you want to delete your KA Lite data. \n \nNOTE: This will require admin privileges."];

//    @try {
//        [self runKalite:@"--version"];
//        [self getKaliteStatus];
//    }
//    @catch (NSException *ex) {
//        NSLog(@"KA Lite had an Error: %@", ex);
//    }
    
    void *sel = @selector(closeSplash);
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:sel userInfo:nil repeats:NO];
    [self startKaliteTimer];

    // TODO(cpauya): Auto-start KA Lite on application load.
    if (self.autoStartOnLoad) {
        [self startFunction];
    } else {
        // Get the status to determine the menu bar icon to display but don't show any notifications.
        // The `isLoaded` property will be set to YES the initial status check.
        showNotification(@"KA Lite is now loaded, click on the Start KA Lite menu to get started.", @"");
        [self getKaliteStatus];
    }

}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Confirm quit action from user.
    // TODO(cpauya): Don't ask if OS asked to quit the app.
    if ([self checkSetup:NO] == YES) {
        NSString *msg = @"This will stop and quit KA Lite, are you sure?";
        switch ([self quitReason]) {
            case quitByUser:
                break;
            default:
                if (! confirm(msg)) {
                    return NSTerminateCancel;
                }
                break;
        }
        [self stopFunction:true];
    }
    return NSTerminateNow;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    NSString *msg = @"KA Lite is now stopped and quit.";
    if ([self checkSetup:NO] == NO) {
        switch ([self quitReason]) {
            case quitByUninstall:
                msg = @"KA Lite was quit to complete the uninstall process.";
                break;
            default:
                msg = @"KA Lite was quit because the required setup is incomplete.";
                break;
        }
    }
    showNotification(msg, @"");
}


// REF: http://stackoverflow.com/a/11815544/845481 - Send notification to Mountain lion notification center
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}


/********************
  Useful Methods
********************/


BOOL checkEnvVars() {
    NSString *kalitePython = getEnvVar(@"KALITE_PYTHON");
    if (!pathExists(kalitePython)) {
        return NO;
    }
    // If KALITE_HOME is nil or an empty string, that's fine.  Else check if value is a valid path.
    NSString *kaliteHome = getEnvVar(@"KALITE_HOME");
    if (kaliteHome && !pathExists(kaliteHome)) {
        return NO;
    }
    return YES;
}


- (IBAction)clearLogs:(id)sender {
    self.taskLogs.string = @"";
}


- (void) displayLogs:(NSString *)outStr {
    dispatch_sync(dispatch_get_main_queue(), ^{
        // REF: http://stackoverflow.com/questions/10772033/get-current-date-time-with-nsdate-date
        //Get the current date time
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
        
        NSString *str = [self.taskLogs.string stringByAppendingString:[NSString stringWithFormat:@"\n%@ %@", dateStr, outStr]];
        self.taskLogs.string = str;
        // Scroll to end of outputText field
        NSRange range;
        range = NSMakeRange([self.taskLogs.string length], 0);
        [self.taskLogs scrollRangeToVisible:range];
    });
}


- (void) runTask:(NSString *)command {
    NSString *kalitePath;
    NSString *statusStr;
    NSString *versionStr;
    NSMutableDictionary *kaliteHomeEnv;
    
    statusStr = @"status";
    versionStr = @"--version";
    
    // Set loading indicator icon.
    if (command != statusStr) {
        [self.statusItem setImage:[NSImage imageNamed:@"loading"]];
    }
    
    self.processCounter += 1;
    
    kalitePath = getKaliteExecutable();
    
    kaliteHomeEnv = [[NSMutableDictionary alloc] init];
    
    NSString *kaliteHomePath = getKaliteDataPath();
    
    // Set KALITE_HOME environment
    [kaliteHomeEnv addEntriesFromDictionary:[[NSProcessInfo processInfo] environment]];
    [kaliteHomeEnv setObject:kaliteHomePath forKey:@"KALITE_HOME"];
    
    //REF: http://stackoverflow.com/questions/386783/nstask-not-picking-up-path-from-the-users-environment
    NSTask* task = [[NSTask alloc] init];
    NSString *kaliteCommand = [NSString stringWithFormat:@"%@ %@", getKaliteExecutable(), command];
    NSArray *array = [NSArray arrayWithObjects:@"-l",
                      @"-c",
                      kaliteCommand,
                      nil];
    
    NSDictionary *defaultEnvironment = [[NSProcessInfo processInfo] environment];
    NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithDictionary:defaultEnvironment];
    [environment setObject:kaliteHomePath forKey:@"KALITE_HOME"];
    [task setEnvironment:environment];

    
    [task setLaunchPath: @"/bin/bash"];
    [task setArguments: array];
    
    // REF: http://stackoverflow.com/questions/9965360/async-execution-of-shell-command-not-working-properly
    // REF: http://www.raywenderlich.com/36537/nstask-tutorial
    
    NSPipe *pipeOutput = [NSPipe pipe];
    task.standardOutput = pipeOutput;
    task.standardError = pipeOutput;
    
    [[task.standardOutput fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
        NSData *data = [file availableData]; // this will read to EOF, so call only once
        NSString *outStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (self.status != self.lastStatus) {
            NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            [self displayLogs:outStr];
        }
        
        // Set the current kalite version
        if (command == versionStr){
            self.kaliteVersion.stringValue = outStr;
        }
    }];
    
    [task launch];
    
}


NSString *getResourcePath(NSString *pathToAppend) {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:pathToAppend];
    path = [path stringByStandardizingPath];
    return path;
}


NSString *getDatabasePath() {
    NSString *database;
    NSString* envKaliteHomeStr = getEnvVar(@"KALITE_HOME");
    if (pathExists(envKaliteHomeStr)) {
        database = [NSString stringWithFormat:@"%@%@", envKaliteHomeStr, @"/database/data.sqlite"];
        database = [database stringByStandardizingPath];
        return database;
    }
    database = @"~/.kalite/database/data.sqlite";
    database = [database stringByStandardizingPath];
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


BOOL kaliteExists() {
    NSString *kalitePath = getKaliteExecutable();
    return pathExists(kalitePath);
}


// REF: http://objc.toodarkpark.net/Foundation/Classes/NSTask.html
-(id)init{
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkRunTask:)
                                                 name:NSTaskDidTerminateNotification
                                               object:nil];
    return self;
}


- (enum kaliteStatus)checkRunTask:(NSNotification *)aNotification{
    NSArray *taskArguments;
    NSArray *statusArguments;
    NSString *kaliteStatusCommand;
    enum kaliteStatus oldStatus = self.status;
    
    int status = [[aNotification object] terminationStatus];

    taskArguments = [[aNotification object] arguments];
    kaliteStatusCommand = [NSString stringWithFormat:@"%@ status", getKaliteExecutable()];
    statusArguments = [[NSArray alloc]initWithObjects:@"-l", @"-c", kaliteStatusCommand, nil];
    NSSet *taskArgsSet = [NSSet setWithArray:taskArguments];
    NSSet *statusArgsSet = [NSSet setWithArray:statusArguments];
    
    if (self.processCounter >= 1) {
        self.processCounter -= 1;
    }
    if (self.processCounter != 0) {
        return self.status;
    }
    
    if (checkKaliteExecutable()) {
        if ([taskArgsSet isEqualToSet:statusArgsSet]) {
            // MUST: The result is on the 9th bit of the returned value.  Not sure why this
            // is but maybe because of the returned values from the `system()` call.  For now
            // we shift 8 bits to the right until we figure this one out.  TODO(cpauya): fix later
            if (status >= 255) {
                status = status >> 8;
            }
            [self setNewStatus:status];
            if (oldStatus != status) {
                [self showStatus:self.status];
            }
            return self.status;
        } else {
            // If command is not "status", run `kalite status` to get status of ka-lite.
            // We need this check because this may be called inside the KA-Lite timer.
            NSLog(@"Fetching `kalite status`...");
            [self getKaliteStatus];
            return self.status;
        }
    } else {
        [self setNewStatus:statusCouldNotDetermineStatus];
        [self showStatus:self.status];
        showNotification(@"The `kalite` executable does not exist!", @"");
    }
    return self.status;
}


- (enum kaliteStatus)runKalite:(NSString *)command {
    @try {
        // MUST: This will make sure the process to run has access to the environment variable
        // because the .app may be loaded the first time.
        if (checkKaliteExecutable()) {
            [self runTask:command];
        }
    }
    @catch (NSException *ex) {
        [self setNewStatus:statusCouldNotDetermineStatus];
        NSLog(@"Error running `kalite` %@", ex);
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


void showNotification(NSString *subtitle, NSString *info) {
    // REF: http://stackoverflow.com/questions/12267357/nsusernotification-with-custom-soundname?rq=1
    // TODO(cpauya): These must be ticked by user on preferences if they want notifications, sounds, or not.
    NSUserNotification* notification = [[NSUserNotification alloc] init];
    notification.title = @"KA Lite";
    notification.subtitle = subtitle;
    notification.informativeText = info;
    notification.soundName = @"Basso.aiff";

    NSUserNotificationCenter *nc = [NSUserNotificationCenter defaultUserNotificationCenter];
    [nc deliverNotification:notification];
    // The notification may be optional (based on user's OS X preferences) but we must show it on the logs.
    NSLog(subtitle);
    if (info) {
        NSLog(info);
    }
}


- (void)toggleKaliteDataPath:(BOOL)toggleValue {
    if (toggleValue == YES) {
        self.customKaliteData.enabled = YES;
        [self.customKaliteData setToolTip:@"Select KA Lite data path."];
    } else {
        self.customKaliteData.enabled = NO;
        [self.customKaliteData setToolTip:@"KA Lite is still running. Stop KA Lite to select data path."];
    }
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


NSString *getKaliteExecutable() {
    NSString* envKalitePexPath = getEnvVar(@"KALITE_PEX");
    if (pathExists(envKalitePexPath)) {
        return envKalitePexPath;
    }
    return @"/Applications/KA-Lite/support/ka-lite/kalite.pex";
}


NSString *getKaliteDataPath() {
    /*
    This function returns these possible locations for the KA Lite data path:
        1. Custom KA Lite data set by the user at the preferences dialog.
        2. Path based on the KALITE_HOME environment variable.
        3. The default location of the KA Lite data folder at ~/.kalite/.
        4. nil - The above locations do not exist.
    */
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *customKaliteData = [prefs stringForKey:@"customKaliteData"];
    
    if (pathExists(customKaliteData)) {
        NSString *standardizedPath = [customKaliteData stringByStandardizingPath];
        return standardizedPath;
    } else {
        NSString* envKaliteHomeStr = getEnvVar(@"KALITE_HOME");
        if (pathExists(envKaliteHomeStr)) {
            return envKaliteHomeStr;
        } else {
            NSString *defaultKalitePath = [NSString stringWithFormat:@"%@/.kalite", NSHomeDirectory()];
            if (pathExists(defaultKalitePath)) {
                return defaultKalitePath;
            }
        }
    }
    // Return this if we cannot find a data folder path anywhere.
    return nil;
}


BOOL checkKaliteExecutable() {
    NSString *kalitePath = getKaliteExecutable();
    return pathExists(kalitePath);
}


NSString *getEnvVar(NSString *var) {
    // Get environment variables as per var argument.
    NSString *path = [[[NSProcessInfo processInfo]environment]objectForKey:var];
    return path;
}


/********************
 END Useful Methods
 ********************/


/*
 This will keep track of the last status so that we don't fill the Logs when we check for status every interval.
 So instead of showing "running" status logs every minute, we just show the log when a status change is detected
 based on the timer interval.
 */
- (void)setNewStatus:(enum kaliteStatus)newStatus {
    self.lastStatus = self.status;
    self.status = newStatus;
}


- (void)showStatus:(enum kaliteStatus)status {
    // Enable/disable menu items based on status.
    BOOL canStart = pathExists(getKaliteExecutable()) > 0 ? YES : NO;
    switch (status) {
        case statusFailedToStart:
            [self.startKalite setEnabled:canStart];
            [self.stopKalite setEnabled:NO];
            self.startButton.enabled = canStart;
            self.stopButton.enabled = NO;
            self.openBrowserButton.enabled = NO;
            [self.openInBrowserMenu setEnabled:NO];
            [self.statusItem setImage:[NSImage imageNamed:@"exclaim"]];
            [self.statusItem setToolTip:@"KA Lite failed to start."];
            // Disable custom kalite data path when kalite is still running.
            [self toggleKaliteDataPath:NO];
            break;
        case statusStartingUp:
            [self.startKalite setEnabled:NO];
            [self.stopKalite setEnabled:NO];
            [self.openInBrowserMenu setEnabled:NO];
            self.startButton.enabled = NO;
            self.stopButton.enabled = NO;
            self.openBrowserButton.enabled = NO;
            [self.statusItem setToolTip:@"KA Lite is starting..."];
            [self.statusItem setImage:[NSImage imageNamed:@"loading"]];
            // Disable custom kalite data path when kalite is still running.
            [self toggleKaliteDataPath:NO];
            break;
        case statusOkRunning:
            [self.startKalite setEnabled:NO];
            [self.stopKalite setEnabled:YES];
            [self.openInBrowserMenu setEnabled:YES];
            self.startButton.enabled = NO;
            self.stopButton.enabled = YES;
            self.openBrowserButton.enabled = YES;
            [self.statusItem setImage:[NSImage imageNamed:@"stop"]];
            [self.statusItem setToolTip:@"KA Lite is running."];
            showNotification(@"Running, you can now click on 'Open in Browser' menu.", @"");
            // Disable custom kalite data path when kalite is still running.
            [self toggleKaliteDataPath:NO];
            break;
        case statusStopped:
            [self.startKalite setEnabled:canStart];
            [self.stopKalite setEnabled:NO];
            [self.openInBrowserMenu setEnabled:NO];
            self.startButton.enabled = canStart;
            self.stopButton.enabled = NO;
            self.openBrowserButton.enabled = NO;
            [self.statusItem setImage:[NSImage imageNamed:@"favicon"]];
            [self.statusItem setToolTip:@"KA Lite is stopped."];

            // We don't want to show "Stopped" right after we have loaded the application and checked the status.
            if (self.isLoaded) {
                showNotification(@"Stopped", @"");
            }

            // Enable setting the custom kalite data path.
            [self toggleKaliteDataPath:YES];
            
            break;
        default:
            [self.startKalite setEnabled:canStart];
            [self.stopKalite setEnabled:NO];
            [self.openInBrowserMenu setEnabled:NO];
            self.startButton.enabled = canStart;
            self.stopButton.enabled = NO;
            self.openBrowserButton.enabled = NO;
            if (kaliteExists()) {
                [self.statusItem setImage:[NSImage imageNamed:@"favicon"]];
            } else {
                [self.statusItem setImage:[NSImage imageNamed:@"exclaim"]];
            }
            break;
    }
    self.isLoaded = YES;
}


- (void)startFunction {
    if (self.processCounter != 0) {
        alert(@"KA Lite is still processing, please wait until it is finished.");
        return;
    }
    showNotification(@"Starting...", @"");
    [self setNewStatus:statusStartingUp];
    [self runKalite:@"start"];
}


- (void)stopFunction:(BOOL)isQuit {
    if (self.processCounter != 0) {
        alert(@"KA Lite is still processing, please wait until it is finished.");
        return;
    }
    NSString *msg = @"Stopping";
    if (isQuit) {
        msg = @"Stopping and quitting the application...";
    }
    showNotification(msg, @"");
    [self runKalite:@"stop"];
}


- (void)openFunction {
    // REF: http://stackoverflow.com/a/7129543/845481
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8008/"];
    if( ![[NSWorkspace sharedWorkspace] openURL:url] ) {
        NSString *msg = [NSString stringWithFormat:@" Failed to open url: %@",[url description]];
        showNotification(msg, @"");
    }
}


- (IBAction)start:(id)sender {
    [self startFunction];
}


- (IBAction)startButton:(id)sender {
    [self startFunction];
}


- (IBAction)stop:(id)sender {
    [self stopFunction:false];
}


- (IBAction)stopButton:(id)sender {
    [self stopFunction:false];
}


- (IBAction)customKaliteData:(id)sender {
    self.savePrefs.enabled = TRUE;
}


- (IBAction)loadOnLogin:(id)sender {
    self.savePrefs.enabled = TRUE;
}


- (IBAction)open:(id)sender {
    [self openFunction];
}


- (IBAction)openButton:(id)sender {
    [self openFunction];
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


- (IBAction)kaliteUninstall:(id)sender {
    
    // Get the KA Lite application directory path.
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    // REF: http://stackoverflow.com/questions/7469425/how-to-parse-nsstring-by-removing-2-folders-in-path-in-objective-c
    NSString *kaliteAppDir = [appPath stringByDeletingLastPathComponent];
    // REF: http://stackoverflow.com/questions/1489522/stringbyappendingpathcomponent-hows-it-work
    NSString *kaliteUninstallPath = [[kaliteAppDir stringByAppendingPathComponent:@"/KA-Lite_Uninstall.tool"] stringByStandardizingPath];
    
    if (pathExists(kaliteUninstallPath)) {
        if (confirm(@"Are you sure that you want to uninstall the KA Lite application?")) {
            NSString *kaliteUninstallArg;
            if ([self.deleteKaliteData state]==NSOnState) {
                // Delete the KA Lite data.
                kaliteUninstallArg = @"yes yes";
            } else {
                kaliteUninstallArg = @"yes no";
            }
            const char *runCommand = [[NSString stringWithFormat: @"%@ %@", kaliteUninstallPath, kaliteUninstallArg] UTF8String];
            int runCommandStatus = system(runCommand);
            if (runCommandStatus == 0) {
                self.quitReason = quitByUninstall;
                // Terminate application.
                [[NSApplication sharedApplication] terminate:nil];
            } else {
                alert(@"The KA Lite uninstall did not succeed. You can see the logs at the Console application.");
            }
        }
        
    } else {
        NSString *msg = [NSString stringWithFormat:@"The KA Lite uninstall script is not found at '%@'. You need to reinstall the KA Lite application.", kaliteUninstallPath];
        alert(msg);
    }
}


- (IBAction)uninstallHelp:(id)sender {
    NSString* msg = @"This will uninstall the KA Lite application. \n \nCheck the `Delete KA Lite data folder` option if you want to delete your KA Lite data. \n \nNOTE: This will require admin privileges.";
    [self showPopOver:sender withMsg:msg];
}


- (IBAction)kaliteDataHelp:(id)sender {
    NSString* msg = @"This will set the KALITE_HOME environment variable to the selected KA Lite data location. \n \nClick the 'Apply' button to save your changes and click the 'Start KA Lite' button to use your new data location. \n \nNOTE: To use your existing KA Lite data, manually copy it to the selected KA Lite data location.\n \nFor more information, please refer to the README document.";
    [self showPopOver:sender withMsg:msg];
}


- (void)closeSplash {
    [splash orderOut:self];
}


- (void)showPreferences {
    [splash orderOut:self];
    [self loadPreferences];
    [window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
    // REF: http://stackoverflow.com/questions/6994541/cocoa-showing-a-window-on-top-without-giving-it-focus
    [window setLevel:NSFloatingWindowLevel];
    self.savePrefs.enabled = FALSE;
}


/*
 Checks if environment for running KA Lite is good:
 1. `kalite` executable exists
 2. environment variables: KALITE_PYTHON, KALITE_HOME
 3. Custom KA Lite data path.
*/
- (BOOL)checkSetup:(BOOL)showIt {
    NSString *title = @"The KA Lite installation is incomplete.";
    NSString *msg = @"";
    BOOL isOk = YES;

    // Check the kalite executable.
    if (! checkKaliteExecutable()) {
        msg = [NSString stringWithFormat:@"%@\n* The KA Lite executable cannot be found.", msg];
        isOk = NO;
    }

//    // Check the environment variables.
//    if (! checkEnvVars()) {
//        msg = [NSString stringWithFormat:@"%@\n* One of the KALITE_PYTHON or KALITE_HOME environment variables is invalid.", msg];
//        isOk = NO;
//    }
//
//    // Check the custom KA Lite data path.
//    NSString *dataPath = getKaliteDataPath();
//    if (dataPath == nil) {
//        msg = [NSString stringWithFormat:@"%@\n* The custom KA Lite data path is invalid, please check the KALITE_HOME environment variable value.", msg];
//        isOk = NO;
//    }
//
//    if (showIt == YES && isOk == NO) {
//        msg = [NSString stringWithFormat:@"%@  Please try to re-install KA Lite to attempt to fix the issue/s.%@", title, msg];
//        showNotification(title, msg);
//    }
    return isOk;
}


// Checks for default preferences, sets them accordingly, and saves the .plist.
// Returns YES if defaults preferences were set, otherwise NO.
- (BOOL)registerDefaultPreferences {
    
    NSString *dataPath = getKaliteDataPath();
    if (dataPath == nil) {
        NSLog(@"The default KA Lite data path is nil, please check the KALITE_HOME environment variable value or re-install KA Lite.");
        return NO;
    }
    NSDictionary *dict = @{
                           @"version": self.version,
                           @"autoLoadOnLogin": @YES,
                           @"autoStartOnLoad": @YES,
                           @"customKaliteData": dataPath
                           };
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // MUST: Check a key in the default preferences and override with the default values if non-extant.
    NSNumber *version = [defaults objectForKey:@"version"];
    if (version == nil) {
        [defaults registerDefaults:dict];
        [defaults setValuesForKeysWithDictionary:dict];
        BOOL result = [defaults synchronize];
        
        // TODO(cpauya): Let's perform the actions based on the values of the preferences.
        // 1. autoLoadOnLogin
        // 2. autoStartOnLoad
        [self setEnvVarsAndPlist];
        return YES;
    }
    self.kaliteVersion.stringValue = version;
    return NO;
}


- (void)loadPreferences {
    
    // MUST: Check for default preferences first before actually loading the stored preferences.
    // It's possible that the .plist was deleted while the .app is loaded, so this makes sure
    // we still load the default preferences just in case.
    [self registerDefaultPreferences];
    
    NSString *kaliteDataPath = getKaliteDataPath();
    if (!kaliteDataPath) {
        showNotification(@"KA Lite data folder is not found. Click the `Start KA Lite` button to auto-create the KA Lite data folder.", @"");
    }
    NSString *standardizedPath = [kaliteDataPath stringByStandardizingPath];
    self.customKaliteData.stringValue = standardizedPath;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *state = [defaults objectForKey:@"autoLoadOnLogin"];
    if (state == nil || [state boolValue]){
        self.loadOnLogin.state = YES;
    } else {
        self.loadOnLogin.state = NO;
    }
}


- (void)savePreferences {
    /*
     1. Save the preferences: REF: http://stackoverflow.com/questions/10148788/xcode-cocoa-app-preferences
     2. Run `kalite manage setup` if no database was found.
     */
    
    // Stop KA Lite
    [self stopFunction:false];
    
    // Save the preferences.
    // REF: http:iosdevelopertips.com/core-services/encode-decode-using-base64.html
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // Set autoLoadOnLogin value, defaults to YES.
    NSInteger state = [self.loadOnLogin state];
    if (state == NSOffState) {
        [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"autoLoadOnLogin"];
    } else {
        [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"autoLoadOnLogin"];
    }
    
    NSString *customKaliteData = [[self.customKaliteData URL] path];
    if (pathExists(customKaliteData)) {
        [prefs setObject:customKaliteData forKey:@"customKaliteData"];
    }
    
    // REF: https:github.com/iwasrobbed/Objective-C-CheatSheet#storing-values
    // Handle the NO Boolean return if unsuccessful.
    BOOL result = [prefs synchronize];
    if (! result) {
        showNotification(@"Sorry but your preferences cannot be saved, please check the Console logs.", @"");
    }
    
    [self setEnvVarsAndPlist];
    

    // Close the preferences dialog after a successful save.
    [window orderOut:[window identifier]];
}


- (void)showPopOver:(id)sender withMsg:(NSString*) msg {
    [popoverMsg setStringValue:msg];
    
    // Show the popover first, then set it's size so it is rendered correctly.
    [popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxXEdge];

    // REF: http://stackoverflow.com/a/16239550/845481
    // Getting NSTextView to perfectly fit its contents
    NSString *text = popoverMsg.stringValue;
    NSSize newSize = NSMakeSize(popoverMsg.bounds.size.width, 0);
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
    NSRect bounds = [text boundingRectWithSize:newSize options:options attributes:nil];
    // TODO(cpauya): Using this code on a popover with shorter height yields an extra space at the
    // bottom.  Find a way to remove that without affecting the other popover with longer height.
    NSRect rect = NSMakeRect(0, 0, newSize.width, bounds.size.height + 50);
    popoverMsg.frame = rect;
    popover.contentSize = rect.size;
}


- (BOOL)setEnvVarsAndPlist {
    /*
    This function sets the KALITE_HOME environment variable based on the custom KA Lite data path and
    then it sets the .plist file contents so the env var is used when computer is rebooted.
    */

    // REF: http://stackoverflow.com/questions/99395/how-to-check-if-a-folder-exists-in-cocoa-objective-c

    // This is needed to display the proper menu bar icon when applying the preferences.
    [self setNewStatus:statusCouldNotDetermineStatus];
    
    // MUST: Check if ~/Library/LaunchAgents/ path exists and create it if it doesn't.
    // We do this because some fresh install of Mac OS X does not have this folder.
    NSString *libraryLaunchAgentsPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Library/LaunchAgents/"];
    if (!pathExists(libraryLaunchAgentsPath)) {
        // REF: http://stackoverflow.com/questions/99395/how-to-check-if-a-folder-exists-in-cocoa-objective-c
        // Create ~/Library/LaunchAgents/ path.
        NSError * error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath: libraryLaunchAgentsPath
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:&error];
        if (!success) {
            NSLog(@"Failed to create %@ directory", libraryLaunchAgentsPath);
            return FALSE;
        }
    }
    
    // Set the KALITE_HOME environment variable using the system() function
    // so that it will be updated if already set and used by the app.
    NSString *kaliteDataPath = getKaliteDataPath();
    showNotification([NSString stringWithFormat:@"Setting KALITE_HOME environment variable to %@...", kaliteDataPath], @"");
    if (!kaliteDataPath) {
        showNotification(@"KA Lite data folder is not found. Click the `Start KA Lite` button to auto-create the KA Lite data folder.", @"");
        return FALSE;
    }
    NSString *command = [NSString stringWithFormat:@"launchctl setenv KALITE_HOME \"%@\"", kaliteDataPath];
    const char *cmd = [command UTF8String];
    int i = system(cmd);
    if (i != 0) {
        showNotification(@"Failed to set KALITE_HOME env.", @"");
        return FALSE;
    }
    
    // Use a different .plist name because the LaunchDaemon does not load plists with duplicate names.
    // We already have /Library/LaunchAgents/org.learningequality.kalite.plist for setting the KALITE_PYTHON env var,
    // so we name this into: ~/Library/LaunchAgents/org.learningequality.kalite.user.plist.
    NSString *plist = @"org.learningequality.kalite.user.plist";
    NSString *target = [NSString stringWithFormat:@"%@%@", libraryLaunchAgentsPath, plist];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] init];
    [plistDict setObject:plist forKey:@"Label"];

    // If autoLoadOnLogin value is TRUE, append the command to "open the Kalite.app" to the plist.
    NSString *kaliteHomeStr = [NSString stringWithFormat:@"%@",
                               [NSString stringWithFormat:@"launchctl setenv KALITE_HOME \"%@\"", kaliteDataPath]
                               ];    
    NSString *launchStr = [NSString stringWithFormat:@"%@", kaliteHomeStr];
    // Check for a not-NO here because the preference also be nil if not yet set, to which we treat it as YES since
    // we want it to default to YES.
    NSNumber *state = [[NSUserDefaults standardUserDefaults] objectForKey:@"autoLoadOnLogin"];
    if ([state boolValue] != NO){
        NSString *kaliteAppPath = [NSString stringWithFormat:@"open %@", [[NSBundle mainBundle] bundlePath]];
        launchStr = [NSString stringWithFormat:@"%@ ; %@", kaliteHomeStr, kaliteAppPath];
    }

    // More contents for the .plist command.
    NSArray *arr = @[@"sh", @"-c", launchStr];
    [plistDict setObject:arr forKey:@"ProgramArguments"];
    [plistDict setObject:[NSNumber numberWithBool:TRUE] forKey:@"RunAtLoad"];
    [plistDict setObject:self.version forKey:@"version"];

    // Write the formed content to set the KALITE_HOME env var to the .plist.
    NSLog([NSString stringWithFormat:@"Writing the .plist for the KALITE_HOME environment variable... %@", plistDict]);
    BOOL ret = [plistDict writeToFile:target atomically:YES];
    if (ret == NO) {
        NSLog([NSString stringWithFormat:@"Failed to save .plist file!  Result: %hhd", ret]);
        return FALSE;
    }
    NSLog([NSString stringWithFormat:@"Saved .plist file to %@", target]);

    NSString *msg = [NSString stringWithFormat:@"Successfully set KALITE_HOME env to %@.", kaliteDataPath];
    showNotification(msg, @"");
    return TRUE;
}


- (void)discardPreferences {
    // TODO(cpauya): Discard changes and load the saved preferences.
    [window orderOut:[window identifier]];
}


- (void)startKaliteTimer {
    // TODO(cpauya): Use initWithFireDate of NSTimer instance.
    // TODO(amodia): Check if kalite environment variables change.
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(getKaliteStatus)
                                   userInfo:nil
                                    repeats:YES];
}


- (enum kaliteStatus)getKaliteStatus {
    return [self runKalite:@"status"];
}


@end
