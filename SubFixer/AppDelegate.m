//
//  AppDelegate.m
//  SubFixer
//
//  Created by Ahmad on 8/24/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

#import "AppDelegate.h"
#import "SFConverter.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    
    [SFConverter fixSubtitleAtPath:filename];
    
    return YES;
    
}

@end
