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

@interface AppDelegate ()
//    @property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

@synthesize startKalite, stopKalite, openInBrowserMenu, kaliteVersion, customKaliteData, startOnLogin, kaliteDataHelp;


// REF: http://objcolumnist.com/2009/08/09/reopening-an-applications-main-window-by-clicking-the-dock-icon/
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    if(flag==NO) {
        [self showPreferences];
    }
    return YES;	
}


// TODO(amodia): Show menu bar on dock icon.
//- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
//    return self.statusMenu;
//}


//<##>applicationDidFinishLaunching
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // Setup the status menu item.
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setImage:[NSImage imageNamed:@"favicon"]];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setToolTip:@"Click to show the KA Lite menu items."];
    
    [self.kaliteDataHelp setToolTip:@"This will set the KALITE_HOME environment variable to the selected KA Lite data location. \n \nClick the 'Apply' button to save your changes and click the 'Start KA Lite' button to use your new data location. \n \nNOTE: To use your existing KA Lite data, manually copy it to the selected KA Lite data location."];

    // Set the default status.
    self.status = statusCouldNotDetermineStatus;
    [self getKaliteStatus];
    
    // We need to show preferences if the following does not exist:
    // 1. database does not exist
    // 2. symlinked `kalite` executable
    // Apply button is clicked, we run `kalite manage setup`.
    bool mustShowPreferences = false;
    @try {
        checkEnvVars();
        NSString *database = getDatabasePath();
        if (!pathExists(database)) {
            NSLog(@"Database not found, must show preferences.");
            mustShowPreferences = true;
        } else {
            NSLog([NSString stringWithFormat:@"FOUND database at %@!", database]);
        }

        NSString *kalite = getUsrBinKalite();
        if (!pathExists(kalite)) {
            NSLog(@"kalite executable is not found, must show preferences.");
            mustShowPreferences = true;
            [self showStatus:statusFailedToStart];
            showNotification(@"Kalite executable is not found. You need to reinstall the KA Lite application.");
            
        } else {
            NSLog([NSString stringWithFormat:@"FOUND kalite at %@!", kalite]);
            showNotification(@"KA Lite is now loaded.");
            [self runKalite:@"--version"];
            [self getKaliteStatus];
        }
    }
    @catch (NSException *ex) {
        NSLog(@"KA Lite had an Error: %@", ex);
    }
    
    void *sel = @selector(closeSplash);
    if (mustShowPreferences) {
        sel = @selector(showPreferences);
    }
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:sel userInfo:nil repeats:NO];
    [self startKaliteTimer];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    // TODO(cpauya): Confirm quit action from user.
    if (kaliteExists()) {
        showNotification(@"Stopping and quitting the application...");
        // Stop KA Lite
        [self stopFunction];
    }
}


/********************
  Useful Methods
********************/


BOOL checkEnvVars() {
    // MUST: Check the KALITE_PYTHON environment variable
    // and default it to the .app Resources folder if not yet set.
    NSString *kalitePython = getEnvVar(@"KALITE_PYTHON");

    if (!pathExists(kalitePython)) {
        NSString *msg = @"The KALITE_PYTHON environment variable is not set";
        showNotification(msg);
        return FALSE;
    }
    return TRUE;
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
    
    kalitePath = getUsrBinKalite();
    
    kaliteHomeEnv = [[NSMutableDictionary alloc] init];
    
    NSString *kaliteHomePath = getCustomKaliteHomePath();
    
    // Set KALITE_HOME environment
    [kaliteHomeEnv addEntriesFromDictionary:[[NSProcessInfo processInfo] environment]];
    [kaliteHomeEnv setObject:kaliteHomePath forKey:@"KALITE_HOME"];
    
    //REF: http://stackoverflow.com/questions/386783/nstask-not-picking-up-path-from-the-users-environment
    NSTask* task = [[NSTask alloc] init];
    NSString *kaliteCommand = [NSString stringWithFormat:@"kalite %@",command];
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
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSString *outStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self displayLogs:outStr];
        
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


/*
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
*/


