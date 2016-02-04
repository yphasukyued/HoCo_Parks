//
//  RunDetailsViewController.m
//  MyRunner
//
//  Created by Yongyuth Phasukyued on 7/8/15.
//  Copyright (c) 2015 Yongyuth Phasukyued. All rights reserved.
//

#import "RunDetailsViewController.h"
#import "MainViewController.h"
#import "NewRunViewController.h"
#import "MathController.h"
#import "Run.h"
#import "Location.h"
#import "MulticolorPolylineSegment.h"

@interface RunDetailsViewController () {
    UIView *mainView;
    UIView *mainMapView;
    UIView *navMenuView;
    CLLocationManager *locationManager;
    MKMapView *mapView;
    UILabel *distanceLabel;
    UILabel *dateLabel;
    UILabel *timeLabel;
    UILabel *paceLabel;
    UILabel *caloriesLabel;
    NSInteger pace;
    NSInteger minute;
    UIButton *toggleBTN;
    NSString *toggleValue;
    UITextField *weightField;
    CGImageRef cgimg;
    UIButton *backBTN;
    UIImageView *postImage;
    UIButton *shareBTN;
}

@end

@implementation RunDetailsViewController

- (void)setRun:(Run *)run {
    if (_run != run) {
        _run = run;
        [self configureView];
    }
}
- (void)configureView {
    distanceLabel.text = [NSString stringWithFormat:@"Distance: %@", [MathController stringifyDistance:self.run.distance.floatValue]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    dateLabel.text = [formatter stringFromDate:self.run.timestamp];
    
    timeLabel.text = [NSString stringWithFormat:@"Time: %@",  [MathController stringifySecondCount:self.run.duration.intValue usingLongFormat:YES]];
    
    minute = [[MathController stringifySecondCount_Only:self.run.duration.intValue]integerValue];
    
    paceLabel.text = [NSString stringWithFormat:@"Pace: %@",  [MathController stringifyAvgPaceFromDist:self.run.distance.floatValue overTime:self.run.duration.intValue]];
    
    pace = [[MathController stringifyAvgPaceFromDist_Only:self.run.distance.floatValue overTime:self.run.duration.intValue] integerValue];
    
    [self loadMap];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    toggleValue = @"calories";
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.headingFilter = 1;
    locationManager.delegate = self;
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];

    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    mainView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mainView];
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    
    CIImage *inputImage = [CIImage imageWithCGImage:[[UIImage imageNamed:@"Finish.jpeg"] CGImage]];
    [gaussianBlurFilter setValue:inputImage forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@0 forKey:kCIInputRadiusKey];
    
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    cgimg = [context createCGImage:outputImage fromRect:[inputImage extent]];
    
    UIImageView *titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    titleImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    titleImage.image = [UIImage imageWithCGImage:cgimg];
    titleImage.alpha = 1;
    titleImage.hidden = NO;
    [mainView addSubview:titleImage];
    
    //y=180  height=260
    mainMapView = [[UIView alloc] initWithFrame:CGRectMake(0, 150, mainView.frame.size.width, mainView.frame.size.height-150)];
    mainMapView.backgroundColor = [UIColor clearColor];
    [mainView addSubview:mainMapView];
    
    mapView= [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, mainMapView.frame.size.width, mainMapView.frame.size.height)];
    [mainMapView addSubview:mapView];
    
    [mapView setMapType:MKMapTypeStandard];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    
    MKCoordinateRegion region = {{0.0, 0.0},{0.0, 0.0}};
    region.center.latitude = locationManager.location.coordinate.latitude;
    region.center.longitude = locationManager.location.coordinate.longitude;
    region.span.latitudeDelta = 0.0003f;
    region.span.longitudeDelta = 0.0003f;
    [mapView setRegion:region animated:YES];
    
    NSString *tileDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Tiles"];
    NSURL *tileDirectoryURL = [NSURL fileURLWithPath:tileDirectory isDirectory:YES];
    NSString *tileTemplate = [NSString stringWithFormat:@"%@{z}/{x}/{y}.png", tileDirectoryURL];
    MKTileOverlay *overlay = [[MKTileOverlay alloc] initWithURLTemplate:tileTemplate];
    overlay.geometryFlipped = YES;
    [mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];
    
    toggleBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    toggleBTN.frame = CGRectMake(20, mainView.frame.size.height-80, mainView.frame.size.width-40, 60);
    [toggleBTN setTitle:@"Calories Count" forState:UIControlStateNormal];
    [toggleBTN.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:30]];
    toggleBTN.backgroundColor = [UIColor colorWithRed:4.0/255.0 green:127.0/255.0 blue:64.0/255.0 alpha:1];
    [toggleBTN addTarget:self action:@selector(toggle_Click) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:toggleBTN];
    
    weightField = [[UITextField alloc] initWithFrame:CGRectMake(20, mainView.frame.size.height-80, 0, 60)];
    weightField.borderStyle = UITextBorderStyleRoundedRect;
    weightField.backgroundColor = [UIColor whiteColor];
    weightField.font = [UIFont systemFontOfSize:24];
    weightField.placeholder = @"Your Weight(lbs)";
    weightField.autocorrectionType = UITextAutocorrectionTypeNo;
    weightField.keyboardType = UIKeyboardTypeNumberPad;
    weightField.returnKeyType = UIReturnKeyDone;
    weightField.clearButtonMode = UITextFieldViewModeWhileEditing;
    weightField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    weightField.hidden = YES;
    weightField.delegate = self;
    [mainView addSubview:weightField];
    
    distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, mainView.frame.size.width-20, 30)];
    distanceLabel.text = @"";
    distanceLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:20];
    distanceLabel.backgroundColor = [UIColor clearColor];
    distanceLabel.textColor = [UIColor blackColor];
    distanceLabel.textAlignment = NSTextAlignmentLeft;
    distanceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainView addSubview:distanceLabel];
    
    paceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 90, mainView.frame.size.width-20, 30)];
    paceLabel.text = @"";
    paceLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:20];
    paceLabel.backgroundColor = [UIColor clearColor];
    paceLabel.textColor = [UIColor blackColor];
    paceLabel.textAlignment = NSTextAlignmentLeft;
    paceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainView addSubview:paceLabel];
    
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, (mainView.frame.size.width/2)-10, 30)];
    timeLabel.text = @"";
    timeLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:20];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textColor = [UIColor blackColor];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainView addSubview:timeLabel];
    
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake((mainView.frame.size.width/2), 120, (mainView.frame.size.width/2)-10, 30)];
    dateLabel.text = @"";
    dateLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:20];
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.textColor = [UIColor blackColor];
    dateLabel.textAlignment = NSTextAlignmentRight;
    dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainView addSubview:dateLabel];
    
    caloriesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 170, mainView.frame.size.width-20, 30)];
    caloriesLabel.text = @"";
    caloriesLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:20];
    caloriesLabel.backgroundColor = [UIColor redColor];
    caloriesLabel.textColor = [UIColor whiteColor];
    caloriesLabel.textAlignment = NSTextAlignmentCenter;
    caloriesLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    caloriesLabel.hidden = YES;
    [mainView addSubview:caloriesLabel];
    
    navMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, 64)];
    navMenuView.backgroundColor = [UIColor blackColor];
    navMenuView.alpha = 0.5;
    navMenuView.tag = 1;
    [mainView addSubview:navMenuView];
    
    backBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    backBTN.frame = CGRectMake(8, 24, 48, 48);
    [backBTN setBackgroundImage:[UIImage imageNamed:@"Arrow_Left.png"] forState:UIControlStateNormal];
    [backBTN addTarget:self action:@selector(back_Click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBTN];
    
    shareBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBTN.frame = CGRectMake(self.view.frame.size.width-38, 28, 21, 28);
    [shareBTN setBackgroundImage:[UIImage imageNamed:@"702-share.png"] forState:UIControlStateNormal];
    [shareBTN addTarget:self action:@selector(shareThis) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBTN];
    
    [self configureView];
}
- (MKCoordinateRegion)mapRegion {
    MKCoordinateRegion region;
    Location *initialLoc = self.run.locations.firstObject;
    
    float minLat = initialLoc.latitude.floatValue;
    float minLng = initialLoc.longitude.floatValue;
    float maxLat = initialLoc.latitude.floatValue;
    float maxLng = initialLoc.longitude.floatValue;
    
    for (Location *location in self.run.locations) {
        if (location.latitude.floatValue < minLat) {
            minLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue < minLng) {
            minLng = location.longitude.floatValue;
        }
        if (location.latitude.floatValue > maxLat) {
            maxLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue > maxLng) {
            maxLng = location.longitude.floatValue;
        }
    }
    
    region.center.latitude = (minLat + maxLat) / 2.0f;
    region.center.longitude = (minLng + maxLng) / 2.0f;
    
    region.span.latitudeDelta = (maxLat - minLat) * 1.1f; // 10% padding
    region.span.longitudeDelta = (maxLng - minLng) * 1.1f; // 10% padding
    
    return region;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircle *circle = (MKCircle *)overlay;
        MKCircleRenderer *cRenderer = [[MKCircleRenderer alloc] initWithCircle:circle];
        cRenderer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        cRenderer.lineWidth = 1;
        cRenderer.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
        return cRenderer;
    } else if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        MKTileOverlayRenderer *tRenderer = [[MKTileOverlayRenderer alloc] initWithOverlay:overlay];
        tRenderer.alpha = 1;
        return tRenderer;
    } else if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *pRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        pRenderer.strokeColor = [UIColor colorWithRed:0/255 green:0/255 blue:255/255 alpha:1];
        pRenderer.lineWidth = 6;
        return pRenderer;
    } else if ([overlay isKindOfClass:[MulticolorPolylineSegment class]]) {
        MulticolorPolylineSegment *polyLine = (MulticolorPolylineSegment *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = polyLine.color;
        aRenderer.lineWidth = 6;
        return aRenderer;
    }
    return nil;
}
- (MKPolyline *)polyLine {
    
    CLLocationCoordinate2D coords[self.run.locations.count];
    
    for (int i = 0; i < self.run.locations.count; i++) {
        Location *location = [self.run.locations objectAtIndex:i];
        coords[i] = CLLocationCoordinate2DMake(location.latitude.doubleValue, location.longitude.doubleValue);
    }
    
    return [MKPolyline polylineWithCoordinates:coords count:self.run.locations.count];
}
- (void)caloriesCalculation {
    NSLog(@"%ld", (long)pace);
    float met;
    float calories;
    int caloriesCount;
    NSString *str = weightField.text;
    float weightNumber = [str floatValue]*0.453592;
    
    if (pace <= 4) {
        met = 23.0;
    } else if (pace == 5) {
        met = 19.0;
    } else if (pace == 6) {
        met = 14.5;
    } else if (pace == 7) {
        met = 12.3;
    } else if (pace == 8) {
        met = 11.8;
    } else if (pace == 9) {
        met = 10.5;
    } else if (pace == 10) {
        met = 9.8;
    } else if (pace == 11) {
        met = 9.0;
    } else if (pace == 12) {
        met = 8.3;
    } else if (pace == 13) {
        met = 6.0;
    } else if (pace > 13) {
        met = 4.5;
    }
    calories = met * 3.5 * weightNumber / 200;
    caloriesCount = calories * minute;
    caloriesLabel.text = [NSString stringWithFormat:@"Calories Burn: %d", caloriesCount];
    caloriesLabel.hidden = NO;
}
- (void)toggle_Click {
    [[self view] endEditing:YES];
    if ([toggleValue isEqualToString:@"calories"]) {
        [toggleBTN setTitle:@"OK" forState:UIControlStateNormal];
        toggleValue = @"ok";
        weightField.hidden = NO;
        [UIView animateWithDuration:1.0
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             toggleBTN.frame = CGRectMake(mainView.frame.size.width-80, mainView.frame.size.height-80, 60, 60);
                             weightField.frame = CGRectMake(20, mainView.frame.size.height-80, mainView.frame.size.width-100, 60);
                         }
                         completion:^(BOOL finished) {
                         }];
    } else if ([toggleValue isEqualToString:@"new run"]) {
        [self openNewRun];
    } else if ([toggleValue isEqualToString:@"ok"]) {
        [self caloriesCalculation];
        [UIView animateWithDuration:1.0
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             weightField.frame = CGRectMake(20, mainView.frame.size.height-80, 0, 60);
                             toggleBTN.frame = CGRectMake(20, mainView.frame.size.height-80, mainView.frame.size.width-40, 60);
                             CGRect frame = mainView.frame;
                             frame.origin.y = 0;
                             mainView.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             [toggleBTN setTitle:@"New Run" forState:UIControlStateNormal];
                             toggleValue = @"new run";
                             
                         }];
    }

}
- (void)loadMap {
    if (self.run.locations.count > 0) {
        [toggleBTN setTitle:@"Calories Count" forState:UIControlStateNormal];
        toggleValue = @"calories";
        
        // set the map bounds
        [mapView setRegion:[self mapRegion]];
        
        // make the line(s!) on the map
        NSArray *colorSegmentArray = [MathController colorSegmentsForLocations:self.run.locations.array];
        [mapView addOverlays:colorSegmentArray];

        
    } else {
        
        [toggleBTN setTitle:@"New Run" forState:UIControlStateNormal];
        toggleValue = @"new run";
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Sorry, this run has no locations saved."
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}
-(void)openNewRun {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewRunViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NewRun"];
    vc.managedObjectContext = self.managedObjectContext;
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)back_Click {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainView"];
    vc.managedObjectContext = self.managedObjectContext;
    [self presentViewController:vc animated:YES completion:nil];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         weightField.frame = CGRectMake(20, mainView.frame.size.height-80, 60, 60);
                         toggleBTN.frame = CGRectMake(80, mainView.frame.size.height-80, mainView.frame.size.width-100, 60);
                         CGRect frame = mainView.frame;
                         frame.origin.y = 0;
                         mainView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                     }];
    return NO;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = mainView.frame;
                         frame.origin.y = -200;
                         mainView.frame = frame;
                     }
                     completion:^(BOOL finished) {
                     }];
    return YES;
}
- (void)shareThis {
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData*theImageData = UIImageJPEGRepresentation(theImage, 1.0 );
    
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         navMenuView.frame = CGRectMake(0, 0, mainView.frame.size.width, mainView.frame.size.height);
                         navMenuView.alpha = 1.0;
                         backBTN.hidden = YES;
                         shareBTN.hidden = YES;
                         for(UIView *subview in [navMenuView subviews]) {
                             [subview removeFromSuperview];
                         }
                     }
                     completion:^(BOOL finished) {
                         
                         UILabel *shareTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 30, navMenuView.frame.size.width-100, 24)];
                         shareTitle.text = @"Share";
                         shareTitle.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
                         shareTitle.backgroundColor = [UIColor clearColor];
                         shareTitle.textColor = [UIColor whiteColor];
                         shareTitle.alpha = 1.0;
                         shareTitle.textAlignment = NSTextAlignmentCenter;
                         shareTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                         [navMenuView addSubview:shareTitle];
                         
                         UIButton *exitShareBTN = [UIButton buttonWithType:UIButtonTypeCustom];
                         exitShareBTN.frame = CGRectMake(navMenuView.frame.size.width-45, 20, 40, 40);
                         [exitShareBTN setBackgroundImage:[UIImage imageNamed:@"Exit.png"] forState:UIControlStateNormal];
                         [exitShareBTN addTarget:self action:@selector(closeShare) forControlEvents:UIControlEventTouchUpInside];
                         [navMenuView addSubview:exitShareBTN];
                         
                         postImage = [[UIImageView alloc] initWithFrame:CGRectMake((navMenuView.frame.size.width/2)-(navMenuView.frame.size.width/4), 120, (navMenuView.frame.size.width/2), (navMenuView.frame.size.height/2))];
                         postImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                         postImage.image = [UIImage imageWithData:theImageData];
                         [navMenuView addSubview:postImage];
                         
                         UIButton *postBTN = [[UIButton alloc] initWithFrame:CGRectMake(10, navMenuView.frame.size.height-50, navMenuView.frame.size.width-20, 40)];
                         postBTN.backgroundColor = [UIColor darkGrayColor];
                         postBTN.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
                         [postBTN setTitle:@"Post" forState:UIControlStateNormal];
                         [postBTN addTarget:self action:@selector(sendPost) forControlEvents:UIControlEventTouchUpInside];
                         [navMenuView addSubview:postBTN];
                         
                     }];
    
}
- (void)sendPost {
    NSArray *activityItems;
    activityItems = @[postImage.image];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypeMessage,
                                                 UIActivityTypeAddToReadingList,
                                                 UIActivityTypeAirDrop,
                                                 UIActivityTypeAssignToContact,
                                                 UIActivityTypeCopyToPasteboard,
                                                 UIActivityTypePostToFlickr,
                                                 UIActivityTypePostToTencentWeibo,
                                                 UIActivityTypePostToWeibo,
                                                 UIActivityTypePostToVimeo,
                                                 UIActivityTypePrint,
                                                 UIActivityTypeOpenInIBooks,
                                                 UIActivityTypeMail];
    
    [self presentViewController:activityController animated:NO completion:nil];
}
-(void)closeShare {
    backBTN.hidden = NO;
    shareBTN.hidden = NO;
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         navMenuView.frame = CGRectMake(0, 0, mainView.frame.size.width, 64);
                         navMenuView.alpha = 0.5;
                         for(UIView *subview in [navMenuView subviews]) {
                             [subview removeFromSuperview];
                         }
                     }
                     completion:^(BOOL finished) {
                     }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Low Memory"
                                          message:@"Your device is running low on memory."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action)
                                   {
                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                   }];
    [alertController addAction:actionCancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
