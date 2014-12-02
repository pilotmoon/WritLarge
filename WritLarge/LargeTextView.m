//
//  LargeTextView.m
//  WritLarge
//
//  Created by Nicholas Moore on 28/11/2014.
//  Copyright (c) 2014 Pilotmoon Software. All rights reserved.
//

#import "LargeTextView.h"

@implementation LargeTextView

- (void)drawRect:(NSRect)dirtyRect
{
    // draw background
    [[NSColor colorWithCalibratedWhite:0 alpha:0.85] set];
    NSRectFill([self bounds]);
    
    // render text
    [self.text drawWithRect:self.textFrame
                    options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

@end
