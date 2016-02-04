//
//  TapAnnotation.h
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 8/1/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface TapAnnotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
