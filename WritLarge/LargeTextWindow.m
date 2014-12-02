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

static NSRect _centerBox(NSSize box, NSSize container)
{
    return NSMakeRect((container.width-box.width)*0.5,
                      (container.height-box.height)*0.5, box.width, box.height);
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
        [self setLevel:NSScreenSaverWindowLevel];
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

#pragma mark Fade in/out

- (void)fadeAlpha:(CGFloat)alpha duration:(NSTimeInterval)duration after:(void (^)(void))after
{
    if (after) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*duration+0.1), dispatch_get_main_queue(), ^{
            after();
        });
    }
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    [[self animator] setAlphaValue:alpha];
    [NSAnimationContext endGrouping];
}

- (void)fadeIn {
    [self setAlphaValue:0];
    [self makeKeyAndOrderFront:self];
    [self fadeAlpha:1 duration:0.2 after:nil];
}

- (void)fadeOut {
    [self fadeAlpha:0 duration:0.1 after:^{
        [self close];
    }];
}

#pragma mark Window drawing

// automatically calculates the bounds based on the screen the mouse is in
- (void)showWithText:(NSString *)text
{
    const NSPoint mousePoint=[NSEvent mouseLocation];
    const NSRect mouseZone=NSMakeRect(mousePoint.x-0.5, mousePoint.y-0.5, 1, 1);

    NSRect frame=NSZeroRect;
    for (NSScreen *s in [[NSScreen screens] reverseObjectEnumerator]) {
        frame=[s frame];
        if (NSIntersectsRect(frame, mouseZone)) {
            break;
        }
    }
    
    [self showWithText:text inFrame:frame];
}

// the bounds should be the bounds of the screen you want to show it on
- (void)showWithText:(NSString *)text inFrame:(NSRect)frame
{
    const CGFloat padding=25, minFontSize=40, maxFontSize=450;
    const NSSize maxDisplaySize=NSMakeSize(frame.size.width-padding*2, frame.size.height-padding*2);
    
    // get the full text attributes for a given font size
    NSDictionary *(^attributesForSize)(CGFloat)=^NSDictionary *(CGFloat fontSize) {
        NSMutableParagraphStyle *const style=[[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location==NSNotFound) {
            [style setAlignment:NSCenterTextAlignment];
        }
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        return @{NSFontAttributeName: [NSFont systemFontOfSize:fontSize],
                 NSForegroundColorAttributeName: [NSColor whiteColor],
                 NSParagraphStyleAttributeName: style};
    };
    
    // calculate the rendered text size for a given font size
    NSSize (^sizeCalc)(CGFloat) = ^NSSize(CGFloat fontSize) {
        NSSize size=[text boundingRectWithSize:maxDisplaySize
                                       options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine
                                    attributes:attributesForSize(fontSize)].size;
        size.width+=fontSize*0.3; // fudge factor
        return size;
    };
    
    // calculate font size
    const NSSize referenceSize=sizeCalc(minFontSize);
    const CGFloat scale=MIN(maxDisplaySize.width/referenceSize.width, maxDisplaySize.height/referenceSize.height);
    const CGFloat fontSize=MIN(floor(minFontSize*scale), maxFontSize);
    
    // prepare the window
    [self setFrame:frame display:NO];
    ((LargeTextView *)[self contentView]).text=[[NSAttributedString alloc] initWithString:text attributes:attributesForSize(fontSize)];
    ((LargeTextView *)[self contentView]).textFrame=_centerBox(sizeCalc(fontSize), frame.size);
    [self fadeIn];
}

@end
