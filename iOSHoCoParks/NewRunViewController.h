//
//  NewRunViewController.h
//  MyRunner
//
//  Created by Yongyuth Phasukyued on 7/8/15.
//  Copyright (c) 2015 Yongyuth Phasukyued. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@interface NewRunViewController : UIViewController
<UIActionSheetDelegate,
CLLocationManagerDelegate,
MKMapViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property int seconds;
@property float distance;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSTimer *timer;

@end
