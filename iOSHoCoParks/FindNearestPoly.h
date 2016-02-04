//
//  FindNearestPoly.h
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 8/5/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FindNearestPoly : NSObject

+ (double)distanceOfPointOnPolygon:(MKMapPoint)pt toPoly:(MKPolygon *)poly;
+ (double)distanceOfPointOnPolyline:(MKMapPoint)pt toPoly:(MKPolyline *)poly;
+ (double)metersFromPixel:(NSUInteger)px atPoint:(CGPoint)pt mv:(MKMapView *)mapView;

@end
