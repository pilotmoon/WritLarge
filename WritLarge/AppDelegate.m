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
    NSString *result=@"";
    NSArray *const args=[[NSProcessInfo processInfo] arguments];
    
    if ([args count]>1) { // use command line
        for (int i=1; i<[args count]; i++) { // concatenate all arguments
            result = [[result stringByAppendingString:args[i]] stringByAppendingString:@" "];
        }
    }
    else { // use stdin
        NSLog(@"Reading text from stdin. ^D to end.");
        result=[[NSString alloc] initWithData:[[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile] encoding:NSASCIIStringEncoding];
    }
    
    return [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)quit
{
    NSLog(@"Quitting.");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSApplication sharedApplication] terminate:self];
    });
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *text=[self text];
    if ([text length]>0) {
        NSLog(@"Text supplied:\n%@", text);
        [self showWindowWithText:text];
    }
    else {
        NSLog(@"No text supplied.");
        [self quit];
    }
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self quit];
}

- (void)showWindowWithText:(NSString *)text
{
    NSLog(@"Showing large text window.");
    
    LargeTextWindow *const window=[[LargeTextWindow alloc] init];
    [window setDelegate:self];
    [window showWithText:text style:FullScreen];
    self.window=window;
}

@end
