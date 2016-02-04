//
//  NewRunViewController.m
//  MyRunner
//
//  Created by Yongyuth Phasukyued on 7/8/15.
//  Copyright (c) 2015 Yongyuth Phasukyued. All rights reserved.
//

#import "NewRunViewController.h"
#import "RunDetailsViewController.h"
#import "MainViewController.h"
#import "MathController.h"
#import "Run.h"
#import "Location.h"
#import "AvailableMemory.h"

//static NSString * const detailSegueName = @"RunDetails";
//static NSString * const homeSegueName = @"Home";

@interface NewRunViewController () {
    UIView *mainView;
    UILabel *promptLabel;
    UILabel *distanceLabel;
    UILabel *timeLabel;
    UILabel *paceLabel;
    UILabel *levelLabel;
    UILabel *memoryLabel;
    UIButton *startBTN;
    UIButton *stopBTN;
    UIView *mainMapView;
    MKMapView *mapView;
    UIImageView *titleImage;
    UIImageView *titleImage1;
    CGImageRef cgimg;
    CGImageRef cgimg1;
    UIButton *gpsBTN;
}

@property (strong, nonatomic) Run *run;

@end

@implementation NewRunViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //startBTN.hidden = NO;
    promptLabel.hidden = NO;
    
    timeLabel.hidden = YES;
    distanceLabel.hidden = YES;
    paceLabel.hidden = YES;
    stopBTN.hidden = YES;
    mapView.hidden = YES;
    levelLabel.hidden = YES;
}
-(void)start_Click {
    titleImage.hidden = YES;
    titleImage1.hidden = NO;
    startBTN.hidden = YES;
    promptLabel.hidden = YES;
    gpsBTN.hidden = YES;
    timeLabel.hidden = NO;
    distanceLabel.hidden = NO;
    paceLabel.hidden = NO;
    stopBTN.hidden = NO;
    mapView.hidden = NO;
    levelLabel.hidden = NO;
    
    self.seconds = 0;
    self.distance = 0;
    self.locations = [NSMutableArray array];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self
                                                selector:@selector(eachSecond) userInfo:nil repeats:YES];
    [self startLocationUpdates];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // save
    if (buttonIndex == 0) {
        [self saveRun];
        [self openRunDetails];
    // discard
    } else if (buttonIndex == 1) {
        titleImage.hidden = NO;
        titleImage1.hidden = YES;
        startBTN.hidden = NO;
        promptLabel.hidden = NO;
        gpsBTN.hidden = NO;
        timeLabel.hidden = YES;
        distanceLabel.hidden = YES;
        paceLabel.hidden = YES;
        stopBTN.hidden = YES;
        mapView.hidden = YES;
        levelLabel.hidden = YES;
        [self.locationManager stopUpdatingLocation];
    }
}

