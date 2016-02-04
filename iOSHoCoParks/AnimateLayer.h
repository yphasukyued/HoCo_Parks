//
//  AnimateLayer.h
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 7/19/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AnimateLayer : NSObject

+ (void)animateLayerHorizontal:(CGFloat)x layer:(UIView *)layerName;
+ (void)animateLayerVertical:(CGFloat)y layer:(UIView *)layerName;

@end
