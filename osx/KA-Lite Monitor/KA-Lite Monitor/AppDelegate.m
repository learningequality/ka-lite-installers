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

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // Setup the status menu item.
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setImage:[NSImage imageNamed:@"play"]];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setToolTip:@"Click to show the KA-Lite menu items."];

    // We need to run setup if local_settings.py or database does not exist.
    /*
     TODO(cpauya):
     1. show window for progress of setup
     2. copy local_settings_sample.py to KALITE_DIR/kalite/local_settings.py
     3. run `kalite manage setup --username admin --password password123 --noinput`
     */

    @try {
        NSString *localSettings = [[NSBundle mainBundle] pathForResource:@"ka-lite/kalite/local_settings" ofType:@"py"];
        if (localSettings == nil) {
            NSLog(@"local_settings.py not found, copying local_settings.default...");
            copyLocalSettings();
        } else {
            NSLog(@"FOUND local_settings.py!");
        }
        
        NSString *database = [[NSBundle mainBundle] pathForResource:@"ka-lite/kalite/database/data" ofType:@"sqlite"];
        if (database == nil) {
            NSLog(@"Database not found, will run setup.");
            // TODO(cpauya): prompt user for admin account credentials.
            NSString *username = @"admin";
            NSString *password = @"password123";
            NSString *cmd = [NSString stringWithFormat:@"manage setup --username %@ --password %@ --noinput", username, password];
            runKalite(cmd);
        } else {
            NSLog(@"FOUND database!");
        }
        NSLog(@"KA Lite was successfully started!");
    }
    @catch (NSException *ex) {
        NSLog(@"KA Lite had an Error: %@", ex);
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.0
                                     target:self
                                   selector:@selector(closeSplash)
                                   userInfo:nil
                                    repeats:NO];
    //    [self closeSplash];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    // TODO(cpauya): Confirm quit action from user.
    runKalite(@"stop");
    NSLog(@"==> quitting...");
}


int copyLocalSettings() {
    NSString *source = [[NSBundle mainBundle] pathForResource:@"local_settings" ofType:@"default"];
    NSLog(@"==> localSettings: %@", source);

    NSString *target = getResourcePath(@"ka-lite/kalite/local_settings.py");
    NSString *command = [NSString stringWithFormat:@"cp \"%@\" \"%@\"", source, target];
    NSLog(@"==> Running command: %@", command);

    const char *cmd = [command UTF8String];
    int i = system(cmd);
    return i;
}


NSString *getResourcePath(NSString *pathToAppend) {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:pathToAppend];
    path = [path stringByStandardizingPath];
    return path;
}


// REF: http://stackoverflow.com/a/10284037/845481
// convert const char* to NSString * and convert back - _NSAutoreleaseNoPool()
int runKalite(NSString *command) {
    // It needs the `KALITE_DIR` and `KALITE_PYTHON` environment variables, so we set them here for every call.
    // TODO(cpauya): We must prompt user on a preferences dialog and persist these perhaps on `local_settings.py`?
    NSString *kaliteDir;
    NSString *pyrun;
    NSString *kalitePath;
    NSString *finalCmd;
    
    @try {
        kaliteDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ka-lite"];
        kaliteDir = [kaliteDir stringByStandardizingPath];
        
        pyrun = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"pyrun-2.7/bin/pyrun"];
        pyrun = [pyrun stringByStandardizingPath];
        
        kalitePath = [kaliteDir stringByAppendingString:@"/bin/kalite"];
        
        finalCmd = [NSString stringWithFormat: @"export KALITE_DIR=\"%@\"", kaliteDir];
        finalCmd = [NSString stringWithFormat: @"%@; export KALITE_PYTHON=\"%@\"", finalCmd, pyrun];
        finalCmd = [NSString stringWithFormat: @"%@; \"%@\" %@", finalCmd, kalitePath, command];
        
        // convert to objective-c string
        const char *exportCommand = [finalCmd UTF8String];
        NSLog(@"==> Running exportCommand %s", exportCommand);
        int i = system(exportCommand);
        
        NSLog(@"==> return is %i... done.", i);
        return i;
    }
    @catch (NSException *ex) {
        NSLog(@"Error running `kalite` %@", ex);
    }
}


- (IBAction)start:(id)sender {
    [self.statusItem setTitle:@"..."];
    int i;
    i = runKalite(@"start");
    [self.statusItem setTitle:@""];
    if (i == 0) {
        [self.statusItem setImage:[NSImage imageNamed:@"stop"]];
        [self.statusItem setToolTip:@"KA-Lite is running."];
    } else {
        [self.statusItem setImage:[NSImage imageNamed:@"exclaim"]];
        [self.statusItem setToolTip:@"KA-Lite has encountered an error, pls check the Console."];
    }
}


- (IBAction)stop:(id)sender {
    NSLog(@"==> Stopping...");
    [self.statusItem setTitle:@"..."];
    int i;
    i = runKalite(@"stop");
    [self.statusItem setTitle:@""];
    if (i == 0) {
        [self.statusItem setImage:[NSImage imageNamed:@"play"]];
        [self.statusItem setTitle:@""];
        [self.statusItem setToolTip:@"KA-Lite is not running."];
    } else {
        [self.statusItem setImage:[NSImage imageNamed:@"exclaim"]];
        [self.statusItem setToolTip:@"KA-Lite has encountered an error, pls check the Console."];
    }
}


- (IBAction)open:(id)sender {
    NSLog(@"==> Opening KA-Lite in browser...");
    // TODO(cpauya): Get the ip address and port from `local_settings.py`.
    // REF: http://stackoverflow.com/a/7129543/845481
    // Open URL with Safari no matter what system browser is set to
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8008/"];
    if( ![[NSWorkspace sharedWorkspace] openURL:url] ) {
        NSLog(@"==> Failed to open url: %@",[url description]);
    }
}


- (IBAction)startOnBoot:(id)sender {
    NSLog(@"==> Start on boot...");
// TODO(cpauya): This is a test, remove when done!
//    int i = runKalite(@"manage shell");
}


- (IBAction)checkForUpdatesAutomatically:(id)sender {
    NSLog(@"==> Checking for updates automatically...");
}


- (IBAction)closeSplash:(id)sender {
    [self closeSplash];
}


- (IBAction)showPreferences:(id)sender {
    NSLog(@"==> showing preferences...");
//    [window orderFront:[window identifier]];
    [window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}


- (IBAction)hidePreferences:(id)sender {
    NSLog(@"==> hiding preferences...");
    [window orderOut:[window identifier]];
}

- (IBAction)savePreferences:(id)sender {
    NSLog(@"==> saving preferences...");
    [window orderOut:[window identifier]];
}


- (IBAction)discardPreferences:(id)sender {
    NSLog(@"==> discarding preferences...");
    [window orderOut:[window identifier]];
}


- (void)closeSplash {
    [splash orderOut:self];
    [window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

@end