BOOL kaliteExists() {
    NSString *kalitePath = getUsrBinKalite();
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
    NSString *kalitePath = getUsrBinKalite();
    enum kaliteStatus oldStatus = self.status;
    
    int status = [[aNotification object] terminationStatus];

    taskArguments = [[aNotification object] arguments];
    statusArguments = [[NSArray alloc]initWithObjects:@"-l", @"-c", @"kalite status", nil];
    NSSet *taskArgsSet = [NSSet setWithArray:taskArguments];
    NSSet *statusArgsSet = [NSSet setWithArray:statusArguments];
    
    if (self.processCounter >= 1) {
        self.processCounter -= 1;
    }
    if (self.processCounter != 0) {
        return self.status;
    }
    
    if (checkUsrBinKalitePath()) {
        if ([taskArgsSet isEqualToSet:statusArgsSet]) {
            // MUST: The result is on the 9th bit of the returned value.  Not sure why this
            // is but maybe because of the returned values from the `system()` call.  For now
            // we shift 8 bits to the right until we figure this one out.  TODO(cpauya): fix later
            if (status >= 255) {
                status = status >> 8;
            }
            self.status = status;
            if (oldStatus != status) {
                [self showStatus:self.status];
            }
            return self.status;
        } else {
            // If command is not "status", run `kalite status` to get status of ka-lite.
            // We need this check because this may be called inside the kA-Lite timer.
            NSLog(@"Fetching `kalite status`...");
            [self showStatus:self.status];
            [self getKaliteStatus];
            return self.status;
        }
    } else {
        self.status = statusCouldNotDetermineStatus;
        [self showStatus:self.status];
        showNotification(@"The `kalite` executable does not exist!");
    }
    return self.status;
}


- (enum kaliteStatus)runKalite:(NSString *)command {
    @try {
        // MUST: This will make sure the process to run has access to the environment variable
        // because the .app may be loaded the first time.
        
        if (checkUsrBinKalitePath()) {
            [self runTask:command];
        }
    }
    @catch (NSException *ex) {
        self.status = statusCouldNotDetermineStatus;
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


void showNotification(NSString *subtitle) {
    // REF: http://stackoverflow.com/questions/12267357/nsusernotification-with-custom-soundname?rq=1
    // TODO(cpauya): These must be ticked by user on preferences if they want notifications, sounds, or not.
    NSUserNotification* notification = [[NSUserNotification alloc]init];
    notification.title = @"KA Lite";
    notification.subtitle = subtitle;
    notification.soundName = @"Basso.aiff";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    // The notification may be optional (based on user preferences) but we must show it on the logs.
    NSLog(subtitle);
}

- (void)disableKaliteDataPath{
    // Disable custom kalite data path when kalite is still running.
    self.customKaliteData.enabled = NO;
    [self.customKaliteData setToolTip:@"KA Lite is still running. Stop KA Lite to select data path."];
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


NSString *getUsrBinKalite() {
    return @"/usr/local/bin/kalite";
}

NSString *getCustomKaliteHomePath() {
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
                return [NSString stringWithFormat:@"%@/.kalite", NSHomeDirectory()];
            } else {
                showNotification(@"KA Lite data is not found. Click `Start KA Lite` button to create the KA Lite data. ");
            }
        }
    }
    
    return nil;
}


BOOL *checkUsrBinKalitePath() {
    NSString *kalitePath = getUsrBinKalite();
    if (pathExists(kalitePath)) {
        return TRUE;
    }
    return false;
}


NSString *getEnvVar(NSString *var) {
    // Get environment variables as per var argument.
    NSString *path = [[[NSProcessInfo processInfo]environment]objectForKey:var];
    return path;
}


/********************
 END Useful Methods
 ********************/


