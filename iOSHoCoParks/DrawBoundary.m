//
//  DrawBoundary.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 7/20/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "DrawBoundary.h"
#import "StartAnnotation.h"
#import "EndAnnotation.h"

@implementation DrawBoundary

+ (MKPolygon *)buildBoundary: (NSString *)title {
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:[title stringByReplacingOccurrencesOfString:@" / " withString:@" "] ofType:@"plist"];
    
    NSArray *regionArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    CLLocationCoordinate2D coordinates[regionArray.count];
    
    int coordinatesIndex = 0;
    
    for (NSDictionary * c in regionArray) {
        double y = [[c valueForKey:@"latitude"] doubleValue];
        double x = [[c valueForKey:@"longitude"] doubleValue];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = y;
        coordinate.longitude = x;
        
        //Put this coordinate in the C array...
        coordinates[coordinatesIndex] = coordinate;
        coordinatesIndex++;
    }
    
    MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coordinates count:regionArray.count];
    polygon.title = title;
    return polygon;
}

+ (MKPolyline *)buildLine: (NSString *)title {
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:[title stringByReplacingOccurrencesOfString:@" / " withString:@" "] ofType:@"plist"];
    
    NSArray *regionArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    CLLocationCoordinate2D coordinates[regionArray.count];
    
    int coordinatesIndex = 0;
    
    for (NSDictionary * c in regionArray) {
        double y = [[c valueForKey:@"latitude"] doubleValue];
        double x = [[c valueForKey:@"longitude"] doubleValue];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = y;
        coordinate.longitude = x;
        
        //Put this coordinate in the C array...
        coordinates[coordinatesIndex] = coordinate;
        coordinatesIndex++;
    }
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:regionArray.count];
    polyline.title = title;
    return polyline;
}

+ (MKPolyline *)buildProfile:(MKMapView *)mapView myTrails:(NSMutableArray *)trails searchItem:(NSString *)trailName {
    
    CLLocationCoordinate2D coordinates[trails.count];
    
    int coordinatesIndex = 0;
    
    for (int l = 0; l < [trails count]; l++)  {
        NSDictionary *info = [trails objectAtIndex:l];
        double y = [[info objectForKey:@"latitude"] doubleValue];
        double x = [[info objectForKey:@"longitude"] doubleValue];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = y;
        coordinate.longitude = x;
        
        //Put this coordinate in the C array...
        coordinates[coordinatesIndex] = coordinate;
        coordinatesIndex++;

         if (l==0) {
         [DrawBoundary drawPin:(MKMapView *)mapView myTitle:(NSString *)@"Start"
         lat:(CGFloat)y
         lng:(CGFloat)x];
         } else if (l+1==[trails count]) {
         [DrawBoundary drawPin:(MKMapView *)mapView myTitle:(NSString *)@"End"
         lat:(CGFloat)y
         lng:(CGFloat)x];
         }
    }
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:trails.count];
    polyline.title = trailName;
    return polyline;
}

+ (void)drawPin:(MKMapView *)mapView myTitle:(NSString *)title lat:(CGFloat)latItem lng:(CGFloat)lngItem {
    
    CLLocationCoordinate2D location;
    location.latitude = latItem;
    location.longitude = lngItem;
    
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance (location, 100, 100);
    
    if ([title isEqualToString:@"Start"]) {
        StartAnnotation *point = [[StartAnnotation alloc] init];
        point.coordinate = region.center;
        point.title = title;
        point.subtitle = @"";
        [mapView addAnnotation:point];
    } else if ([title isEqualToString:@"End"]) {
        EndAnnotation *point = [[EndAnnotation alloc] init];
        point.coordinate = region.center;
        point.title = title;
        point.subtitle = @"";
        [mapView addAnnotation:point];
    }

}
@end
