//
//  LargeTextView.m
//  WritLarge
//
//  Created by Nicholas Moore on 28/11/2014.
//  Copyright (c) 2014 Pilotmoon Software. All rights reserved.
//

#import "LargeTextView.h"


@implementation LargeTextView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor colorWithCalibratedWhite:0 alpha:0.8] set];
    NSRectFill([self bounds]);
}

- (NSView *)hitTest:(NSPoint)aPoint
{
    return NSPointInRect(aPoint, [self frame]) ? self : nil;
}

@end