-(void)stop_Click {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self
                                                    cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Save", @"Discard", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryLevelChanged:)
                                                 name:UIDeviceBatteryLevelDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.headingFilter = 1;
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    mainView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:mainView];

    CIImage *inputImage = [CIImage imageWithCGImage:[[UIImage imageNamed:@"Running.jpg"] CGImage]];
    
    CIFilter *gloomFilter = [CIFilter filterWithName:@"CIGloom"];
    [gloomFilter setDefaults];
    [gloomFilter setValue:inputImage forKey:kCIInputImageKey];
    [gloomFilter setValue:@50.0f forKey:kCIInputRadiusKey];
    [gloomFilter setValue:@0.75f forKey:kCIInputIntensityKey];
    
    CIImage *outputImage = [gloomFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    cgimg = [context createCGImage:outputImage fromRect:[inputImage extent]];
    
    titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(-50, -50, mainView.frame.size.width+100, mainView.frame.size.height+100)];
    titleImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    titleImage.image = [UIImage imageWithCGImage:cgimg];
    titleImage.alpha = 1.0;
    [mainView addSubview:titleImage];
    
    CGFloat leftRightMin = -50.0f;
    CGFloat leftRightMax = 50.0f;
    CGFloat upDownMin = -50.0f;
    CGFloat upDownMax = 50.0f;
    
    UIInterpolatingMotionEffect *leftRight = [[UIInterpolatingMotionEffect alloc]
                                              initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    
    UIInterpolatingMotionEffect *upDown = [[UIInterpolatingMotionEffect alloc]
                                           initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    leftRight.minimumRelativeValue = @(leftRightMin);
    leftRight.maximumRelativeValue = @(leftRightMax);
    upDown.minimumRelativeValue = @(upDownMin);
    upDown.maximumRelativeValue = @(upDownMax);
    
    UIMotionEffectGroup *myGroup = [[UIMotionEffectGroup alloc]init];
    myGroup.motionEffects = @[leftRight, upDown];
    
    [titleImage addMotionEffect:myGroup];
    
    CIFilter *gaussianBlurFilter1 = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter1 setDefaults];
    
    CIImage *inputImage1 = [CIImage imageWithCGImage:[[UIImage imageNamed:@"Runner.jpeg"] CGImage]];
    [gaussianBlurFilter1 setValue:inputImage1 forKey:kCIInputImageKey];
    [gaussianBlurFilter1 setValue:@0 forKey:kCIInputRadiusKey];
    
    CIImage *outputImage1 = [gaussianBlurFilter1 outputImage];
    CIContext *context1 = [CIContext contextWithOptions:nil];
    cgimg1 = [context1 createCGImage:outputImage1 fromRect:[inputImage1 extent]];
    
    titleImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    titleImage1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    titleImage1.image = [UIImage imageWithCGImage:cgimg1];
    titleImage1.alpha = 1;
    titleImage1.hidden = YES;
    [mainView addSubview:titleImage1];
    
    levelLabel = [[UILabel alloc] initWithFrame:CGRectMake((mainView.frame.size.width/2)-40, 120, (mainView.frame.size.width/2)+30, 30)];
    levelLabel.text = @"";
    levelLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:16];
    levelLabel.backgroundColor = [UIColor clearColor];
    levelLabel.textColor = [UIColor whiteColor];
    levelLabel.textAlignment = NSTextAlignmentRight;
    levelLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainView addSubview:levelLabel];
    
    memoryLabel = [[UILabel alloc] initWithFrame:CGRectMake((mainView.frame.size.width/2)-70, 90, (mainView.frame.size.width/2)+60, 30)];
    memoryLabel.text = @"";
    memoryLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:16];
    memoryLabel.backgroundColor = [UIColor clearColor];
    memoryLabel.textColor = [UIColor whiteColor];
    memoryLabel.textAlignment = NSTextAlignmentRight;
    memoryLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainView addSubview:memoryLabel];
    
    distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, mainView.frame.size.width-20, 30)];
    distanceLabel.text = @"";
    distanceLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:16];
    distanceLabel.backgroundColor = [UIColor clearColor];
    distanceLabel.textColor = [UIColor whiteColor];
    distanceLabel.textAlignment = NSTextAlignmentLeft;
    distanceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainView addSubview:distanceLabel];
    
    paceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 90, mainView.frame.size.width-20, 30)];
    paceLabel.text = @"";
    paceLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:16];
    paceLabel.backgroundColor = [UIColor clearColor];
    paceLabel.textColor = [UIColor whiteColor];
    paceLabel.textAlignment = NSTextAlignmentLeft;
    paceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainView addSubview:paceLabel];
    
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, mainView.frame.size.width-20, 30)];
    timeLabel.text = @"";
    timeLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:16];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainView addSubview:timeLabel];
    
    promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, mainView.frame.size.height-200, mainView.frame.size.width-20, 70)];
    promptLabel.text = @"Ready  Get  Set";
    promptLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:30];
    promptLabel.backgroundColor = [UIColor clearColor];
    promptLabel.textColor = [UIColor whiteColor];
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.numberOfLines = 2;
    promptLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainView addSubview:promptLabel];
    
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
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.latitudeDelta = 0.0003f;
    region.span.longitudeDelta = 0.0003f;
    [mapView setRegion:region animated:YES];

    NSString *tileDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Tiles"];
    NSURL *tileDirectoryURL = [NSURL fileURLWithPath:tileDirectory isDirectory:YES];
    NSString *tileTemplate = [NSString stringWithFormat:@"%@{z}/{x}/{y}.png", tileDirectoryURL];
    MKTileOverlay *overlay = [[MKTileOverlay alloc] initWithURLTemplate:tileTemplate];
    overlay.geometryFlipped = YES;
    [mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];
    
    startBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    startBTN.frame = CGRectMake(20, self.view.frame.size.height-80, mainView.frame.size.width-40, 60);
    [startBTN setTitle:@"GO" forState:UIControlStateNormal];
    [startBTN.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:40]];
    startBTN.backgroundColor = [UIColor colorWithRed:4.0/255.0 green:127.0/255.0 blue:64.0/255.0 alpha:1];
    [startBTN addTarget:self action:@selector(start_Click) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:startBTN];
    
    stopBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    stopBTN.frame = CGRectMake(20, mainView.frame.size.height-80, mainView.frame.size.width-40, 60);
    [stopBTN setTitle:@"STOP" forState:UIControlStateNormal];
    [stopBTN.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:40]];
    stopBTN.backgroundColor = [UIColor colorWithRed:200.0/255 green:0.0/255.0 blue:0.0/255.0 alpha:1];
    [stopBTN addTarget:self action:@selector(stop_Click) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:stopBTN];
    
    UIButton *backBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    backBTN.frame = CGRectMake(8, 24, 48, 48);
    [backBTN setBackgroundImage:[UIImage imageNamed:@"Arrow_Left.png"] forState:UIControlStateNormal];
    [backBTN addTarget:self action:@selector(openHome) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBTN];
    
    gpsBTN = [[UIButton alloc] initWithFrame:CGRectMake(0, 64, mainView.frame.size.width, 25)];
    [gpsBTN addTarget:self action:@selector(callSetting) forControlEvents:UIControlEventTouchUpInside];
    gpsBTN.backgroundColor = [UIColor colorWithRed:195/255.0f green:195/255.0f blue:195/255.0f alpha:0.5f];
    gpsBTN.titleLabel.font = [UIFont systemFontOfSize:16];
    gpsBTN.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    gpsBTN.hidden = YES;
    [mainView addSubview:gpsBTN];
    
    [self checkSetting];
}
- (void)appDidBecomeActive:(NSNotification *)notification {
    [self checkSetting];
}
- (void)checkSetting {
    gpsBTN.hidden = NO;
    if (!([CLLocationManager locationServicesEnabled])
        || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        ) {
        startBTN.hidden = YES;
        promptLabel.textColor = [UIColor redColor];
        promptLabel.text = @"Location Service need to be on.";
        [gpsBTN setTitle:@"Location Service is off" forState:UIControlStateNormal];
    } else {
        startBTN.hidden = NO;
        promptLabel.textColor = [UIColor colorWithRed:4.0/255.0 green:127.0/255.0 blue:64.0/255.0 alpha:1];
        promptLabel.text = @"Ready Get Set";
        [gpsBTN setTitle:@"Location Service is on" forState:UIControlStateNormal];
    }
}
- (void)callSetting {
    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication]openURL:settingsURL];
}
-(void)openHome {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainView"];
    vc.managedObjectContext = self.managedObjectContext;
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)openRunDetails {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RunDetailsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"RunDetails"];
    vc.managedObjectContext = self.managedObjectContext;
    [vc setRun:self.run];
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}
- (void)eachSecond {
    self.seconds++;
    timeLabel.text = [NSString stringWithFormat:@"Time: %@",  [MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
    distanceLabel.text = [NSString stringWithFormat:@"Distance: %@", [MathController stringifyDistance:self.distance]];
    paceLabel.text = [NSString stringWithFormat:@"Pace: %@",  [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
    [self updateBatteryLevel];
    memoryLabel.text = [NSString stringWithFormat:@"Free: %.0f MB", [[UIDevice currentDevice] availableMemory]];
    /*
    NSLog(@"%f", self.distance);
    if (self.distance >= 100.0f && self.distance <= 115.0f) {
        NSLog(@"100 M");
    } else if (self.distance >= 200.0f && self.distance <= 215.0f) {
        NSLog(@"200 M");
    } else if (self.distance >= 300.0f && self.distance <= 315.0f) {
        NSLog(@"300 M");
    }
    */
}
- (void)startLocationUpdates {
    // Create the location manager if this object does not
    // already have one.
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    // Movement threshold for new events.
    self.locationManager.distanceFilter = 10; // meters
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self.locationManager startUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *newLocation in locations) {
        
        NSDate *eventDate = newLocation.timestamp;
        
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
            
            // update distance
            if (self.locations.count > 0) {
                self.distance += [newLocation distanceFromLocation:self.locations.lastObject];
                
                CLLocationCoordinate2D coords[2];
                coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
                coords[1] = newLocation.coordinate;
                
                MKCoordinateRegion region =
                MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
                [mapView setRegion:region animated:YES];
                
                [mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
            }
            
            [self.locations addObject:newLocation];
        }
    }
}
- (void)saveRun {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    Run *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"Run"
                                                inManagedObjectContext:self.managedObjectContext];
    
    newRun.distance = [NSNumber numberWithFloat:self.distance];
    newRun.duration = [NSNumber numberWithInt:self.seconds];
    newRun.timestamp = [NSDate date];
    
    NSMutableArray *locationArray = [NSMutableArray array];
    for (CLLocation *location in self.locations) {
        Location *locationObject = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                                 inManagedObjectContext:self.managedObjectContext];
        
        locationObject.timestamp = location.timestamp;
        locationObject.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        locationObject.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        [locationArray addObject:locationObject];
    }
    
    newRun.locations = [NSOrderedSet orderedSetWithArray:locationArray];
    self.run = newRun;
    
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
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
    }
    return nil;
}
- (void)batteryLevelChanged:(NSNotification *)notification {
    [self updateBatteryLevel];
}
- (void)updateBatteryLevel {
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    if (batteryLevel < 0.0) {
        // -1.0 means battery state is UIDeviceBatteryStateUnknown
        levelLabel.text = NSLocalizedString(@"Unknown", @"");
    }
    else {
        static NSNumberFormatter *numberFormatter = nil;
        if (numberFormatter == nil) {
            numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
            [numberFormatter setMaximumFractionDigits:1];
        }
        NSNumber *levelObj = [NSNumber numberWithFloat:batteryLevel];
        levelLabel.text = [NSString stringWithFormat:@"Battery Level: %@",[numberFormatter stringFromNumber:levelObj]];
    }
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
