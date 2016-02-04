//
//  GetJSON.h
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 7/19/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface GetJSON : NSObject

+ (NSMutableArray *)getNearest:(NSString *)type searchItem:(NSString *)item mv:(MKMapView *)mapView;
+ (NSMutableArray *)getFeatureByParkID:(NSString *)parkID searchItem:(NSString *)item mv:(MKMapView *)mapView;
+ (NSMutableArray *)getAllFeature:(MKMapView *)mapView;
+ (NSString *)getNearestTrail:(CGFloat)latItem lng:(CGFloat)lngItem;
+ (NSMutableArray *)getTrail:(NSString *)trailID searchItem:(NSString *)trailName;
+ (NSMutableArray *)getProfile:(NSMutableArray *)trails;
+ (NSMutableArray *)countFeatureByParkID:(NSString *)parkID;
+ (NSMutableArray *)getDistanceProfile:(NSMutableArray *)trails;
@end
