//
//  Annotation.h
//  MasterView
//
//  Created by Yongyuth Phasukyued on 11/27/12.
//  Copyright (c) 2012 Yongyuth Phasukyued. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface Annotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
    NSString *status;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *status;
@property (assign) double latItem;
@property (assign) double lngItem;
@property (nonatomic, copy) NSString *idItem;
@end
