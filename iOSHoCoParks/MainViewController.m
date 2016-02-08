//
//  MainViewController.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 6/11/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "MainViewController.h"
#import "MainAmenitiesViewController.h"
#import "NearestResultViewController.h"
#import "SpecialEventsViewController.h"
#import "NewRunViewController.h"
#import "WebViewController.h"
#import "SearchViewController.h"
#import "AnimateLayer.h"
#import "GetJSON.h"
#import "CustomAlert.h"
#import "Reachability.h"

#import <mach/mach.h>
#import <mach/mach_host.h>

static NSString * const newRunSegueName = @"NewRun";

const int MAXIMUM_ZOOM = 20;

@interface MainViewController () {
    UIView *mainView;
    UIView *navMenuView;
    UIView *tipView;
    UIView *aboutView;
    UIView *disclaimerView;
    
    UIWebView *webView;
    
    UIImageView *mainImage;
    UIImageView *internetConnectionImageView;
    UIImageView *localWiFiConnectionImageView;
    UIImageView *remoteHostImageView;
    
    UIButton *exitBTN;
    UIButton *logo;
    UIButton *checkButton0;
    UIButton *acceptButton;
    UIButton *checkButton1;
    UIButton *r1BTN1;
    UIButton *r1BTN2;
    UIButton *r1BTN3;
    UIButton *r1BTN4;
    UIButton *r1BTN5;
    
    CLLocationManager *locationManager;
    
    UILabel* summaryLabel;
    UILabel* summaryLabel1;
    UILabel *remoteHostLabel;
    UILabel *remoteHostStatusField;
    UILabel *internetConnectionStatusField;
    UILabel *localWiFiConnectionStatusField;
    UILabel *timerLBL;
    UILabel *geofenceLabel;
    
    NSString *searchItem;
    NSString *searchType;
    NSString *searchTitle;
    NSString *disclaimerDisplay;
    NSString *aboutDisplay;
    NSString *pulldownMenu;
    NSString *locationItem;
    
    CLGeocoder *geoCoder;
    
    NSMutableArray *json;
    NSInteger siteID;
    int countdown;
    NSTimer *timer;
    BOOL check;
    BOOL checkAbout;
    UIActivityIndicatorView *indicator;
    CGImageRef cgimg;
}

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@end

@implementation MainViewController
@synthesize myAgreeItem;

- (NSArray*)buildGeofenceData {
    //NSLog(@"Build Regions");
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"regions" ofType:@"plist"];
    NSArray *regionArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    NSMutableArray *geofences = [NSMutableArray array];
    for(NSDictionary *regionDict in regionArray) {
        CLRegion *region = [self mapDictionaryToRegion:regionDict];
        [geofences addObject:region];
    }
    
    return [NSArray arrayWithArray:geofences];
}

- (void) initializeRegionMonitoring:(NSArray*)geofences {
    
    if(![CLLocationManager locationServicesEnabled]) {
        return;
    }
    
    if (locationManager == nil) {
        [NSException raise:@"Location Manager Not Initialized" format:@"You must initialize location manager first."];
    }
    
    if(![CLLocationManager isMonitoringAvailableForClass:[CLRegion class]]) {
        return;
    }
    
    for(CLRegion *geofence in geofences) {
        //NSLog(@"\nstart monitor: %@\n", geofence.identifier);
        [locationManager startMonitoringForRegion:geofence];
    }
}

- (CLRegion*)mapDictionaryToRegion:(NSDictionary*)dictionary {
    
    NSString *title = [dictionary valueForKey:@"description"];
    
    CLLocationDegrees latitude = [[dictionary valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[dictionary valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    CLLocationDistance regionRadius = [[dictionary valueForKey:@"radius"] doubleValue];
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:centerCoordinate radius:regionRadius identifier:title];
    
    return region;

    
}
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    //NSLog(@"Enter %@", region.identifier);
    [self postGeofenceNotifWithMessage:[NSString stringWithFormat:@"Nearest to %@", region.identifier] andRegionID:region.identifier];
    geofenceLabel.text = [NSString stringWithFormat:@"Nearest to\n%@", region.identifier];
}
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    //NSLog(@"Exit %@", region.identifier);
    //[self postGeofenceNotifWithMessage:[NSString stringWithFormat:@"Goodbye %@!", region.identifier] andRegionID:region.identifier];
    //geofenceLabel.text = [NSString stringWithFormat:@"Goodbye\n%@!", region.identifier];
}

