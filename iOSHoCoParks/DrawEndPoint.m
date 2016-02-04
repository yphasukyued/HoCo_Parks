//
//  DrawEndPoint.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 8/18/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "DrawEndPoint.h"

@implementation DrawEndPoint

- (void)drawRect:(CGRect)rect {
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextClearRect(contextRef, rect);
    CGContextSetRGBFillColor(contextRef, 145.0/255, 68.0/255, 34.0/255, 1.0);
    CGContextFillEllipseInRect(contextRef, rect);
}

@end
