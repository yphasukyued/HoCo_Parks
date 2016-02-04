//
//  Location.h
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 7/10/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSManagedObject *run;

@end