-(void)postGeofenceNotifWithMessage:(NSString*)aMessage andRegionID:(NSString*)aRegionID {
    UIApplication *app                = [UIApplication sharedApplication];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    if (notification == nil){return;}
    
    notification.alertBody = [NSString stringWithFormat:@"%@", aMessage];
    notification.alertAction = @"Open Webview";
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:aRegionID forKey:aRegionID];
    notification.userInfo = infoDict;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    
    [app presentLocalNotificationNow:notification];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)swipe:(UISwipeGestureRecognizer *)swipeRecogniser {
    if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionDown) {
        [self openReachability];
    } else if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionUp) {
        [self closeReachability];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    disclaimerDisplay = @"off";
    
    NSError *error;
    NSError *jsonError = nil;
    
    NSString* jsonFilePath = [[NSBundle mainBundle] pathForResource:[@"dataMainMenu" stringByReplacingOccurrencesOfString:@" / " withString:@" "] ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath options:kNilOptions error:&jsonError ];
    json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    pulldownMenu = @"NO";
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.headingFilter = 1;
    locationManager.delegate = self;
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    UISwipeGestureRecognizer *upSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    upSwipeGestureRecognizer.numberOfTouchesRequired = 1;
    upSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:upSwipeGestureRecognizer];
    
    UISwipeGestureRecognizer *downSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    downSwipeGestureRecognizer.numberOfTouchesRequired = 1;
    downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:downSwipeGestureRecognizer];
    
    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    mainView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:mainView];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, mainView.frame.size.width, mainView.frame.size.height)];
    webView.backgroundColor = [UIColor blackColor];
    webView.autoresizesSubviews = YES;
    webView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    webView.scalesPageToFit=YES;
    [mainView addSubview:webView];
    
    CIImage *inputImage = [CIImage imageWithCGImage:[[UIImage imageNamed:@"ParksAppBG.png"] CGImage]];
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    [gaussianBlurFilter setValue:inputImage forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@5 forKey:kCIInputRadiusKey];
    
    CIFilter *sepiaToneFilter = [CIFilter filterWithName:@"CISepiaTone"];
    [sepiaToneFilter setDefaults];
    [sepiaToneFilter setValue:inputImage forKey:kCIInputImageKey];
    [sepiaToneFilter setValue:@0.8f forKey:kCIInputIntensityKey];
    
    CIFilter *gloomFilter = [CIFilter filterWithName:@"CIGloom"];
    [gloomFilter setDefaults];
    [gloomFilter setValue:inputImage forKey:kCIInputImageKey];
    [gloomFilter setValue:@50.0f forKey:kCIInputRadiusKey];
    [gloomFilter setValue:@0.75f forKey:kCIInputIntensityKey];
    
    CIImage *outputImage = [gloomFilter outputImage];
    CIContext *context   = [CIContext contextWithOptions:nil];
    cgimg = [context createCGImage:outputImage fromRect:[inputImage extent]];
    
    mainImage = [[UIImageView alloc] initWithFrame:CGRectMake(-50, -50, mainView.frame.size.width+100, mainView.frame.size.height+100)];
    mainImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    mainImage.image = [UIImage imageWithCGImage:cgimg];
    mainImage.alpha = 1.0;
    [mainView addSubview:mainImage];

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
    
    [mainImage addMotionEffect:myGroup];
    
    /*
    SKView *skv = [[SKView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, mainView.frame.size.height)];
    skv.backgroundColor = [UIColor clearColor];
    
    [mainView addSubview:skv];
    
    SKView * skView = skv;
    skView.showsFPS = YES;
    skView.showsNodeCount = NO;
    
    // Create and configure the scene.
    SKScene * scene = [SnowScene sceneWithSize:skView.bounds.size];
    scene.backgroundColor = [SKColor clearColor];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    */
    
    geofenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, mainView.frame.size.width, 50)];
    geofenceLabel.text = @"";
    geofenceLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    geofenceLabel.backgroundColor = [UIColor clearColor];
    geofenceLabel.textColor = [UIColor whiteColor];
    geofenceLabel.textAlignment = NSTextAlignmentCenter;
    geofenceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    geofenceLabel.numberOfLines = 2;
    [mainView addSubview:geofenceLabel ];
    
    logo = [UIButton buttonWithType:UIButtonTypeCustom];
    logo.frame = CGRectMake(0, 85, mainView.frame.size.width, 60);
    logo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [logo setBackgroundImage:[UIImage imageNamed:@"HCRPLogo_Green.png"] forState:UIControlStateNormal];
    [logo addTarget:self action:@selector(openAbout) forControlEvents:UIControlEventTouchUpInside];
    logo.tag = 0;
    logo.alpha = 0.8;
    [mainView addSubview:logo];

    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(20, 180, self.view.frame.size.width-40, 280) style:UITableViewStylePlain];
    self.mainTableView.dataSource = self;
    self.mainTableView.delegate = self;
    self.mainTableView.backgroundColor = [UIColor clearColor];
    self.mainTableView.alpha = 1.0;
    [mainView addSubview:self.mainTableView];
    
    [self.mainTableView reloadData];
    
    navMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, 64)];
    navMenuView.backgroundColor = [UIColor clearColor];
    navMenuView.alpha = 0;
    navMenuView.tag = 1;
    [mainView addSubview:navMenuView];
    
    UIButton *menuBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBTN.frame = CGRectMake(self.view.frame.size.width-58, 28, 48, 48);
    [menuBTN setBackgroundImage:[UIImage imageNamed:@"List_White.png"] forState:UIControlStateNormal];
    [menuBTN addTarget:self action:@selector(getMenu:) forControlEvents:UIControlEventTouchUpInside];
    menuBTN.tag = 1;
    [mainView addSubview:menuBTN];
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    indicator.transform = CGAffineTransformMakeScale(2, 2);
    indicator.backgroundColor = [UIColor clearColor];
    [self.view addSubview:indicator];
    
    tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    tipView.backgroundColor = [UIColor blackColor];
    tipView.alpha = 1.0;
    tipView.tag = 1;
    [self.view addSubview:tipView];
    
    CGRect row1aFrame = CGRectMake(35, 54, 32, 32);
    
    row1aFrame.origin.y += 40;
    remoteHostImageView = [[UIImageView alloc] initWithFrame:row1aFrame];
    remoteHostImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    remoteHostImageView.image = [UIImage imageNamed:@"Airport.png"];
    remoteHostImageView.alpha = 1;
    [tipView addSubview:remoteHostImageView];
    
    row1aFrame.origin.y += 70;
    internetConnectionImageView = [[UIImageView alloc] initWithFrame:row1aFrame];
    internetConnectionImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    internetConnectionImageView.image = [UIImage imageNamed:@"Airport.png"];
    internetConnectionImageView.alpha = 1;
    [tipView addSubview:internetConnectionImageView];
    
    row1aFrame.origin.y += 70;
    localWiFiConnectionImageView = [[UIImageView alloc] initWithFrame:row1aFrame];
    localWiFiConnectionImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    localWiFiConnectionImageView.image = [UIImage imageNamed:@"Airport.png"];
    localWiFiConnectionImageView.alpha = 1;
    [tipView addSubview:localWiFiConnectionImageView];
    
    CGRect row1bFrame = CGRectMake(25, 60, self.view.frame.size.width-50, 40);
    
    remoteHostLabel = [[UILabel alloc] initWithFrame:row1bFrame];
    remoteHostLabel.text = @"Remote Host";
    remoteHostLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
    remoteHostLabel.backgroundColor = [UIColor clearColor];
    remoteHostLabel.textColor = [UIColor whiteColor];
    remoteHostLabel.alpha = 1.0;
    remoteHostLabel.textAlignment = NSTextAlignmentLeft;
    remoteHostLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [tipView addSubview:remoteHostLabel];
    
    row1bFrame.origin.y += 70;
    UILabel *internetConnectionLabel = [[UILabel alloc] initWithFrame:row1bFrame];
    internetConnectionLabel.text = @"TCP/IP Routing Available";
    internetConnectionLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
    internetConnectionLabel.backgroundColor = [UIColor clearColor];
    internetConnectionLabel.textColor = [UIColor whiteColor];
    internetConnectionLabel.alpha = 1.0;
    internetConnectionLabel.textAlignment = NSTextAlignmentLeft;
    internetConnectionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [tipView addSubview:internetConnectionLabel];
    
    row1bFrame.origin.y += 70;
    UILabel *localWiFiConnectionLabel = [[UILabel alloc] initWithFrame:row1bFrame];
    localWiFiConnectionLabel.text = @"Local WiFi";
    localWiFiConnectionLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
    localWiFiConnectionLabel.backgroundColor = [UIColor clearColor];
    localWiFiConnectionLabel.textColor = [UIColor whiteColor];
    localWiFiConnectionLabel.alpha = 1.0;
    localWiFiConnectionLabel.textAlignment = NSTextAlignmentLeft;
    localWiFiConnectionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [tipView addSubview:localWiFiConnectionLabel];
    
    CGRect row1Frame = CGRectMake(75, 55, self.view.frame.size.width-85, 30);
    
    row1Frame.origin.y += 40;
    remoteHostStatusField = [[UILabel alloc] initWithFrame:row1Frame];
    remoteHostStatusField.text = @"remote host";
    remoteHostStatusField.font = [UIFont fontWithName:@"TrebuchetMS" size:16];
    remoteHostStatusField.backgroundColor = [UIColor clearColor];
    remoteHostStatusField.textColor = [UIColor whiteColor];
    remoteHostStatusField.alpha = 1.0;
    remoteHostStatusField.textAlignment = NSTextAlignmentLeft;
    remoteHostStatusField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [tipView addSubview:remoteHostStatusField];
    
    row1Frame.origin.y += 70;
    internetConnectionStatusField = [[UILabel alloc] initWithFrame:row1Frame];
    internetConnectionStatusField.text = @"internet";
    internetConnectionStatusField.font = [UIFont fontWithName:@"TrebuchetMS" size:16];
    internetConnectionStatusField.backgroundColor = [UIColor clearColor];
    internetConnectionStatusField.textColor = [UIColor whiteColor];
    internetConnectionStatusField.alpha = 1.0;
    internetConnectionStatusField.textAlignment = NSTextAlignmentLeft;
    internetConnectionStatusField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [tipView addSubview:internetConnectionStatusField];
    
    row1Frame.origin.y += 70;
    localWiFiConnectionStatusField = [[UILabel alloc] initWithFrame:row1Frame];
    localWiFiConnectionStatusField.text = @"wifi";
    localWiFiConnectionStatusField.font = [UIFont fontWithName:@"TrebuchetMS" size:16];
    localWiFiConnectionStatusField.backgroundColor = [UIColor clearColor];
    localWiFiConnectionStatusField.textColor = [UIColor whiteColor];
    localWiFiConnectionStatusField.alpha = 1.0;
    localWiFiConnectionStatusField.textAlignment = NSTextAlignmentLeft;
    localWiFiConnectionStatusField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [tipView addSubview:localWiFiConnectionStatusField];
    
    CGRect row1cFrame = CGRectMake(25, row1bFrame.origin.y+90, self.view.frame.size.width-50, 120);
    summaryLabel1 = [[UILabel alloc] initWithFrame:row1cFrame];
    summaryLabel1.text = @"";
    summaryLabel1.font = [UIFont fontWithName:@"TrebuchetMS" size:16];
    summaryLabel1.backgroundColor = [UIColor clearColor];
    summaryLabel1.textColor = [UIColor yellowColor];
    summaryLabel1.alpha = 1.0;
    summaryLabel1.textAlignment = NSTextAlignmentLeft;
    summaryLabel1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    summaryLabel1.numberOfLines = 6;
    [tipView addSubview:summaryLabel1];

    exitBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    exitBTN.frame = CGRectMake(tipView.frame.size.width-50, 22, 40, 40);
    [exitBTN setBackgroundImage:[UIImage imageNamed:@"Exit.png"] forState:UIControlStateNormal];
    [exitBTN addTarget:self action:@selector(closeReachability) forControlEvents:UIControlEventTouchUpInside];
    [tipView addSubview:exitBTN];
    
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server you want to monitor.
    NSString *remoteHostName = @"www.apple.com";
    NSString *remoteHostLabelFormatString = NSLocalizedString(@"Remote Host: %@", @"Remote host label format string");
    remoteHostLabel.text = [NSString stringWithFormat:remoteHostLabelFormatString, remoteHostName];
    
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
    [self updateInterfaceWithReachability:self.wifiReachability];
    
    disclaimerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, mainView.frame.size.height)];
    disclaimerView.backgroundColor = [UIColor darkGrayColor];
    [mainView addSubview:disclaimerView];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, self.view.frame.size.width-20, 24)];
    label1.text = @"Terms and Conditions";
    label1.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    label1.backgroundColor = [UIColor clearColor];
    label1.textColor = [UIColor colorWithRed:195/255.0f green:195/255.0f blue:195/255.0f alpha:1.0f];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [disclaimerView addSubview:label1];
    
    UITextView *label2 = [[UITextView alloc] initWithFrame:CGRectMake(10, 45, self.view.frame.size.width-20, disclaimerView.frame.size.height-150)];
    label2.text = @"Your access to and use of the Howard County Government website (the 'Site') is subject to the following terms and conditions, as well as all applicable laws. Your access to the Site is in consideration for your agreement to these Terms and Conditions of Use, whether or not you are a registered user. By accessing, browsing, and using the Site, you accept, without limitation or qualification, these Terms and Conditions of Use.\n\nThere are sections of the Howard County Government website that connect you to other sites outside of the control of the Howard County Government. These terms and conditions apply only to those areas that are registered under the Howard County Government name and its agencies. Refer to the Terms of Use for those sites outside of the Howard County Government control.\n\nModification of the Agreement\n\nHoward County Government maintains the right to modify these Terms and Conditions of Use and may do so by posting notice of such modifications on this page. Any modification is effective immediately upon posting the modification unless otherwise stated. Your continued use of the Site following the posting of any modification signifies your acceptance of such modification. You should periodically visit this page to review the current Terms and Conditions of Use.\n\nConduct\n\nYou agree to access and use the Site only for lawful purposes. You are solely responsible for the knowledge of and adherence to any and all laws, statutes, rules and regulations pertaining to your use of the Site. By accessing the Site, you agree that you will not:\n\nUse the Site to commit a criminal offense or to encourage others to conduct that which would constitute a criminal offense or give rise to a civil liability;\nPost or transmit any unlawful, threatening, libelous, harassing, defamatory, vulgar, obscene, pornographic, profane, or otherwise objectionable content;\nUse the Site to impersonate other parties or entities;\nUse the Site to upload any content that contains a software virus, 'Trojan Horse' or any other computer code, files, or programs that may alter, damage, or interrupt the functionality of the Site or the hardware or software of any other person who accesses the Site;\nUpload, post, email, or otherwise transmit any materials that you do not have a right to transmit under any law or under a contractual relationship;\nAlter, damage, or delete any content posted on the site;\nDisrupt the normal flow of communication in any way;\nClaim a relationship with or speak for any business, association, or other organization for which you are not authorized to claim such a relationship;\nPost or transmit any unsolicited advertising, promotional materials, or other forms of solicitation;\nPost any material that infringes or violates the intellectual property rights of another; or\nCollect or store personal information about others.\n\nTermination of Use\n\nHoward County Government may, in its sole discretion, terminate or suspend your access and use of this Site without notice and for any reason, including for violation of these Terms and Conditions of Use or for other conduct which the Howard County Government, in its sole discretion, believes is unlawful or harmful to others. In the event of termination, you are no longer authorized to access the Site, and the Howard County Government will use whatever means possible to enforce this termination.\n\nOther Site Links\n\nSome links on the Site lead to websites that are not operated by the Howard County Government. The Howard County Government does not control these websites nor do we review or control their content. The Howard County Government provides these links to users for convenience. These links are not an endorsement of products, services, or information, and do not imply an association between the Howard County Government and the operators of the linked website.\n\nPolicy on Spamming\n\nYou specifically agree that you will not utilize email addresses obtained through using the Howard County Government's website to transmit the same or substantially similar unsolicited message to 10 or more recipients in a single day, nor 20 or more emails in a single week (consecutive 7-day period), unless it is required for legitimate business purposes. The Howard County Government, in its sole and exclusive discretion, will determine violations of the limitations on email usage set forth in these Terms and Conditions of Use.\n\nContent\n\nThe Howard County Government has the right to monitor the content that you provide, but shall not be obligated to do so. Although the Howard County Government cannot monitor all postings on the Site, we reserve the right (but assume no obligation) to delete, move, or edit any postings that come to our attention that we consider unacceptable or inappropriate, whether for legal or other reasons. United States and foreign copyright laws and international conventions protect the contents of the Site. You agree to abide by all copyright notices.\n\nIndemnity\n\nYou agree to defend, indemnify, and hold harmless the Howard County Government and its employees from any and all liabilities and costs incurred by Indemnified Parties in connection with any claim arising from any breach by you of these Terms and Conditions of Use, including reasonable attorneys' fees and costs. You agree to cooperate as fully as may be reasonably possible in the defense of any such claim. The Howard County Government reserves the right to assume, at its own expense, the exclusive defense and control of any matter otherwise subject to indemnification by you. You in turn shall not settle any matter without the written consent of the Howard County Government.\n\nDisclaimer of Warranty\n\nYou expressly understand and agree that your use of the Site, or any material available through this Site, is at your own risk. Neither the Howard County Government nor its employees warrant that the Site will be uninterrupted, problem-free, free of omissions, or error-free; nor do they make any warranty as to the results that may be obtained from the use of the Site. The content and function of the Site are provided to you 'as is,' without warranties of any kind, either express or implied, including, but not limited to, warranties of title, merchantability, fitness for a particular purpose or use, or 'currentness.'\n\nLimitation of Liability\n\nIn no event will the Howard County Government or its employees be liable for any incidental, indirect, special, punitive, exemplary, or consequential damages, arising out of your use of or inability to use the Site, including without limitation, loss of revenue or anticipated profits, loss of goodwill, loss of business, loss of data, computer failure or malfunction, or any and all other damages.";
    label2.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    label2.backgroundColor = [UIColor clearColor];
    label2.textColor = [UIColor colorWithRed:195/255.0f green:195/255.0f blue:195/255.0f alpha:1.0f];
    label2.textAlignment = NSTextAlignmentLeft;
    label2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    label2.editable=FALSE;
    [disclaimerView addSubview:label2];
    
    label2.layer.cornerRadius = 5.0;
    label2.clipsToBounds = YES;
    label2.layer.borderColor = [UIColor grayColor].CGColor;
    label2.layer.borderWidth = 1;
    label2.layer.backgroundColor = (__bridge CGColorRef)([UIColor lightGrayColor]);
    label2.layer.shadowOffset = CGSizeMake(-2,0);
    label2.layer.shadowOpacity = 0.1;
    label2.layer.shadowPath = [UIBezierPath bezierPathWithRect:label2.bounds].CGPath;
    
    UIImage *buttonImage0 = [UIImage imageNamed:@"checkbox_unchecked_icon.png"];
    
    checkButton0 = [UIButton buttonWithType:UIButtonTypeCustom];
    checkButton0.frame = CGRectMake(10, disclaimerView.frame.size.height-90, 32, 32);
    [checkButton0 setImage:buttonImage0 forState:UIControlStateNormal];
    [checkButton0 addTarget:self action:@selector(chkAgree) forControlEvents:UIControlEventTouchUpInside];
    [disclaimerView addSubview:checkButton0];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(52, disclaimerView.frame.size.height-85, 100, 24)];
    label3.text = @"I agree";
    label3.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    label3.backgroundColor = [UIColor clearColor];
    label3.textColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    label3.textAlignment = NSTextAlignmentLeft;
    label3.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [disclaimerView addSubview:label3];
    
    acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(10, disclaimerView.frame.size.height-50, disclaimerView.frame.size.width-20, 40)];
    [acceptButton addTarget:self action:@selector(disclaimer_Click) forControlEvents:UIControlEventTouchUpInside];
    [acceptButton setTitle:@"Accept and Continue" forState:UIControlStateNormal];
    acceptButton.backgroundColor = [UIColor colorWithRed:195/255.0f green:195/255.0f blue:195/255.0f alpha:1.0f];
    acceptButton.titleLabel.font = [UIFont systemFontOfSize:20];
    acceptButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    acceptButton.hidden = YES;
    [disclaimerView addSubview:acceptButton];
    
    check=NO;
    
    myAgreeItem = @"No";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.myAgreeItem = [defaults objectForKey:@"Agreement"];
    
    if ([myAgreeItem isEqualToString:@"Yes"]) {
        disclaimerDisplay = @"off";
        [self disclaimer_Click];
        //NSLog(@"1a");
    } else if ([myAgreeItem isEqualToString:@"No"]) {
        disclaimerDisplay = @"on";
        [self disclaimer_Click];
        //NSLog(@"2b");
    } else {
        disclaimerDisplay = @"on";
        [self disclaimer_Click];
        //NSLog(@"3c");
    }
    
    aboutView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    aboutView.backgroundColor = [UIColor darkGrayColor];
    aboutView.alpha = 1.0;
    aboutView.tag = 1;
    [self.view addSubview:aboutView];
    
    UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake((aboutView.frame.size.width/2)-50, 30, 100, 100)];
    logoImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    logoImage.image = [UIImage imageNamed:@"howard_county_seal.gif"];
    logoImage.alpha = 1.0;
    [aboutView addSubview:logoImage];
    
    UILabel *appTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, aboutView.frame.size.width-20, 30)];
    appTitle.text = @"HoCo Parks";
    appTitle.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:24];
    appTitle.backgroundColor = [UIColor clearColor];
    appTitle.textColor = [UIColor whiteColor];
    appTitle.alpha = 1.0;
    appTitle.textAlignment = NSTextAlignmentCenter;
    appTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [aboutView addSubview:appTitle];
    
    UILabel *appSubTitle1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 170, aboutView.frame.size.width-200, 20)];
    appSubTitle1.text = @"Version 1.0.1";
    appSubTitle1.font = [UIFont fontWithName:@"TrebuchetMS" size:14];
    appSubTitle1.backgroundColor = [UIColor clearColor];
    appSubTitle1.textColor = [UIColor whiteColor];
    appSubTitle1.alpha = 1.0;
    appSubTitle1.textAlignment = NSTextAlignmentCenter;
    appSubTitle1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [aboutView addSubview:appSubTitle1];
    
    UILabel *appSubTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(100, 190, aboutView.frame.size.width-200, 20)];
    appSubTitle2.text = @"12.01.2015";
    appSubTitle2.font = [UIFont fontWithName:@"TrebuchetMS" size:14];
    appSubTitle2.backgroundColor = [UIColor clearColor];
    appSubTitle2.textColor = [UIColor whiteColor];
    appSubTitle2.alpha = 1.0;
    appSubTitle2.textAlignment = NSTextAlignmentCenter;
    appSubTitle2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [aboutView addSubview:appSubTitle2];
    
    UITextView *aboutApp = [[UITextView alloc] initWithFrame:CGRectMake(10, 215, aboutView.frame.size.width-20, aboutView.frame.size.height-320)];
    aboutApp.text = @"    The HoCo Parks app helps you explore and navigate the more than 50 parks in the Howard County Department of Recreation & Parks system. Find your nearest park, amenity, playground, pavilion and trail and enjoy all we have to offer in Howard County!\n\nThings to Remember\n\n    Help keep your parks beautiful. Please take your trash and recyclable items home. Take only pictures and leave only footprints.\n    Clean up after your dog and keep it leashed. Dog droppings may attract disease-harboring pests, and even a friendly dog can scare birds, wildlife and other park visitors.\n    All of our parks are inhabited by a wide variety of wildlife such as deer, snakes, fish, rabbits, insects and birds. Please do not disturb them; remember, this is their home.";
    aboutApp.font = [UIFont fontWithName:@"TrebuchetMS" size:14];
    aboutApp.backgroundColor = [UIColor clearColor];
    aboutApp.textColor = [UIColor whiteColor];
    aboutApp.textAlignment = NSTextAlignmentLeft;
    aboutApp.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    aboutApp.editable=FALSE;
    [aboutView addSubview:aboutApp];
    
    UIButton *showButton = [[UIButton alloc] initWithFrame:CGRectMake(120, aboutView.frame.size.height-90, aboutView.frame.size.width-240, 40)];
    [showButton addTarget:self action:@selector(start_Click) forControlEvents:UIControlEventTouchUpInside];
    [showButton setTitle:@"Start" forState:UIControlStateNormal];
    showButton.backgroundColor = [UIColor grayColor];
    showButton.titleLabel.font = [UIFont systemFontOfSize:20];
    showButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [aboutView addSubview:showButton];
    
    checkAbout=NO;
    
    UIImage *buttonImage1 = [UIImage imageNamed:@"checkbox_unchecked_icon.png"];
    
    checkButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    checkButton1.frame = CGRectMake(20, aboutView.frame.size.height-40, 32, 32);
    [checkButton1 setImage:buttonImage1 forState:UIControlStateNormal];
    [checkButton1 addTarget:self action:@selector(chkAbout) forControlEvents:UIControlEventTouchUpInside];
    [aboutView addSubview:checkButton1];
    
    UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, aboutView.frame.size.height-35, 200, 20)];
    showLabel.text = @"Do not show this again";
    showLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    showLabel.backgroundColor = [UIColor clearColor];
    showLabel.textColor = [UIColor whiteColor];
    showLabel.textAlignment = NSTextAlignmentLeft;
    showLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [aboutView addSubview:showLabel];
    
    NSUserDefaults *aboutDefaults = [NSUserDefaults standardUserDefaults];
    aboutDisplay = [aboutDefaults objectForKey:@"about"];
    
    if ([aboutDisplay isEqualToString:@"ON"]) {
        [AnimateLayer animateLayerVertical:0 layer:aboutView];
    } else if ([aboutDisplay isEqualToString:@"OFF"]) {
        [AnimateLayer animateLayerVertical:self.view.frame.size.height layer:aboutView];
    } else {
        [AnimateLayer animateLayerVertical:0 layer:aboutView];
        aboutDisplay = @"ON";
    }
    
    [self closeReachability];
}
- (void)openAbout {
    checkAbout=YES;
    aboutDisplay = @"OFF";
    [checkButton1 setImage:[UIImage imageNamed:@"checkbox_checked_icon.png"]forState:UIControlStateNormal];
    [AnimateLayer animateLayerVertical:0 layer:aboutView];
}
- (void)chkAgree {
    if (check==NO) {
        [checkButton0 setImage:[UIImage imageNamed:@"checkbox_checked_icon.png"]forState:UIControlStateNormal];
        check=YES;
        acceptButton.hidden=NO;
    }
    else if (check==YES) {
        [checkButton0 setImage:[UIImage imageNamed:@"checkbox_unchecked_icon.png"]forState:UIControlStateNormal];
        check=NO;
        acceptButton.hidden=YES;
    }
}
- (void)chkAbout {
    if (checkAbout==NO) {
        [checkButton1 setImage:[UIImage imageNamed:@"checkbox_checked_icon.png"]forState:UIControlStateNormal];
        checkAbout=YES;
        aboutDisplay = @"OFF";
    }
    else if (checkAbout==YES) {
        [checkButton1 setImage:[UIImage imageNamed:@"checkbox_unchecked_icon.png"]forState:UIControlStateNormal];
        checkAbout=NO;
        aboutDisplay = @"ON";
    }
}
- (void)start_Click {
    if ([aboutDisplay isEqualToString:@"OFF"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"OFF" forKey:@"about"];
        [defaults synchronize];
    } else if ([aboutDisplay isEqualToString:@"ON"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"ON" forKey:@"about"];
        [defaults synchronize];
    }
    [AnimateLayer animateLayerVertical:self.view.frame.size.height layer:aboutView];
}
- (void)disclaimer_Click {
    if ([disclaimerDisplay isEqualToString:@"off"]) {
        [AnimateLayer animateLayerVertical:self.view.frame.size.height layer:disclaimerView];
        disclaimerDisplay = @"on";
        myAgreeItem=@"Yes";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.myAgreeItem forKey:@"Agreement"];
        [defaults synchronize];
    } else if ([disclaimerDisplay isEqualToString:@"on"]) {
        disclaimerDisplay = @"off";
        [AnimateLayer animateLayerVertical:0 layer:disclaimerView];
    }
}

