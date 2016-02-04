//
//  DrawBoundary.h
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 7/20/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DrawBoundary : NSObject

+ (MKPolygon *)buildBoundary: (NSString *)title;
+ (MKPolyline *)buildLine: (NSString *)title;
+ (MKPolyline *)buildProfile:(MKMapView *)mapView myTrails:(NSMutableArray *)trails searchItem:(NSString *)trailName;
+ (void)drawPin:(MKMapView *)mapView myTitle:(NSString *)title lat:(CGFloat)latItem lng:(CGFloat)lngItem;
@end