- (void)showStatus:(enum kaliteStatus)status {
    // Enable/disable menu items based on status.
    BOOL canStart = pathExists(getUsrBinKalite()) > 0 ? YES : NO;
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
            self.customKaliteData.enabled = NO;
            [self.customKaliteData setToolTip:@"KA Lite failed to start"];
            
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
            [self disableKaliteDataPath];
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
            showNotification(@"You can now click on 'Open in Browser' menu");
            [self disableKaliteDataPath];
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
            showNotification(@"Stopped");
            self.customKaliteData.enabled = YES;
            [self.customKaliteData setToolTip:@"Select KA Lite data path."];
            break;
        default:
            [self.startKalite setEnabled:canStart];
            [self.stopKalite setEnabled:NO];
            [self.openInBrowserMenu setEnabled:NO];
            self.startButton.enabled = canStart;
            self.stopButton.enabled = NO;
            self.openBrowserButton.enabled = NO;
            if (kaliteExists()){
                [self.statusItem setImage:[NSImage imageNamed:@"favicon"]];
            }else{
                [self.statusItem setImage:[NSImage imageNamed:@"exclaim"]];
            }
//            [self.statusItem setToolTip:@"KA-Lite has encountered an error, pls check the Console."];
//            showNotification(@"Has encountered an error, pls check the Console.");
            break;
    }
}


- (void)startFunction {
    showNotification(@"Starting...");
    [self showStatus:statusStartingUp];
    if (self.processCounter != 0) {
        alert(@"KA Lite is still processing, please wait until it is finished.");
        return;
    }
    [self runKalite:@"start"];
}


- (IBAction)start:(id)sender {
    [self startFunction];
}


- (IBAction)startButton:(id)sender {
    [self startFunction];
}


- (void)stopFunction {
    showNotification(@"Stopping...");
    if (self.processCounter != 0) {
        alert(@"KA Lite is still processing, please wait until it is finished.");
        return;
    }
    [self runKalite:@"stop"];
}


- (IBAction)stop:(id)sender {
    [self stopFunction];
}


- (IBAction)stopButton:(id)sender {
    [self stopFunction];
}


- (void)openFunction {
    // TODO(cpauya): Get the ip address and port from `local_settings.py` or preferences.
    // REF: http://stackoverflow.com/a/7129543/845481
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8008/"];
    if( ![[NSWorkspace sharedWorkspace] openURL:url] ) {
        NSString *msg = [NSString stringWithFormat:@" Failed to open url: %@",[url description]];
        showNotification(msg);
    }
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
}


- (void)loadPreferences {
    NSString *customKaliteData = getCustomKaliteHomePath();
    NSString *standardizedPath = [customKaliteData stringByStandardizingPath];
    self.customKaliteData.stringValue = standardizedPath;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoStartOnLogin"]){
        self.startOnLogin.state = YES;
    }
}


