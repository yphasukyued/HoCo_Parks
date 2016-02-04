//
//  MathController.h
//  MyRunner
//
//  Created by Yongyuth Phasukyued on 7/8/15.
//  Copyright (c) 2015 Yongyuth Phasukyued. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MathController : NSObject

+ (NSString *)stringifyDistance:(float)meters;
+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat;
+ (NSString *)stringifySecondCount_Only:(int)seconds;
+ (NSString *)stringifyAvgPaceFromDist:(float)meters overTime:(int)seconds;
+ (NSString *)stringifyAvgPaceFromDist_Only:(float)meters overTime:(int)seconds;

+ (NSArray *)colorSegmentsForLocations:(NSArray *)locations;

@end
