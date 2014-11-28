//
//  AppDelegate.m
//  WritLarge
//
//  Created by Nicholas Moore on 28/11/2014.
//  Copyright (c) 2014 Pilotmoon Software. All rights reserved.
//

#import "AppDelegate.h"
#import "LargeTextWindow.h"

@interface AppDelegate ()
@property (strong) LargeTextWindow *window;
@end

@implementation AppDelegate

- (NSString *)text
{
    NSArray *const args=[[NSProcessInfo processInfo] arguments];
    if ([args count]>1) {
        // get arg if available
        return args[1];
    }
    else {
        // get text from stdin
        NSLog(@"Reading text from stdin. ^D to end.");
        return [[NSString alloc] initWithData:[[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile] encoding:NSASCIIStringEncoding];
    }
}

- (void)quit
{
    NSLog(@"Quitting.");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSApplication sharedApplication] terminate:self];
    });
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *const text=[[self text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([text length]>0) {
        NSLog(@"Text supplied:\n%@", text);
        [self showWindowWithText:text];
    }
    else {
        NSLog(@"No text supplied.");
        [self quit];
    }
}

- (void)showWindowWithText:(NSString *)text
{
    LargeTextWindow *const window=[[LargeTextWindow alloc] init];
    [window setDelegate:self];
    [window setFrame:NSMakeRect(100, 100, 700, 700) display:NO];
    [window center];

    NSLog(@"Showing large text window.");
    [window makeKeyAndOrderFront:self];
    self.window=window;
}

#pragma mark Window delegate methods

- (void)windowDidResignKey:(NSNotification *)notification
{
    [self.window orderOut:self];
    [self quit];
}

@end
