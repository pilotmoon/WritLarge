//
//  LargeTextWindow.h
//  WritLarge
//
//  Created by Nicholas Moore on 28/11/2014.
//  Copyright (c) 2014 Pilotmoon Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, LargeTextStyle) {
    BarStyle=0,
    FullScreenStyle
};

@interface LargeTextWindow : NSPanel

- (void)showWithText:(NSString *)text inBounds:(NSRect)bounds style:(LargeTextStyle)style;
- (void)showWithText:(NSString *)text style:(LargeTextStyle)style;
- (void)fadeOut;
@end
