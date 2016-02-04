//
//  DrawProfile.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 8/4/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "DrawProfile.h"

@implementation DrawProfile

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //elevation
    int howMany = (kGraphBottom - kGraphTop - kOffsetY) / kStepY;
    for (int i = 0; i < howMany; i++) {
        CGContextSetTextDrawingMode(context, kCGTextFill); // This is the default
        [[UIColor blackColor] setFill]; // This is the default
        [[NSString stringWithFormat:@"%d",(kGraphHeight-(kStepY*i)-50)] drawAtPoint:CGPointMake(0, (kStepX*i)-20)
           withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica"
                                                                size:14]
                            }];
    }
    
    //length
    int howManyHorizontal = (kDefaultGraphWidth - kOffsetX) / kStepX;
    for (int i = 0; i <= howManyHorizontal; i++) {
        CGContextSetTextDrawingMode(context, kCGTextFill); // This is the default
        [[UIColor blackColor] setFill]; // This is the default
        [[NSString stringWithFormat:@"%d",(kStepX*i)] drawAtPoint:CGPointMake(kStepX*i, (kGraphHeight-kStepX)-20)
             withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica"
                                                                  size:14]
                                                          }];
    }
    
    CGContextSetLineWidth(context, 0.6);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGFloat dash[] = {2.0, 2.0};
    CGContextSetLineDash(context, 0.0, dash, 2);
    
    // How many lines?
    int howManyVert = (kDefaultGraphWidth - kOffsetX) / kStepX;

    // Here the lines go
    for (int i = 0; i < howManyVert; i++)
    {
        CGContextMoveToPoint(context, kOffsetX + i * kStepX, kGraphTop);
        CGContextAddLineToPoint(context, kOffsetX + i * kStepX, kGraphBottom);
    }
    
    int howManyHor = (kGraphBottom - kGraphTop - kOffsetY) / kStepY;
    for (int i = 0; i <= howManyHor; i++)
    {
        CGContextMoveToPoint(context, kOffsetX, kGraphBottom - kOffsetY - i * kStepY);
        CGContextAddLineToPoint(context, kDefaultGraphWidth, kGraphBottom - kOffsetY - i * kStepY);
    }
    
    CGContextStrokePath(context);
}


@end
