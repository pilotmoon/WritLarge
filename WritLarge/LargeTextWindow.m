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

@end