- (void)savePreferences {
    /*
     1. Save the preferences: REF: http://stackoverflow.com/questions/10148788/xcode-cocoa-app-preferences
     2. Run `kalite manage setup` if no database was found.
     */
    
    // Stop KA Lite
    [self stopFunction];
    
    // Save the preferences.
    // REF: http:iosdevelopertips.com/core-services/encode-decode-using-base64.html
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //Set autoStartOnLogin value.
    [prefs setBool:FALSE forKey:@"autoStartOnLogin"];
    if ([self.startOnLogin state] == NSOnState) {
        [prefs setBool:TRUE forKey:@"autoStartOnLogin"];
    }
    
    NSString *customKaliteData = [[self.customKaliteData URL] path];
    if (pathExists(customKaliteData)) {
        [prefs setObject:customKaliteData forKey:@"customKaliteData"];
    }
    
    // REF: https:github.com/iwasrobbed/Objective-C-CheatSheet#storing-values
    [prefs synchronize];
    
    if (!setEnvVars()) {
        NSString *msg = @"Failed to set KALITE_HOME env";
        showNotification(msg);
    };
    
    
    // Automatically run `kalite manage setup` if no database was found.
    NSString *databasePath = getDatabasePath();
    if (!pathExists(databasePath)) {
        if (checkUsrBinKalitePath()) {
            alert(@"Will now run KA Lite setup, it will take a few minutes.  Please wait until prompted that setup is done.");
            enum kaliteStatus status = [self setupKalite];
            showNotification(@"Setup is finished!  You can now start KA Lite.");
            [self.statusItem setImage:[NSImage imageNamed:@"exclaim"]];
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
    
    // Terminate application.
//    [[NSApplication sharedApplication] terminate:nil];
}


BOOL setEnvVars() {
    
    //REF: http://stackoverflow.com/questions/99395/how-to-check-if-a-folder-exists-in-cocoa-objective-c
    // Check if home Library/LaunchAgents/ path exist.
    NSString *LibraryLaunchAgentPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Library/LaunchAgents/"];
    NSFileManager*fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:LibraryLaunchAgentPath]) {
        //REF: http://stackoverflow.com/questions/99395/how-to-check-if-a-folder-exists-in-cocoa-objective-c
        // Create home Library/LaunchAgents/ path.
        NSError * error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath: LibraryLaunchAgentPath
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:&error];
        if (!success) {
            NSLog(@"Failed to create %@ directory", LibraryLaunchAgentPath);
            return FALSE;
        }
    }
    
    showNotification(@"Setting KALITE_HOME environment variable...");
    NSString *kaliteHomePath = getCustomKaliteHomePath();
    NSString *command = [NSString stringWithFormat:@"launchctl setenv KALITE_HOME \"%@\"", kaliteHomePath];
    const char *cmd = [command UTF8String];
    int i = system(cmd);
    if (i == 0) {
        NSString *msg = [NSString stringWithFormat:@"Successfully set KALITE_HOME env to %@.", kaliteHomePath];
        showNotification(msg);
    } else {
        showNotification(@"Failed to set KALITE_HOME env.");
        return FALSE;
    }
    
    NSString *KaliteHomeStr = [NSString stringWithFormat:@"%@",
                               [NSString stringWithFormat:@"launchctl setenv KALITE_HOME \"%@\"", kaliteHomePath]
                               ];
    
    // Use org.learningequality.kalite.prefs name to the KALITE_HOME plist because we have already org.learningequality.kalite plist at root /Library/LaunchAgents.
    NSString *org = @"org.learningequality.kalite.prefs";
    NSString *target = [NSString stringWithFormat:@"%@/Library/LaunchAgents/%@.plist", NSHomeDirectory(), org];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] init];
    [plistDict setObject:org forKey:@"Label"];
    
    // Append KA Lite app path to plist if autoStartOnLogin value is TRUE.
    NSString *launchStr = [NSString stringWithFormat:@"%@", KaliteHomeStr];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoStartOnLogin"]){
        NSString *kaliteAppPath = [NSString stringWithFormat:@"open %@", [[NSBundle mainBundle] bundlePath]];
         launchStr = [NSString stringWithFormat:@"%@ ; %@", KaliteHomeStr, kaliteAppPath];
    }
   
    NSArray *arr = @[@"sh", @"-c", launchStr];
    [plistDict setObject:arr forKey:@"ProgramArguments"];
    [plistDict setObject:[NSNumber numberWithBool:TRUE] forKey:@"RunAtLoad"];
    showNotification([NSString stringWithFormat:@"Setting KALITE_HOME environment variable... %@", plistDict]);
    
    // Override org.learningequality.kalite.plist content
    BOOL ret = [plistDict writeToFile:target atomically:YES];
    if (ret == YES) {
        NSLog([NSString stringWithFormat:@"SAVED .plist file to %@", target]);
    } else {
        NSLog([NSString stringWithFormat:@"CANNOT save .plist file!  Result: %hhd", ret]);
        return FALSE;
    }
    return TRUE;
    
}


-(enum kaliteStatus)setupKalite {
    NSString *cmd = [NSString stringWithFormat:@"manage setup --noinput"];
    NSString *msg = [NSString stringWithFormat:@"Running `kalite manage setup`"];
    showNotification(msg);
    enum kaliteStatus status = [self runKalite:cmd];
    [self getKaliteStatus];
    return status;
}


- (void)discardPreferences {
    // TODO(cpauya): Discard changes and load the saved preferences.
    [window orderOut:[window identifier]];
}


- (void)startKaliteTimer {
    // TODO(cpauya): Use initWithFireDate of NSTimer instance.
    // TODO(amodia): Check if kalite environment variables change.
    [NSTimer scheduledTimerWithTimeInterval:60.0
                                    target:self
                                    selector:@selector(getKaliteStatus)
                                    userInfo:nil
                                    repeats:YES];
}


- (enum kaliteStatus)getKaliteStatus {
    return [self runKalite:@"status"];
}


@end
