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

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor colorWithCalibratedWhite:0 alpha:0.8] set];
    NSFont *font=[self.text attributesAtIndex:0 effectiveRange:nil][NSFontAttributeName];
    const CGFloat radius=MAX([font capHeight]/5, 10);
    NSBezierPath *path=[NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:radius yRadius:radius];
    [path fill];
    
    [self.text drawWithRect:NSInsetRect([self bounds], self.padding, self.padding) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine];
}

- (NSView *)hitTest:(NSPoint)aPoint
{
    return NSPointInRect(aPoint, [self frame]) ? self : nil;
}

@end
