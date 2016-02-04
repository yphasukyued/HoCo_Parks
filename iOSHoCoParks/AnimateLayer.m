//
//  AnimateLayer.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 7/19/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "AnimateLayer.h"

@implementation AnimateLayer

+ (void)animateLayerHorizontal:(CGFloat)x layer:(UIView *)layerName {
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = layerName.frame;
                         frame.origin.x = x;
                         layerName.frame = frame;
                     }
                     completion:^(BOOL finished) {
                     }];
}
+ (void)animateLayerVertical:(CGFloat)y layer:(UIView *)layerName {
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = layerName.frame;
                         frame.origin.y = y;
                         layerName.frame = frame;
                     }
                     completion:^(BOOL finished) {
                     }];
}

@end
