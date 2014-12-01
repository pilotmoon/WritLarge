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
    // calculate corner radius based on font size
    NSFont *font=[self.text attributesAtIndex:0 effectiveRange:nil][NSFontAttributeName];
    const CGFloat radius=MAX([font capHeight]/5, 10);
    
    // draw background
    NSBezierPath *path=[NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:radius yRadius:radius];
    [[NSColor colorWithCalibratedWhite:0 alpha:0.8] set];
    [path fill];
    
    // render text
    [self.text drawWithRect:NSInsetRect([self bounds], self.padding, self.padding) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine];
}

@end
