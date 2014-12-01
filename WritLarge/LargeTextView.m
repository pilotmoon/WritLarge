//
//  LargeTextView.m
//  WritLarge
//
//  Created by Nicholas Moore on 28/11/2014.
//  Copyright (c) 2014 Pilotmoon Software. All rights reserved.
//

#import "LargeTextView.h"
#import "LargeTextWindow.h"

@implementation LargeTextView

- (void)drawRect:(NSRect)dirtyRect
{
    // draw background
    NSBezierPath *path=[NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:self.radius yRadius:self.radius];
    [[NSColor colorWithCalibratedWhite:0 alpha:0.9] set];
    [path fill];
    
    // render text
    [self.text drawWithRect:self.textFrame options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine];
}

@end
