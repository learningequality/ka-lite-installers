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

@end