- (void) reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability {
    
    if (reachability == self.hostReachability) {
        [self configureTextField:remoteHostStatusField imageView:remoteHostImageView reachability:reachability];
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        BOOL connectionRequired = [reachability connectionRequired];
        
        summaryLabel.hidden = (netStatus != ReachableViaWWAN);
        NSString* baseLabelText = @"";
        
        if (connectionRequired) {
            baseLabelText = NSLocalizedString(@"Cellular data network is available.\nInternet traffic will be routed through it after a connection is established.", @"Reachability text if a connection is required");
        } else {
            baseLabelText = NSLocalizedString(@"Cellular data network is active.\nInternet traffic will be routed through it.", @"Reachability text if a connection is not required");
        }
        summaryLabel.text = baseLabelText;
    }

    if (reachability == self.internetReachability) {
        [self configureTextField:internetConnectionStatusField imageView:internetConnectionImageView reachability:reachability];
    }
    
    if (reachability == self.wifiReachability) {
        [self configureTextField:localWiFiConnectionStatusField imageView:localWiFiConnectionImageView reachability:reachability];
    }
}

- (void)configureTextField:(UILabel *)textField imageView:(UIImageView *)imageView reachability:(Reachability *)reachability {
    
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    NSString* statusString;// = @"";
    
    switch (netStatus) {
        
        case NotReachable:        {
            statusString = NSLocalizedString(@"Access Not Available", @"Text field text for access is not available");
            imageView.image = [UIImage imageNamed:@"stop-32.png"] ;
            /*
             Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
             */
            summaryLabel.text = statusString;
            connectionRequired = NO;
            //[self openReachability];
            break;
        }
        
        case ReachableViaWWAN:        {
            statusString = NSLocalizedString(@"Reachable WWAN", @"");
            imageView.image = [UIImage imageNamed:@"WWAN5.png"];
            //countdown = 5;
            //timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
            break;
        }
        case ReachableViaWiFi:        {
            statusString= NSLocalizedString(@"Reachable WiFi", @"");
            imageView.image = [UIImage imageNamed:@"Airport.png"];
            //countdown = 5;
            //timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
            break;
        }
    }
    
    if (connectionRequired) {
        NSString *connectionRequiredFormatString = NSLocalizedString(@"%@, Connection Required", @"Concatenation of status string with connection requirement");
        statusString= [NSString stringWithFormat:connectionRequiredFormatString, statusString];
    }
    textField.text= statusString;
    summaryLabel.text = statusString;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

-(void)openReachability {
    [AnimateLayer animateLayerVertical:self.view.frame.size.height+50 layer:mainView];
    [AnimateLayer animateLayerVertical:0 layer:tipView];
    summaryLabel1.text = @"Local data will be used when there is no network connection! Only Driving Directions and Pathway / Trail Profile Elevation are required network connection.";
}
-(void)countDown {
    countdown -= 1;
    if (countdown==0) {
        [timer invalidate];
        [self closeReachability];
    }
}
-(void)closeReachability {
    [AnimateLayer animateLayerVertical:0 layer:mainView];
    [AnimateLayer animateLayerVertical:-(tipView.frame.size.height) layer:tipView];
    summaryLabel1.text = @"";
}

-(void)getMenu:(UIButton *)btn {
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if ([pulldownMenu isEqualToString:@"NO"]) {
                             pulldownMenu = @"YES";
                             [AnimateLayer animateLayerVertical:(CGFloat)165 layer:(UIView *)logo];
                             [AnimateLayer animateLayerVertical:(CGFloat)260 layer:(UIView *)self.mainTableView];
                             navMenuView.frame = CGRectMake(0, 0, mainView.frame.size.width, 160);
                             navMenuView.alpha = 1;
                         } else if ([pulldownMenu isEqualToString:@"YES"]) {
                             pulldownMenu = @"NO";
                             navMenuView.frame = CGRectMake(0, 0, mainView.frame.size.width, 64);
                             [AnimateLayer animateLayerVertical:(CGFloat)85 layer:(UIView *)logo];
                             [AnimateLayer animateLayerVertical:(CGFloat)180 layer:(UIView *)self.mainTableView];
                             navMenuView.alpha = 0;
                             for(UIView *subview in [navMenuView subviews]) {
                                 [subview removeFromSuperview];
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         if ([pulldownMenu isEqualToString:@"YES"]) {
                            [self createMenu];
                         }
                         
                     }];
}

-(void)createMenu {
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    
    CIImage *inputImage = [CIImage imageWithCGImage:[[UIImage imageNamed:@"NearestParksBG.jpeg"] CGImage]];
    [gaussianBlurFilter setValue:inputImage forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@30 forKey:kCIInputRadiusKey];

    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    cgimg = [context createCGImage:outputImage fromRect:[inputImage extent]];
    
    UIImageView *menuImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, navMenuView.frame.size.width, navMenuView.frame.size.height)];
    menuImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    menuImage.image = [UIImage imageWithCGImage:cgimg];
    menuImage.alpha = 1;
    [navMenuView addSubview:menuImage];
    
    CGRect row1Frame = CGRectMake((self.view.frame.size.width/2)-144, 80, 32, 32);
    
    r1BTN1 = [UIButton buttonWithType:UIButtonTypeCustom];
    r1BTN1 = [UIButton buttonWithType:UIButtonTypeCustom];
    r1BTN1.frame = row1Frame;
    r1BTN1.tag = 1;
    [r1BTN1 setBackgroundImage:[UIImage imageNamed:@"phone.png"] forState:UIControlStateNormal];
    [r1BTN1 addTarget:self action:@selector(openCall) forControlEvents:UIControlEventTouchUpInside];
    [navMenuView addSubview:r1BTN1];
    
    row1Frame.origin.x += 62;
    r1BTN2 = [UIButton buttonWithType:UIButtonTypeCustom];
    r1BTN2 = [UIButton buttonWithType:UIButtonTypeCustom];
    r1BTN2.frame = row1Frame;
    r1BTN2.tag = 2;
    [r1BTN2 setBackgroundImage:[UIImage imageNamed:@"rules.png"] forState:UIControlStateNormal];
    [r1BTN2 addTarget:self action:@selector(openRule) forControlEvents:UIControlEventTouchUpInside];
    [navMenuView addSubview:r1BTN2];
    
    r1BTN3 = [UIButton buttonWithType:UIButtonTypeCustom];
    r1BTN3 = [UIButton buttonWithType:UIButtonTypeCustom];
    r1BTN3.frame = CGRectMake((self.view.frame.size.width/2)-25, 80, 50, 50);
    r1BTN3.tag = 3;
    [r1BTN3 setBackgroundImage:[UIImage imageNamed:@"tellHoCo.png"] forState:UIControlStateNormal];
    [r1BTN3 addTarget:self action:@selector(openTellHoCo) forControlEvents:UIControlEventTouchUpInside];
    [navMenuView addSubview:r1BTN3];
    
    row1Frame.origin.x += 136;
    r1BTN4 = [UIButton buttonWithType:UIButtonTypeCustom];
    r1BTN4 = [UIButton buttonWithType:UIButtonTypeCustom];
    r1BTN4.frame = row1Frame;
    r1BTN4.tag = 4;
    [r1BTN4 setBackgroundImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    [r1BTN4 addTarget:self action:@selector(openSearch) forControlEvents:UIControlEventTouchUpInside];
    [navMenuView addSubview:r1BTN4];

    row1Frame.origin.x += 62;
    r1BTN5 = [UIButton buttonWithType:UIButtonTypeCustom];
    r1BTN5 = [UIButton buttonWithType:UIButtonTypeCustom];
    r1BTN5.frame = row1Frame;
    r1BTN5.tag = 5;
    [r1BTN5 setBackgroundImage:[UIImage imageNamed:@"calendar.png"] forState:UIControlStateNormal];
    [r1BTN5 addTarget:self action:@selector(openSpecialEvents) forControlEvents:UIControlEventTouchUpInside];
    [navMenuView addSubview:r1BTN5];
    
    CGRect row2Frame = CGRectMake((self.view.frame.size.width/2)-159, 110, 60, 40);

    UILabel *r2LBL1 = [[UILabel alloc] initWithFrame:row2Frame];
    r2LBL1.text = @"Call Park\nRanger";
    r2LBL1.font = [UIFont fontWithName:@"TrebuchetMS" size:12];
    r2LBL1.backgroundColor = [UIColor clearColor];
    r2LBL1.textColor = [UIColor whiteColor];
    r2LBL1.alpha = 1.0;
    r2LBL1.textAlignment = NSTextAlignmentCenter;
    r2LBL1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    r2LBL1.numberOfLines = 2;
    [navMenuView addSubview:r2LBL1];
    
    row2Frame.origin.x += 62;
    UILabel *r2LBL2 = [[UILabel alloc] initWithFrame:row2Frame];
    r2LBL2.text = @"Rules &\nRegulation";
    r2LBL2.font = [UIFont fontWithName:@"TrebuchetMS" size:12];
    r2LBL2.backgroundColor = [UIColor clearColor];
    r2LBL2.textColor = [UIColor whiteColor];
    r2LBL2.alpha = 1.0;
    r2LBL2.textAlignment = NSTextAlignmentCenter;
    r2LBL2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    r2LBL2.numberOfLines = 2;
    [navMenuView addSubview:r2LBL2];
    
    row2Frame.origin.x += 136;
    UILabel *r2LBL4 = [[UILabel alloc] initWithFrame:row2Frame];
    r2LBL4.text = @"Search\nAmenities";
    r2LBL4.font = [UIFont fontWithName:@"TrebuchetMS" size:12];
    r2LBL4.backgroundColor = [UIColor clearColor];
    r2LBL4.textColor = [UIColor whiteColor];
    r2LBL4.alpha = 1.0;
    r2LBL4.textAlignment = NSTextAlignmentCenter;
    r2LBL4.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    r2LBL4.numberOfLines = 2;
    [navMenuView addSubview:r2LBL4];
    
    row2Frame.origin.x += 62;
    UILabel *r2LBL5 = [[UILabel alloc] initWithFrame:row2Frame];
    r2LBL5.text = @"Special\nEvents";
    r2LBL5.font = [UIFont fontWithName:@"TrebuchetMS" size:12];
    r2LBL5.backgroundColor = [UIColor clearColor];
    r2LBL5.textColor = [UIColor whiteColor];
    r2LBL5.alpha = 1.0;
    r2LBL5.textAlignment = NSTextAlignmentCenter;
    r2LBL5.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    r2LBL5.numberOfLines = 2;
    [navMenuView addSubview:r2LBL5];

}
-(void)openRule {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WebView"];
    vc.webItem = @"rules";
    vc.backViewName = @"Main";
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)openTellHoCo {
    NSURL *webURL = [NSURL URLWithString:@"https://itunes.apple.com/us/app/tell-hoco/id874344402?mt=8"];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:webURL];
    [webView loadRequest:requestURL];
    [webView setScalesPageToFit:YES];
}
-(void)openSpecialEvents {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SpecialEventsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SpecialEventsView"];
    vc.backViewName = @"Main";
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)openCall {
    [self presentViewController:[CustomAlert makePhoneCall] animated:YES completion:nil];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [json count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info;
    info = [json objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    UIButton *detailInfoButton;
    UILabel *parkLabel;
    static NSString *cellIdentifier = @"Cell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
        CGRect myFrame = CGRectMake(20.0, 10.0, self.mainTableView.frame.size.width-60, 25.0);
        parkLabel = [[UILabel alloc] initWithFrame:myFrame];
        parkLabel.backgroundColor = [UIColor clearColor];
        parkLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
        parkLabel.textColor = [UIColor whiteColor];
        parkLabel.text = [info objectForKey:@"name"];
        [cell.contentView addSubview:parkLabel];
        
        NSInteger mytag = [[info objectForKey:@"id"]integerValue];
        
        detailInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        detailInfoButton.frame = CGRectMake(self.mainTableView.frame.size.width-32, 10, 24, 24);
        detailInfoButton.tag = mytag;
        [detailInfoButton setBackgroundImage:[UIImage imageNamed:@"Information.png"] forState:UIControlStateNormal];
        [detailInfoButton addTarget:self action:@selector(openInformation:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:detailInfoButton];

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [indicator startAnimating];
    NSString *selectedRow;
    NSDictionary *info;
    info = [json objectAtIndex:indexPath.row];
    selectedRow = [info objectForKey:@"name"];
    
    if ([selectedRow isEqualToString:@"Parks"]
        || [selectedRow isEqualToString:@"Playgrounds"]
        || [selectedRow isEqualToString:@"Historic Sites"]
        || [selectedRow isEqualToString:@"Pavilions"]) {
        searchType = @"Nearest";
        searchItem = selectedRow;
        searchTitle = selectedRow;
        [self openView];
    } else if ([selectedRow isEqualToString:@"Pathways / Trails"]) {
        searchType = @"Nearest";
        searchItem = @"TRAILHEAD";
        searchTitle = selectedRow;
        [self openView];
    } else if ([selectedRow isEqualToString:@"Amenities"]) {
        [self openMainAmenities];
    //} else if ([selectedRow isEqualToString:@"Run and Walk"]) {
    //    [self openNewRun];
    }
}
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithRed:235/255.0f green:0.0f blue:0.0f alpha:.5];
}
-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
}
-(void)openInformation:(UIButton *)btn {
    siteID = btn.tag;
    for (int i = 0; i < [json count]; i++) {
        NSDictionary *loc = [json objectAtIndex:i];
        NSInteger sid = [[loc objectForKey:@"id"]integerValue];
        if (sid == siteID) {
            NSString *title = [loc objectForKey:@"name"];
            NSString *description = [loc objectForKey:@"description"];
            [self presentViewController:[CustomAlert openMenuInformation:(NSString *)description mtitle:(NSString *)title] animated:YES completion:nil];
        }
    }
}
-(void)openNewRun {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewRunViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NewRun"];
    vc.managedObjectContext = self.managedObjectContext;
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)openMainAmenities {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainAmenitiesViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainAmenitiesView"];
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)openView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NearestResultViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NearestResultView"];
    vc.searchType = searchType;
    vc.searchItem = searchItem;
    vc.searchTitle = searchTitle;
    vc.backViewName = @"Main";
    vc.latItem = self.latItem;
    vc.lngItem = self.lngItem;
    [self presentViewController:vc animated:YES completion:nil];
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
    } else if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonRenderer *plRenderer = [[MKPolygonRenderer alloc] initWithPolygon:overlay];
        plRenderer.strokeColor = [UIColor redColor];
        plRenderer.lineWidth = 5;
        return plRenderer;
    }
    return nil;
}
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    MKCoordinateRegion region;
    region.center.latitude = newLocation.coordinate.latitude;
    region.center.longitude = newLocation.coordinate.longitude;
    region.span.latitudeDelta = 0.02f;
    region.span.longitudeDelta = 0.02f;
    
    self.latItem = newLocation.coordinate.latitude;
    self.lngItem = newLocation.coordinate.longitude;
    
    [geoCoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        locationItem = [NSString stringWithFormat:@"%@",locatedAt];
    }];
    [locationManager stopUpdatingLocation];
}
-(void)openSearch {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchView"];
    vc.backViewName = @"Main";
    [self presentViewController:vc animated:YES completion:nil];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self presentViewController:[CustomAlert lowMemoryAlert] animated:YES completion:nil];
}

@end
