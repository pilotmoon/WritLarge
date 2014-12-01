//
//  LargeTextWindow.m
//  WritLarge
//
//  Created by Nicholas Moore on 28/11/2014.
//  Copyright (c) 2014 Pilotmoon Software. All rights reserved.
//

#import "LargeTextWindow.h"
#import "LargeTextView.h"
#import <Carbon/Carbon.h> // for kVK_Escape

// Calculate inner rect centered in outer rect
static NSRect _rectForCenteredBoxInFrame(NSSize box, NSRect container)
{
    return NSMakeRect((container.size.width-box.width)*0.5+container.origin.x,
                      (container.size.height-box.height)*0.5+container.origin.y, box.width, box.height);
}

@implementation LargeTextWindow

- (id)init
{
    self=[super initWithContentRect:NSZeroRect
                          styleMask:NSBorderlessWindowMask|NSNonactivatingPanelMask
                            backing:NSBackingStoreBuffered
                              defer:NO];
    if (self) {
        [self setOpaque:NO];
        [self setHasShadow:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setLevel:NSModalPanelWindowLevel];
        [self setContentView:[[LargeTextView alloc] initWithFrame:NSZeroRect]];        
        return self;
    }
    return self;
}

#pragma mark NSWindow overrides

- (void)keyDown:(NSEvent *)theEvent
{
    if ([theEvent keyCode]==kVK_Escape) {
        [self fadeOut];
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self fadeOut];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (BOOL)canBecomeMainWindow
{
    return NO;
}

// automatically calculates the bounds
- (void)showWithText:(NSString *)text
{
    const NSPoint mousePoint=[NSEvent mouseLocation];

    const NSRect mouseZone=NSMakeRect(mousePoint.x-0.5, mousePoint.y-0.5, 1, 1);

    NSRect frame=NSZeroRect;
    // reverse order so main screen is last, in case no rect contains the mouse somehow
    for (NSScreen *s in [[NSScreen screens] reverseObjectEnumerator]) {
        frame=[s visibleFrame];
        if (NSIntersectsRect([s frame], mouseZone)) {
            break;
        }
    }
    [self showWithText:text inBounds:frame];
}

// the bounds should be the bounds of the screen you want to show it on
- (void)showWithText:(NSString *)text inBounds:(NSRect)bounds
{
    const CGFloat padding=20, margin=50, minFontSize=40;
    
    // maximum rendered text size, given our bounds
    const NSSize maxDisplaySize=NSMakeSize(bounds.size.width-margin*2-padding*2, bounds.size.height-margin*2-padding*2);
    
    // helper routine to get the full text attributes for a given font size
    NSDictionary *(^attributesForSize)(CGFloat)=^NSDictionary *(CGFloat fontSize) {
        NSMutableParagraphStyle *const style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location==NSNotFound) {
            [style setAlignment:NSCenterTextAlignment];
        }
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        return @{NSFontAttributeName: [NSFont systemFontOfSize:fontSize],
                 NSForegroundColorAttributeName: [NSColor whiteColor],
                 NSParagraphStyleAttributeName: style};
    };
    
    // helper block to calculate the rendered text size for a given font size
    NSSize (^sizeCalc)(CGFloat) = ^NSSize(CGFloat fontSize) {
        NSSize size=[text boundingRectWithSize:maxDisplaySize
                                  options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine
                               attributes:attributesForSize(fontSize)].size;
        size.width+=fontSize*0.3;
        return size;
    };
    
    // calculate font size and display size, scaling up to make best use of the screen
    const NSSize referenceSize=sizeCalc(minFontSize);
    const CGFloat scale=MIN(maxDisplaySize.width/referenceSize.width, maxDisplaySize.height/referenceSize.height);
    const CGFloat fontSize=MIN(floor(minFontSize*scale),400);
    const NSSize displaySize=sizeCalc(fontSize);
    NSLog(@"Calculated font size: %@, display size: %@", @(fontSize), NSStringFromSize(displaySize));
    
    // prepare the window
    const NSRect windowRect=NSInsetRect(_rectForCenteredBoxInFrame(displaySize, bounds), -padding, -padding);
    [self setFrame:windowRect display:NO];
    ((LargeTextView *)[self contentView]).text=[[NSAttributedString alloc] initWithString:text attributes:attributesForSize(fontSize)];
    ((LargeTextView *)[self contentView]).padding=padding;

    // fade in
    [self fadeIn];
}

- (void)fadeIn {
    const NSTimeInterval duration=0.2;
    [self setAlphaValue:0];
    [self makeKeyAndOrderFront:self];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    [[self animator] setAlphaValue:1.0];
    [NSAnimationContext endGrouping];
}

- (void)fadeOut {
    const NSTimeInterval duration=0.1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*duration+0.1), dispatch_get_main_queue(), ^{
        [self orderOut:self];
    });
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    [[self animator] setAlphaValue:0.0];
    [NSAnimationContext endGrouping];
}

@end
