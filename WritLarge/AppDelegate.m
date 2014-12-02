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

// get the text to display, from command line or stdin
- (NSString *)text
{
    NSArray *const args=[[NSProcessInfo processInfo] arguments];
    
    if ([args count]>1) { // use command line
        return args[1];
    }
    else { // use stdin
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

- (void)windowWillClose:(NSNotification *)notification
{
    [self quit];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *const text=[[self text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([text length]>0) {
        NSLog(@"Showing large text window.");
        
        self.window=[[LargeTextWindow alloc] init];
        [self.window setDelegate:self];
        [self.window showWithText:text];
    }
    else {
        NSLog(@"No text supplied.");
        [self quit];
    }
}

@end
