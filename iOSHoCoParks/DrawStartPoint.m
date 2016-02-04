//
//  DrawStartPoint.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 8/18/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "DrawStartPoint.h"

@implementation DrawStartPoint

- (void)drawRect:(CGRect)rect {
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextClearRect(contextRef, rect);
    CGContextSetRGBFillColor(contextRef, 0.0, 128.0/255, 0.0, 1.0);
    CGContextFillEllipseInRect(contextRef, rect);
}

@end
