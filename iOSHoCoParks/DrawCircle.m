//
//  DrawCircle.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 8/2/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "DrawCircle.h"

@implementation DrawCircle

- (void)drawRect:(CGRect)rect {
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextClearRect(contextRef, rect);
    CGContextSetRGBFillColor(contextRef, 255.0, 0.0, 0.0, 0.5);
    CGContextFillEllipseInRect(contextRef, rect);
}

-(void)fadeOut{
    
    CABasicAnimation *fadeout = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeout.delegate = self;
    fadeout.fromValue = [NSNumber numberWithInt:1.0];
    fadeout.toValue = [NSNumber numberWithInt:0];
    fadeout.duration = 1;
    fadeout.fillMode = kCAFillModeForwards;
    fadeout.removedOnCompletion = NO;
    
    [self.layer addAnimation:fadeout forKey:@"fade"];
}

-(void)fadeInOut{
    
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CABasicAnimation *fadein = [CABasicAnimation animationWithKeyPath:@"opacity"];
                         fadein.delegate = self;
                         fadein.fromValue = [NSNumber numberWithInt:0];
                         fadein.toValue = [NSNumber numberWithInt:1];
                         fadein.duration = 1;
                         fadein.fillMode = kCAFillModeForwards;
                         fadein.removedOnCompletion = NO;
                         
                         [self.layer addAnimation:fadein forKey:@"fade"];
                     }
                     completion:^(BOOL finished) {
                         CABasicAnimation *fadeout = [CABasicAnimation animationWithKeyPath:@"opacity"];
                         fadeout.delegate = self;
                         fadeout.fromValue = [NSNumber numberWithInt:1];
                         fadeout.toValue = [NSNumber numberWithInt:0];
                         fadeout.duration = 1;
                         fadeout.fillMode = kCAFillModeForwards;
                         fadeout.removedOnCompletion = NO;
                         
                         [self.layer addAnimation:fadeout forKey:@"fade"];
                     }];

}

@end
