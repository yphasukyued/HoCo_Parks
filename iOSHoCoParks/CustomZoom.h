//
//  CustomZoom.h
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 7/19/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomZoom : NSObject

+ (void)zoomToFitMapAnnotations:(MKMapView *)mapView;
+ (void)zoomToFitPoly:(MKMapView *)mapView poly:(NSString *)boundary;
+ (void)setMapCenter:(MKMapView *)mapView item:(NSString *)title subItem:(NSString *)subTitle lat:(CGFloat)latItem lng:(CGFloat)lngItem;
+ (void)zoomToFitTrail:(NSString *)trailID mv:(MKMapView *)mapView poly:(NSString *)boundary;

@end
