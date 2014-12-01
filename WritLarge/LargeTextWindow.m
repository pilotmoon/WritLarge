//
//  LargeTextWindow.m
//  WritLarge
//
//  Created by Nicholas Moore on 28/11/2014.
//  Copyright (c) 2014 Pilotmoon Software. All rights reserved.
//

#import "LargeTextWindow.h"
#import "LargeTextView.h"
#import <Carbon/Carbon.h>


/* Return inner rect centered in outer rect */
NSRect _rectForCenteredBoxInFrame(NSSize box, NSRect container)
{
    return NSMakeRect((container.size.width-box.width)*0.5+container.origin.x, (container.size.height-box.height)*0.5+container.origin.y, box.width, box.height);
}

/* Return inner rect centered in outer rect */
NSRect _rectForCenteredBoxInBox(NSSize box, NSSize container)
{
    return _rectForCenteredBoxInFrame(box, NSMakeRect(0, 0, container.width, container.height));
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
        [self orderOut:self];
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self orderOut:self];
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

    const CGFloat padding=0;
    const CGFloat border=50;

    const CGFloat maxBoxHeight=bounds.size.height-border*2;
    const CGFloat maxBoxWidth=bounds.size.width-border*2;
    
    // the font
  const CGFloat referenceFontSize=100;
    const CGFloat minBoxHeight=50;
  NSFont *const referenceFont=[NSFont systemFontOfSize:referenceFontSize];
    
    // calculate font size
    const NSSize referenceSize=[text sizeWithAttributes:@{NSFontAttributeName: referenceFont}];
    CGFloat ratio=maxBoxWidth/referenceSize.width;
    const CGFloat scaledHeight=referenceSize.height*ratio;
    if (scaledHeight<minBoxHeight) {
        ratio*=minBoxHeight/scaledHeight;
    }
    else if (scaledHeight>maxBoxHeight) {
        ratio*=maxBoxHeight/scaledHeight;
    }
    const CGFloat fontSize=floor(referenceFontSize*ratio);
//    
//    CGFloat fontSize;
//    for (fontSize=24; fontSize<500; fontSize++) {
//        NSSize textSize=[text sizeWithAttributes:@{NSFontAttributeName: [NSFont systemFontOfSize:fontSize+1]}];
//        if (textSize.width>maxBoxWidth||textSize.height>maxBoxHeight) {
//            break;
//        }
//    }
    
    
    NSFont *const font=[NSFont systemFontOfSize:fontSize];
    
    // calculate display width
    const CGFloat displayWidth=[text sizeWithAttributes:@{NSFontAttributeName: font}].width*1.0;
    NSLog(@"Calculated font size: %@, display width: %@", @(fontSize), @(displayWidth));
    
    // create attributed string for display
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    NSAttributedString *as=[[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font,
                                                                                        NSForegroundColorAttributeName: [NSColor whiteColor],
                                                                                        NSParagraphStyleAttributeName: style}];
    
    // create a text view for layout calculations
    NSTextView *textView=[[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, displayWidth, 0)];
    [textView setEditable:NO];
    [textView setSelectable:NO];
    [textView setDrawsBackground:NO];
    [[textView textStorage] setAttributedString:as];
    [textView sizeToFit];
    
    // get number of lines in text (see https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TextLayout/Tasks/CountLines.html)
    NSLayoutManager *const layoutManager=[textView layoutManager];
    const NSUInteger numberOfGlyphs=[layoutManager numberOfGlyphs];
    NSUInteger numberOfLines=0;
    CGFloat heightNeeded=0;
    for (NSUInteger index=0; index<numberOfGlyphs; numberOfLines++) {
        NSRange lineRange;
        const NSRect rect=[layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
        heightNeeded+=NSHeight(rect);
        index=NSMaxRange(lineRange);
    }
    
    NSLog(@"number of lines %@", @(numberOfLines));
    
    // calculate text frame
    NSRect textFrame=[textView frame];
    textFrame.size.height=MIN(maxBoxHeight, heightNeeded);
    textFrame.size.width+=2;
    [textView setFrame:textFrame];
    
    // size the window
    NSRect windowRect=_rectForCenteredBoxInFrame(textFrame.size, bounds);
    windowRect=NSInsetRect(windowRect, -padding, -padding);
    [self setFrame:windowRect display:NO];
    NSLog(@"window frame %@", NSStringFromRect([self frame]));
    
    // place the text view in the window
    NSLog(@"textframe %@", NSStringFromRect(textFrame));
    
    [textView setFrame:_rectForCenteredBoxInBox(textFrame.size, windowRect.size)];
    [[self contentView] addSubview:textView];
    NSLog(@"textview frame %@", NSStringFromRect([textView frame]));
    
    [self setAlphaValue:0];
    [self makeKeyAndOrderFront:self];
    [[self animator] setAlphaValue:1.0];
}


@end
