//
//  CustomZoom.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 7/19/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "CustomZoom.h"
#import "EmptyAnnotation.h"
#import "BlankAnnotation.h"
#import "ProfileAnnotation.h"

@implementation CustomZoom

+ (void)zoomToFitMapAnnotations:(MKMapView *)mapView {
    if([mapView.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(MKPointAnnotation *annotation in mapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

+ (void)zoomToFitPoly:(MKMapView *)mapView poly:(NSString *)boundary {
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:[boundary stringByReplacingOccurrencesOfString:@" / " withString:@" "] ofType:@"plist"];
    NSArray *regionArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    for (NSDictionary * c in regionArray) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, [[c valueForKey:@"longitude"] doubleValue]);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, [[c valueForKey:@"latitude"] doubleValue]);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, [[c valueForKey:@"longitude"] doubleValue]);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, [[c valueForKey:@"latitude"] doubleValue]);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];

}
+ (void)zoomToFitTrail:(NSString *)trailID mv:(MKMapView *)mapView poly:(NSString *)boundary {
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    NSString *str;
    str = @"https://gis.howardcountymd.gov/iOS/HoCoParks/GetTrail.aspx?searchItem=";
    NSString *stringURL = [NSString stringWithFormat:@"%@%@", str,trailID];
    NSURL *url = [NSURL URLWithString:stringURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error;
    NSMutableArray *json;
    json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSArray *latlngArray;
    NSArray *latitudelngitude;
    
    NSArray * coord0;
    NSMutableArray *coords0 = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [json count]; i++) {
        NSDictionary *info = [json objectAtIndex:i];
        latlngArray = [[info objectForKey:@"WKT"] componentsSeparatedByString:@"|"];
    }
    
    for (int j = 0; j < [latlngArray count]; j++) {
        NSDictionary * dict =[NSMutableDictionary new];
        [dict setValue:[NSString stringWithFormat:@"%@",latlngArray[j]] forKey:@"latlng"];
        coord0 =[[NSArray alloc]initWithObjects:dict, nil];
        [coords0 addObjectsFromArray:coord0];
    }
    
    NSArray * coord;
    NSMutableArray *coords = [[NSMutableArray alloc] init];
    
    for (int k = 0; k < [coords0 count]; k++) {
        NSDictionary *info = [coords0 objectAtIndex:k];
        latitudelngitude = [[info objectForKey:@"latlng"] componentsSeparatedByString:@" "];
        NSDictionary * dict =[NSMutableDictionary new];
        [dict setValue:[NSString stringWithFormat:@"%@",latitudelngitude[1]] forKey:@"latitude"];
        [dict setValue:[NSString stringWithFormat:@"%@",latitudelngitude[0]] forKey:@"longitude"];
        coord =[[NSArray alloc]initWithObjects:dict, nil];
        [coords addObjectsFromArray:coord];
    }
    
    for (int l = 0; l < [coords count]; l++)  {
        NSDictionary *info = [coords objectAtIndex:l];
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, [[info objectForKey:@"longitude"] doubleValue]);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, [[info objectForKey:@"latitude"] doubleValue]);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, [[info objectForKey:@"longitude"] doubleValue]);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, [[info objectForKey:@"latitude"] doubleValue]);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.5; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.5; // Add a little extra space on the sides
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:NO];
}
+ (void)setMapCenter:(MKMapView *)mapView item:(NSString *)title subItem:(NSString *)subTitle lat:(CGFloat)latItem lng:(CGFloat)lngItem {
    
    CLLocationCoordinate2D location;
    location.latitude = latItem;
    location.longitude = lngItem;
    
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance (location, 500, 500);
    
    NSArray *myArray = [title componentsSeparatedByString:@"-"];
    NSString *myType = myArray[0];
    NSString *myTitle = myArray[1];
    
    if ([myType isEqualToString:@"PROFILE"]) {
        ProfileAnnotation *point = [[ProfileAnnotation alloc] init];
        point.coordinate = region.center;
        point.title = myTitle;
        point.subtitle = [NSString stringWithFormat:@"%@", subTitle];
        [mapView addAnnotation:point];
        [mapView setSelectedAnnotations:[[NSArray alloc] initWithObjects:point,nil]];
    } else if ([myType isEqualToString:@"PARK"]
               || [myType isEqualToString:@"HISTORIC"]
               || [myType isEqualToString:@"PAVILION"]
               || [myType isEqualToString:@"PLAYGROUND"]) {
        EmptyAnnotation *point = [[EmptyAnnotation alloc] init];
        point.coordinate = region.center;
        point.title = myTitle;
        point.subtitle = subTitle;
        [mapView addAnnotation:point];
        [mapView setSelectedAnnotations:[[NSArray alloc] initWithObjects:point,nil]];
    } else {
        BlankAnnotation *point = [[BlankAnnotation alloc] init];
        point.coordinate = region.center;
        point.title = myTitle;
        point.subtitle = subTitle;
        [mapView addAnnotation:point];
        [mapView setCenterCoordinate:point.coordinate animated:YES];
        [mapView setSelectedAnnotations:[[NSArray alloc] initWithObjects:point,nil]];
        [mapView setRegion:region animated:NO];
    }

}

@end
