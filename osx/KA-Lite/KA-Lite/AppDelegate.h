//
//  AppDelegate.h
//  KA-Lite
//
//  Created by cyril on 1/20/15.
//  Copyright (c) 2015 FLE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// REF: http://stackoverflow.com/a/6064675/845481
// How to open a new window in a Cocoa application on launch
@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
    IBOutlet id splash;
    IBOutlet id window;
}


@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSButton *stopButton;
@property (weak) IBOutlet NSButton *openBrowserButton;
@property (weak) IBOutlet NSTextField *kaliteVersion;
@property (weak) IBOutlet NSPathControl *customKaliteData;
@property (weak) IBOutlet NSButton *loadOnLogin;
@property (weak) IBOutlet NSButton *startOnLoad;

@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSStatusItem *startItem;
@property (strong, nonatomic) NSStatusItem *stopItem;
@property (strong, nonatomic) NSStatusItem *openItem;
@property (unsafe_unretained) IBOutlet NSTextView *taskLogs;

// It will set as YES if port 8008 is not available.
@property BOOL isPortAlert;
// It will set as YES when startFunction() will execute.
@property BOOL iskaliteStart;

@property BOOL isLoaded;
@property BOOL autoStartOnLoad;
@property NSString *version;

@property (weak) IBOutlet NSMenuItem *startKalite;
@property (weak) IBOutlet NSMenuItem *stopKalite;
@property (weak) IBOutlet NSMenuItem *openInBrowserMenu;

@property (weak) IBOutlet NSButton *resetAppAction;

@property (weak) IBOutlet NSButton *deleteKaliteData;
@property (weak) IBOutlet NSButton *kaliteUninstallHelp;
@property (weak) IBOutlet NSButton *kaliteDataHelp;
@property (weak) IBOutlet NSButton *savePrefs;

@property (weak) IBOutlet NSPopover *popover;
@property (weak) IBOutlet NSTextField *popoverMsg;
@property (weak) IBOutlet NSView *aView;

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
@property enum kaliteStatus lastStatus;

enum kaliteQuitReason {
    quitByUnknown = 0,
    quitByUser = 1,
    quitByOS = 2,
    quitByApp = 3,
    quitByUninstall = 4
};
@property enum kaliteQuitReason quitReason;


- (void)closeSplash;


@end
