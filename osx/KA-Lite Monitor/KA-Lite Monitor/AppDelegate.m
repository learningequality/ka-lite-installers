//
//  AppDelegate.m
//  KA-Lite Monitor
//
//  Created by cyril on 1/20/15.
//  Copyright (c) 2015 FLE. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
//    @property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

@synthesize stringUsername, stringPassword, stringConfirmPassword, startKalite, stopKalite, openInBrowserMenu;


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
        NSString *localSettings = getLocalSettingsPath();
        if (localSettings == nil) {
            NSLog(@"local_settings.py not found, must show preferences...");
            mustShowPreferences = true;
        } else {
            NSLog(@"FOUND local_settings.py!");
        }
        
        NSString *database = getDatabasePath();
        if (database == nil) {
            NSLog(@"Database not found, must show preferences.");
            mustShowPreferences = true;
        } else {
            NSLog(@"FOUND database!");
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


void copyLocalSettings() {
    NSString *source = [[NSBundle mainBundle] pathForResource:@"local_settings" ofType:@"default"];
    if (pathExists(source)) {
        NSString *target = getResourcePath(@"ka-lite/kalite/local_settings.py");
        NSString *command = [NSString stringWithFormat:@"cp \"%@\" \"%@\"", source, target];
        const char *cmd = [command UTF8String];
        int i = system(cmd);
        if (i == 0) {
            showNotification(@"Copied local_settings.default to local_settings.py.");
        } else {
            showNotification(@"Failed to copy `local_settings.default` to `local_settings.py`!");
        }
    } else {
        showNotification(@"The `bin/kalite` executable does not exist!");
    }
}


NSString *getResourcePath(NSString *pathToAppend) {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:pathToAppend];
    path = [path stringByStandardizingPath];
    return path;
}


NSString *getLocalSettingsPath() {
    NSString *localSettings = [[NSBundle mainBundle] pathForResource:@"ka-lite/kalite/local_settings" ofType:@"py"];
    return localSettings;
}


NSString *getDatabasePath() {
    NSString *database = [[NSBundle mainBundle] pathForResource:@"ka-lite/kalite/database/data" ofType:@"sqlite"];
    return database;
}


BOOL pathExists(NSString *path) {
    // REF: http://www.exampledb.com/objective-c-check-if-file-exists.htm
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    return exists;
}


BOOL kaliteExists() {
    NSString *kaliteDir;
    NSString *kalitePath;
    kaliteDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ka-lite"];
    kaliteDir = [kaliteDir stringByStandardizingPath];
    kalitePath = [kaliteDir stringByAppendingString:@"/bin/kalite"];
    if (pathExists(kalitePath)){
        return TRUE;
    }
    return FALSE;
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
        kaliteDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ka-lite"];
        kaliteDir = [kaliteDir stringByStandardizingPath];
        
        pyrun = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"pyrun-2.7/bin/pyrun"];
        pyrun = [pyrun stringByStandardizingPath];
        
        kalitePath = [kaliteDir stringByAppendingString:@"/bin/kalite"];
        
        kaliteCmd = [NSString stringWithFormat: @"export KALITE_DIR=\"%@\"; export KALITE_PYTHON=\"%@\"; \"%@\"",
                    kaliteDir, pyrun, kalitePath];
        
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
            [self.startKalite setEnabled:NO];
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
        alert(@"Sorry but the `bin/kalite` executable is not found!");
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
    
    // Copy `local_settings.default` if no `local_settings.py` was found.
    NSString *localSettingsPath = getLocalSettingsPath();
    if (localSettingsPath == nil) {
        copyLocalSettings();
    }
    
    // Automatically run `kalite manage setup` if no database was found.
    NSString *databasePath = getDatabasePath();
    if (databasePath == nil) {
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
    showNotification(@"Running `kalite manage setup`.");
    NSString *cmd = [NSString stringWithFormat:@"manage setup --username %@ --password %@ --noinput",
                        self.username, self.password];
    enum kaliteStatus status = [self runKalite:cmd];
    [self getKaliteStatus];
    return status;
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
