//
//  AppDelegate.h
//  KA-Lite Monitor
//
//  Created by cyril on 1/20/15.
//  Copyright (c) 2015 FLE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// REF: http://stackoverflow.com/a/6064675/845481
// How to open a new window in a Cocoa application on launch
@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet id splash;
    IBOutlet id window;
}

- (void)closeSplash;

@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSStatusItem *startItem;
@property (strong, nonatomic) NSStatusItem *stopItem;
@property (strong, nonatomic) NSStatusItem *openItem;
@property (unsafe_unretained) IBOutlet NSTextView *taskLogs;
@property BOOL kaliteIsRunning;
@property int kaliteFirstLoad;

@property (strong, nonatomic) IBOutlet NSString *username;
@property (strong, nonatomic) IBOutlet NSString *password;
@property (strong, nonatomic) IBOutlet NSString *confirmPassword;

// get the string from the user preferences textbox.
@property (weak) IBOutlet NSTextField *stringUsername;
@property (weak) IBOutlet NSSecureTextField *stringPassword;
@property (weak) IBOutlet NSSecureTextField *stringConfirmPassword;

@property (weak) IBOutlet NSMenuItem *startKalite;
@property (weak) IBOutlet NSMenuItem *stopKalite;
@property (weak) IBOutlet NSMenuItem *openInBrowserMenu;

@property (weak) IBOutlet NSButton *resetAppAction;

enum kaliteStatus {
    statusOkRunning = 0,
    statusStopped = 1,
    statusStartingUp = 4,
    statusNotResponding = 5,
    statusFailedToStart = 6,
    statusUncleanShutdown = 7,
    statusUnknownKaliteRunningOnPort = 8,
    statusKaliteServerConfigurationError = 9,
    statusCouldNotReadPidFile = 99,
    statusInvalidPidFile = 100,
    statusCouldNotDetermineStatus = 101
};

@property enum kaliteStatus status;


@end
