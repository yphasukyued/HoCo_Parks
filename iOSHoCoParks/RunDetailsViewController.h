//
//  RunDetailsViewController.h
//  MyRunner
//
//  Created by Yongyuth Phasukyued on 7/8/15.
//  Copyright (c) 2015 Yongyuth Phasukyued. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class Run;

@interface RunDetailsViewController : UIViewController
<CLLocationManagerDelegate,
UITextFieldDelegate,
MKMapViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) Run *run;

@end
