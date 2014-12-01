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
    NSString * text=[self text];
    text=@"ABACUS TIME IS HERE AGAIN! OH YES OH YES. Now, what time is it again? When will the line wrap? Please";
//     text=@"Abacus";
//    text=@"Abacus chris morris";
//    text=@"Abacus chris morris has a programme called on the hour hello hello";
//    text=@"Abacus chris morris has a programme called on the hour hello hello fwhat is the time sir?";
   // text = @"This code assumes you have a reference to a text view configured with a layout manager, text storage, and text container. The text view returns a reference to the layout manager, which then returns the number of glyphs for all the characters in its associated text storage, performing glyph generation if necessary. The for loop then begins laying out the text and counting the resulting line fragments. The NSLayoutManager method lineFragmentRectForGlyphAtIndex:effectiveRange: forces layout of the line containing the glyph at the index passed to it. The method returns the rectangle occupied by the line fragment (here ignored) and, by reference, the range of the glyphs in the line after layout. After the method calculates a line, the NSMaxRangefunction returns the index one greater than the maximum value in the range, that is, the index of the first glyph in the next line. The numberOfLines variable increments, and the for loop repeats, until index is greater than the number of glyphs in the text, at which point numberOfLines contains the number of lines resulting from the layout process, as defined by word wrapping. This strategy causes layout of the entire text contained in the text storage object and calculates the number of lines required to lay it out, regardless of the number of text containers filled or text views required to display it. To obtain the number of lines in a single page (which is modeled by a text container), you would use the NSLayoutManager method glyphRangeForTextContainer: and restrict the line-counting for loop to that range, rather than the {0, numberOfGlyphs} range, which includes all of the text.";
    if ([text length]>0) {
        NSLog(@"Text supplied:\n%@", text);
        [self showWindowWithText:text];
    }
    else {
        NSLog(@"No text supplied.");
        [self quit];
    }
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    [self.window fadeOut];
    [self quit];
}

- (void)showWindowWithText:(NSString *)text
{
    NSLog(@"Showing large text window.");
    
    LargeTextWindow *const window=[[LargeTextWindow alloc] init];
    [window setDelegate:self];
    [window showWithText:text];
    self.window=window;
}

@end
