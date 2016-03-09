//
//  NearestResultViewController.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 6/11/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "NearestResultViewController.h"
#import "MainViewController.h"
#import "MainAmenitiesViewController.h"
#import "SpecialEventsViewController.h"
#import "ParksViewController.h"
#import "PavilionsViewController.h"
#import "PlaygroundsViewController.h"
#import "HistoricSitesViewController.h"
#import "WebViewController.h"
#import "DrawBoundary.h"
#import "CustomZoom.h"
#import "AnimateLayer.h"
#import "GetJSON.h"
#import "Annotation.h"
#import "AmphitheaterAnnotation.h"
#import "ArcheryAnnotation.h"
#import "BlankAnnotation.h"
#import "EmptyAnnotation.h"
#import "StartAnnotation.h"
#import "EndAnnotation.h"
#import "ParksAnnotation.h"
#import "PavilionsAnnotation.h"
#import "PlaygroundsAnnotation.h"
#import "HistoricSitesAnnotation.h"
#import "BaseballFieldAnnotation.h"
#import "BasketballCourtAnnotation.h"
#import "CricketFieldAnnotation.h"
#import "DiscGolfCourseAnnotation.h"
#import "FireRingAnnotation.h"
#import "FishingAnnotation.h"
#import "HandballCourtAnnotation.h"
#import "HockeyRinkAnnotation.h"
#import "HorseshoePitAnnotation.h"
#import "MultipurposeFieldAnnotation.h"
#import "RacquetballCourtAnnotation.h"
#import "SkatespotAnnotation.h"
#import "TennisCourtAnnotation.h"
#import "VolleyballCourtAnnotation.h"
#import "TrailsAnnotation.h"
#import "RestroomsAnnotation.h"
#import "PicnicTableAnnotation.h"
#import "GrillAnnotation.h"
#import "EquestrianAnnotation.h"
#import "ProfileAnnotation.h"
#import "BuildingAnnotation.h"
#import "DogAnnotation.h"
#import "EntranceAnnotation.h"
#import "ParkingAnnotation.h"
#import "SkillsParkAnnotation.h"
#import "BocceBallAnnotation.h"
#import "ObservatoryAnnotation.h"
#import "BoatRampAnnotation.h"
#import "GazeboAnnotation.h"
#import "DrawCircle.h"
#import "DrawText.h"
#import "DrawProfile.h"
#import "DrawStartPoint.h"
#import "DrawEndPoint.h"
#import "FindNearestPoly.h"
#import "CustomAlert.h"
#import "Reachability.h"
#import "SearchViewController.h"
#import "CustomCollectionCell_H.h"
#import "AvailableMemory.h"

@interface NearestResultViewController () {
    UIView *mainView;
    UIView *infoView;
    UIView *myTableView;
    UIView *mainMapView;
    UIView *mapMenuView;
    UIView *navMenuView;
    UIView *tipView;
    UIView *DDView;
    UIView *mapToolsView;
    
    UIWebView *webView;
    
    UIImageView *profileView;
    UIScrollView *scroller;
    
    UIButton *fullMapBTN;
    UIButton *mapToolsBTN;
    UIButton *profileBTN;
    UIButton *saveLocationBTN;
    UIButton *exitBTN;
    UIButton *fullStepBTN;
    UIButton *voiceBTN;
    UIButton *locationBTN;
    UIButton *backBTN;
    UIButton *menuBTN;
    UIButton *BTN1;
    UIButton *r1BTN1;
    UIButton *r1BTN2;
    UIButton *r1BTN3;
    UIButton *r1BTN4;
    UIButton *r1BTN5;
    
    
    UISwitch *trailsSwitch;
    UISwitch *mapSwitch;
    UISwitch *amenitiesSwitch;
    UISwitch *tipSwitch;
    
    UILabel *trailsSwitchLabel;
    UILabel *mapSwitchLabel;
    UILabel *amenitiesSwitchLabel;
    UILabel *tipSwitchLabel;
    UILabel *destinationLabel;
    UILabel *distanceLabel;
    UILabel *stepsTitle;
    UILabel *appTitle;
    UILabel *appSubTitle;
    UILabel *timerLBL;
    UILabel *locationLabel;
    UILabel *titleDDLabel;
    
    
    NSString *selectedRow;
    NSString *fullMap;
    NSString *locationItem;
    NSString *imgname;
    NSString *pulldownMenu;
    NSString *mapToolsDisplay;
    NSString *mapSatelliteDisplay;
    NSString *amenitiesDisplay;
    NSString *tipDisplay;
    NSString *trailsDisplay;
    NSString *fullStep;
    NSString *originalItem;
    NSString *uLoc;
    NSString *allSteps;
    
    
    UIPageControl *pageControl;
    UIScrollView *myScrollView;
    int pageCount;
    UIImage *inImage;
    CGImageRef cgimg;

    UITextView *info_TextView;
    UITextView *stepsTextView;
    
    CLGeocoder *geoCoder;
    MKRoute *routeDetails;
    MKPolyline *trailOverlay;
    MKPointAnnotation *previousAnnotation;
    CLLocationManager *locationManager;
    
    UIActivityIndicatorView *indicator;
    
    UICollectionView *cv;
    
    int X_Line, Y_Line, x, y;
    int countdown;
    NSTimer *timer;
    //NSTimer *timer1;
    NSInteger viewTag;
    BOOL nextRegionChangeIsFromUserInteraction;
    CGFloat latUserLocation;
    CGFloat lngUserLocation;
    
    NSInteger totalLength;
    NSInteger currentLength;
    CGFloat grandTotal;
    NSString *initialCalculation;
    NSString *appenLength;
    NSString *appLen;
    NSString *lengthUnit;
    UILabel *calculatorLBL;
    UILabel *totalLBL;
    UIButton *unitBTN;
    UIImageView *postImage;
    UIButton *shareBTN;
    //UIButton *gpsBTN;
    //UILabel *memoryLabel;
}
@end

@implementation NearestResultViewController
@synthesize searchType, searchItem, feature_id, park_id, trailID, searchTitle, hasSavedLocation, latSaved, lngSaved, backViewName;

-(void)openGoogleNavigation {
    NSInteger wifiAvailable = [NearestResultViewController checkAvailableWiFi];
    NSInteger netAvailable = [NearestResultViewController checkAvailableInternet];
    if (wifiAvailable == 1) {
        [self hasNavigation];
    } else if (wifiAvailable == 0) {
        if (netAvailable == 2) {
            [self hasNavigation];
        } else if (netAvailable == 0) {
            [self presentViewController:[CustomAlert openMenuInformation:@"No access to www.google.com for driving or walking directions." mtitle:@"Access Not Available"] animated:YES completion:nil];
        }
    }
}
-(void)hasNavigation {
    double destLat = 0.0, destLng = 0.0;
    destLat = self.latSaved;
    destLng = self.lngSaved;
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps-x-callback://"]]) {
        NSString *gURL = [NSString stringWithFormat:@"comgooglemaps-x-callback://?daddr=%f,%f&center=%f,%f&directionsmode=driving&zoom=14&x-success=gov.howardcountymd.iOSHoCoParks://?resume=true&x-source=Parks", destLat, destLng,destLat, destLng];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:gURL]];
    } else {
        //NSLog(@"Can't use comgooglemaps://");
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Google Maps Not Found"
                                              message:@"Google Maps App is required for this device."
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Get Google Maps App"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
                                       [self getGoogleMapsApp];
                                   }];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action)
                                       {
                                           [alertController dismissViewControllerAnimated:YES completion:nil];
                                       }];

        [alertController addAction:actionOk];
        [alertController addAction:actionCancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
-(void)getGoogleMapsApp {
    NSURL *webURL = [NSURL URLWithString:@"https://itunes.apple.com/us/app/google-maps/id585027354?mt=8"];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:webURL];
    [webView loadRequest:requestURL];
    [webView setScalesPageToFit:YES];
}
-(void)checkSavedLocation {
    [self startLocationUpdates];
    hasSavedLocation = @"No";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.hasSavedLocation = [defaults objectForKey:@"Location"];
    
    if ([hasSavedLocation isEqualToString:@"Yes"]) {
        self.latSaved = [defaults doubleForKey:@"Latitude"];
        self.lngSaved = [defaults doubleForKey:@"Longitude"];
        [self overwriteLocation];
    } else if ([hasSavedLocation isEqualToString:@"No"]) {
        [self openSaveLocation];
    } else {
        [self openSaveLocation];
    }
}
-(void)overwriteLocation {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Saved Location Found"
                                          message:@"You can overwrite with current location OR you can navigate back to saved location."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Overwrite"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   [self saveCurrentLocation];
                               }];
    UIAlertAction *actionNavigation = [UIAlertAction actionWithTitle:@"Navigate Back"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   [self openGoogleNavigation];
                               }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action)
                                   {
                                       //[AnimateLayer animateLayerHorizontal:0 layer:saveLocationBTN];
                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                   }];
    [alertController addAction:actionOk];
    [alertController addAction:actionNavigation];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)openSaveLocation {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Save Location"
                                        message:@"You can save your current location for later navigate back to this spot."
                                        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Save Now"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   [self saveCurrentLocation];
                               }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action)
                                   {
                                       //[AnimateLayer animateLayerHorizontal:0 layer:saveLocationBTN];
                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                   }];
    [alertController addAction:actionOk];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)saveCurrentLocation {
    [AnimateLayer animateLayerHorizontal:0 layer:saveLocationBTN];
    self.latSaved = latUserLocation;
    self.lngSaved = lngUserLocation;
    
    hasSavedLocation=@"Yes";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.hasSavedLocation forKey:@"Location"];
    [defaults setDouble:self.latSaved forKey:@"Latitude"];
    [defaults setDouble:self.lngSaved forKey:@"Longitude"];
    [defaults synchronize];
    
    CLLocationCoordinate2D location;
    location.latitude = self.latSaved;
    location.longitude = self.lngSaved;
    
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance (location, 100, 100);
    
    StartAnnotation *point = [[StartAnnotation alloc] init];
    point.coordinate = region.center;
    point.title = @"Saved Location";
    point.subtitle = @"";
    [self.mapView addAnnotation:point];
    [self.mapView setCenterCoordinate:point.coordinate animated:YES];
    [self.mapView setSelectedAnnotations:[[NSArray alloc] initWithObjects:point,nil]];
    [self.mapView setRegion:region animated:NO];
}
-(void)closeStep {
    [AnimateLayer animateLayerVertical:mainView.frame.size.height layer:DDView];
    [AnimateLayer animateLayerHorizontal:(mainView.frame.size.width/6)*4-42 layer:profileBTN];
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         mainMapView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
                         self.mapView.frame = CGRectMake(0, 45, mainMapView.frame.size.width, mainMapView.frame.size.height-45);
                         mainMapView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         //[fullStepBTN setBackgroundImage:[UIImage imageNamed:@"Arrow_Out.png"] forState:UIControlStateNormal];
                     }];
}
-(void)openStep {
    [AnimateLayer animateLayerHorizontal:(mainView.frame.size.width/2)-26 layer:profileBTN];
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         mainMapView.frame = CGRectMake(0, 64, self.view.frame.size.width, (self.view.frame.size.height/2)-64);
                         self.mapView.frame = CGRectMake(0, 45, mainMapView.frame.size.width, mainMapView.frame.size.height-45);
                         DDView.frame = CGRectMake(0, (self.view.frame.size.height/2), self.view.frame.size.width, (self.view.frame.size.height/2));
                         mainMapView.alpha = 1;
                         //[AnimateLayer animateLayerVertical:mainView.frame.size.height layer:cv];
                     }
                     completion:^(BOOL finished) {
                         [fullStepBTN setBackgroundImage:[UIImage imageNamed:@"Arrow_Out.png"] forState:UIControlStateNormal];
                         fullStep = @"no";
                     }];
}
- (void)setStepSize {
    if ([fullStep isEqualToString:@"no"]) {
        fullStep = @"yes";
        [UIView animateWithDuration:1.0
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             DDView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
                             stepsTextView.frame = CGRectMake(10, 115, DDView.frame.size.width-20, DDView.frame.size.height-120);
                             scroller.frame = CGRectMake(10, 115, DDView.frame.size.width-20, DDView.frame.size.height-120);
                             mainMapView.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             [fullStepBTN setBackgroundImage:[UIImage imageNamed:@"Arrow_In.png"] forState:UIControlStateNormal];
                         }];
    } else if ([fullStep isEqualToString:@"yes"]) {
        fullStep = @"no";
        [UIView animateWithDuration:1.0
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             DDView.frame = CGRectMake(0, (self.view.frame.size.height/2), self.view.frame.size.width, (self.view.frame.size.height/2));
                             stepsTextView.frame = CGRectMake(10, 115, DDView.frame.size.width-20, DDView.frame.size.height-120);
                             scroller.frame = CGRectMake(10, 115, DDView.frame.size.width-20, DDView.frame.size.height-120);
                             mainMapView.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             [fullStepBTN setBackgroundImage:[UIImage imageNamed:@"Arrow_Out.png"] forState:UIControlStateNormal];
                         }];
    }
    //[AnimateLayer animateLayerVertical:mainView.frame.size.height layer:cv];
}
- (void)setMapSize {
    backBTN.hidden = NO;
    menuBTN.hidden = NO;
    appSubTitle.hidden = NO;
    appTitle.hidden = NO;
    if ([fullMap isEqualToString:@"no"]) {
        fullMap = @"yes";
        if ([pulldownMenu isEqualToString:@"YES"]) {
            [self getMenu];
        }
        
        [UIView animateWithDuration:1.0
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{

                             if (routeDetails!=nil) {
                                 mainMapView.frame = CGRectMake(0, 64, self.view.frame.size.width, (self.view.frame.size.height/2)-114);
                                 self.mapView.frame = CGRectMake(0, 45, mainMapView.frame.size.width, mainMapView.frame.size.height-45);
                                DDView.frame = CGRectMake(0, (self.view.frame.size.height/2), self.view.frame.size.width, (self.view.frame.size.height/2));
                             } else {
                                 mainMapView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-114);
                                 self.mapView.frame = CGRectMake(0, 45, mainMapView.frame.size.width, mainMapView.frame.size.height-45);
                             }
                             myTableView.alpha = 1;
                             self.titleImage.alpha = 0;
                             [AnimateLayer animateLayerVertical:mainView.frame.size.height-50 layer:cv];
                         }
                         completion:^(BOOL finished) {
                             [fullMapBTN setBackgroundImage:[UIImage imageNamed:@"Arrow_In.png"] forState:UIControlStateNormal];
                         }];
    } else if ([fullMap isEqualToString:@"yes"]) {
        fullMap = @"no";
        [UIView animateWithDuration:1.0
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             mainMapView.frame = CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height-170);
                             self.mapView.frame = CGRectMake(0, 45, mainMapView.frame.size.width, (mainMapView.frame.size.height-45));
                             myTableView.alpha = 1;
                             self.titleImage.alpha = 1;
                             [AnimateLayer animateLayerVertical:mainView.frame.size.height layer:cv];
                         }
                         completion:^(BOOL finished) {
                             [fullMapBTN setBackgroundImage:[UIImage imageNamed:@"Arrow_Out.png"] forState:UIControlStateNormal];
                             [AnimateLayer animateLayerVertical:mainView.frame.size.height layer:DDView];
                         }];
    }
}
- (void)swipe:(UISwipeGestureRecognizer *)swipeRecogniser {
    if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionRight) {
        pageControl.currentPage -=1;
    } else if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionLeft) {
        pageControl.currentPage +=1;
    }
    [self pageTurn:pageControl];
}
-(void) initPageTurn {
    [self pageTurn:pageControl];
}
- (void) pageTurn: (UIPageControl *) aPageControl {
    //gpsBTN.hidden = NO;
    [indicator stopAnimating];
    NSInteger whichPage = aPageControl.currentPage;
    if (aPageControl.currentPage == 0) {
        if (!([CLLocationManager locationServicesEnabled])
            || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
            ) {
            uLoc = @"ON";
            //[gpsBTN setTitle:@"Location Service is off" forState:UIControlStateNormal];
        } else {
            //[gpsBTN setTitle:@"Location Service is on" forState:UIControlStateNormal];
            [self startLocationUpdates];
        }
        searchItem = originalItem;
        appSubTitle.text = @"Nearest";
        appTitle.text = searchTitle;
        searchType = @"Nearest";
        [AnimateLayer animateLayerHorizontal:-(self.view.frame.size.width) layer:infoView];
        [AnimateLayer animateLayerHorizontal:-(self.view.frame.size.width) layer:mainMapView];
        [AnimateLayer animateLayerHorizontal:0 layer:myTableView];
        [AnimateLayer animateLayerVertical:170 layer:myTableView];
        [self.parks removeAllObjects];
        self.parks = [GetJSON getNearest:searchType searchItem:searchItem mv:self.mapView];
        [self.mainTableView reloadData];
    } else if (aPageControl.currentPage == 1) {
        if (!([CLLocationManager locationServicesEnabled])
            || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
            ) {
            uLoc = @"ON";
            //[gpsBTN setTitle:@"Location Service is off" forState:UIControlStateNormal];
        } else {
            //[gpsBTN setTitle:@"Location Service is on" forState:UIControlStateNormal];
            [self startLocationUpdates];
        }
        searchItem = originalItem;
        appSubTitle.text = @"Alphabetical";
        appTitle.text = searchTitle;
        searchType = @"All";
        [AnimateLayer animateLayerHorizontal:-(self.view.frame.size.width) layer:infoView];
        [AnimateLayer animateLayerHorizontal:-(self.view.frame.size.width) layer:mainMapView];
        [AnimateLayer animateLayerHorizontal:0 layer:myTableView];
        [AnimateLayer animateLayerVertical:170 layer:myTableView];
        [self.parks removeAllObjects];
        self.parks = [GetJSON getNearest:(NSString *)searchType searchItem:(NSString *)searchItem mv:self.mapView];
        [self.mainTableView reloadData];
    } else if (aPageControl.currentPage == 2) {
        appSubTitle.text = @"Map";
        appTitle.text = searchTitle;
        searchItem = originalItem;
        [locationManager stopUpdatingLocation];
        [AnimateLayer animateLayerHorizontal:-(self.view.frame.size.width) layer:infoView];
        [AnimateLayer animateLayerHorizontal:-(self.view.frame.size.width) layer:myTableView];
        [AnimateLayer animateLayerHorizontal:0 layer:mainMapView];
        [AnimateLayer animateLayerVertical:170 layer:myTableView];
        if (routeDetails) {
            [self.mapView removeOverlay:routeDetails.polyline];
            routeDetails=nil;
        }
        [self checkMapSetting];
        [self chkSatellite];
        [CustomZoom zoomToFitPoly:self.mapView poly:@"Howard County"];
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    myScrollView.contentOffset = CGPointMake(self.view.frame.size.width * whichPage, 0.0f);
    [UIView commitAnimations];
}
- (void)checkMapSetting {
    if([amenitiesDisplay isEqualToString:@"ON"]) {
        [self removeAllAnnotations];
        [self.amenities removeAllObjects];
        searchItem = @"Amenities";
        self.amenities = [GetJSON getAllFeature:self.mapView];
        [self setPin];
    } else if([amenitiesDisplay isEqualToString:@"OFF"]) {
        [self removeAllAnnotations];
        searchItem = originalItem;
        [self.parks removeAllObjects];
        self.parks = [GetJSON getNearest:searchType searchItem:searchItem mv:self.mapView];
        [self setPin];
    }
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    searchType = @"All";
    fullMap = @"no";
    viewTag = 1;
    pulldownMenu = @"NO";
    mapToolsDisplay = @"OFF";
    fullStep = @"no";
    uLoc = @"OFF";
    originalItem = searchItem;
    initialCalculation = @"YES";
    lengthUnit = @"F";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    mapSatelliteDisplay = [defaults objectForKey:@"satellite"];
    if ([mapSatelliteDisplay isEqualToString:@"ON"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"ON" forKey:@"satellite"];
        [defaults synchronize];
    } else if ([mapSatelliteDisplay isEqualToString:@"OFF"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"OFF" forKey:@"satellite"];
        [defaults synchronize];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"OFF" forKey:@"satellite"];
        [defaults synchronize];
        mapSatelliteDisplay = @"OFF";
    }
    
    tipDisplay = [defaults objectForKey:@"tips"];
    if ([tipDisplay isEqualToString:@"ON"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"ON" forKey:@"tips"];
        [defaults synchronize];
    } else if ([tipDisplay isEqualToString:@"OFF"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"OFF" forKey:@"tips"];
        [defaults synchronize];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"ON" forKey:@"tips"];
        [defaults synchronize];
        tipDisplay = @"ON";
    }
    
    trailsDisplay = [defaults objectForKey:@"trails"];
    if ([trailsDisplay isEqualToString:@"ON"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"ON" forKey:@"trails"];
        [defaults synchronize];
    } else if ([trailsDisplay isEqualToString:@"OFF"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"OFF" forKey:@"trails"];
        [defaults synchronize];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"ON" forKey:@"trails"];
        [defaults synchronize];
        trailsDisplay = @"ON";
    }
    
    amenitiesDisplay = [defaults objectForKey:@"amenities"];
    if ([amenitiesDisplay isEqualToString:@"ON"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"ON" forKey:@"amenities"];
        [defaults synchronize];
    } else if ([amenitiesDisplay isEqualToString:@"OFF"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"OFF" forKey:@"amenities"];
        [defaults synchronize];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"ON" forKey:@"amenities"];
        [defaults synchronize];
        amenitiesDisplay = @"ON";
    }
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    mainView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:mainView];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, mainView.frame.size.width, mainView.frame.size.height)];
    webView.backgroundColor = [UIColor blackColor];
    webView.autoresizesSubviews = YES;
    webView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    webView.scalesPageToFit=YES;
    [mainView addSubview:webView];
    
    if ([searchItem isEqualToString:@"Parks"]) {
        inImage = [UIImage imageNamed:@"Centennial Park.jpg"];
    } else if ([searchItem isEqualToString:@"Playgrounds"]) {
        inImage = [UIImage imageNamed:@"CVH.jpg"];
    } else if ([searchItem isEqualToString:@"Pavilions"]) {
        inImage = [UIImage imageNamed:@"P004.jpg"];
    } else if ([searchItem isEqualToString:@"Historic Sites"]) {
        inImage = [UIImage imageNamed:@"Waverly Mansion.jpg"];
    } else {
        inImage = [UIImage imageNamed:@"David Force Natural Resource Area & Community Park.jpg"];
    }
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    
    CIImage *inputImage0 = [CIImage imageWithCGImage:[[UIImage imageNamed:@"NearestParksBG.jpeg"] CGImage]];
    [gaussianBlurFilter setValue:inputImage0 forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@30 forKey:kCIInputRadiusKey];
    
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    cgimg = [context createCGImage:outputImage fromRect:[inputImage0 extent]];
    
    self.titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, 170)];
    self.titleImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.titleImage.image = inImage;
    self.titleImage.alpha = 1;
    [mainView addSubview:self.titleImage];

    /*
    memoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 135, mainView.frame.size.width-20, 20)];
    memoryLabel.text = @"";
    memoryLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:14];
    memoryLabel.backgroundColor = [UIColor clearColor];
    memoryLabel.textColor = [UIColor whiteColor];
    memoryLabel.textAlignment = NSTextAlignmentCenter;
    memoryLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mainView addSubview:memoryLabel];
    */
    
    UIImageView *tableImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height-170)];
    tableImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    tableImage.image = [UIImage imageWithCGImage:cgimg];
    tableImage.alpha = 1;
    [mainView addSubview:tableImage];

    myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 170)];
    myScrollView.backgroundColor = [UIColor clearColor];
    myScrollView.contentSize = CGSizeMake(self.view.frame.size.width,170);
    myScrollView.scrollEnabled=FALSE;
    myScrollView.pagingEnabled=TRUE;
    myScrollView.delegate=self;
    [mainView addSubview:myScrollView];
    /*
    gpsBTN = [[UIButton alloc] initWithFrame:CGRectMake(0, 64, mainView.frame.size.width, 25)];
    [gpsBTN addTarget:self action:@selector(callSetting) forControlEvents:UIControlEventTouchUpInside];
    gpsBTN.backgroundColor = [UIColor colorWithRed:195/255.0f green:195/255.0f blue:195/255.0f alpha:0.5f];
    gpsBTN.titleLabel.font = [UIFont systemFontOfSize:16];
    gpsBTN.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    gpsBTN.hidden = YES;
    [mainView addSubview:gpsBTN];
    */
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    leftSwipeGestureRecognizer.numberOfTouchesRequired = 1;
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipeGestureRecognizer.delegate = self;
    [myScrollView addGestureRecognizer:leftSwipeGestureRecognizer];
    
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    rightSwipeGestureRecognizer.numberOfTouchesRequired = 1;
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipeGestureRecognizer.delegate = self;
    [myScrollView addGestureRecognizer:rightSwipeGestureRecognizer];
    
    pageCount = 3;
    
    pageControl = [[UIPageControl alloc] init];
    pageControl.frame = CGRectMake(0, 150, self.view.frame.size.width, 20);
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.numberOfPages = pageCount;
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.transform = CGAffineTransformMakeScale(1.25, 1.25);
    pageControl.currentPage = 0;
    [pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    [mainView addSubview:pageControl];
    
    mainMapView = [[UIView alloc] initWithFrame:CGRectMake(-(self.view.frame.size.width), 170, self.view.frame.size.width, self.view.frame.size.height-170)];
    mainMapView.backgroundColor = [UIColor clearColor];
    [mainView addSubview:mainMapView];
    
    self.mapView= [[MKMapView alloc] initWithFrame:CGRectMake(0, 45, mainMapView.frame.size.width, mainMapView.frame.size.height-45)];
    self.mapView.tag = 0;
    [mainMapView addSubview:self.mapView];
    
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    self.mapView.delegate = self;
    self.mapView.userInteractionEnabled = YES;
    self.mapView.showsUserLocation = YES;
    
    MKCoordinateRegion region = {{0.0, 0.0},{0.0, 0.0}};
    region.center.latitude = locationManager.location.coordinate.latitude;
    region.center.longitude = locationManager.location.coordinate.longitude;
    region.span.latitudeDelta = 0.0005f;
    region.span.longitudeDelta = 0.0005f;
    [self.mapView setRegion:region animated:YES];
    
    [self.mapView setShowsPointsOfInterest:NO];
    
    appSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, self.view.frame.size.width-100, 15)];
    appSubTitle.text = @"";
    appSubTitle.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:15];
    appSubTitle.backgroundColor = [UIColor clearColor];
    appSubTitle.textColor = [UIColor whiteColor];
    appSubTitle.alpha = 1.0;
    appSubTitle.textAlignment = NSTextAlignmentCenter;
    appSubTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:appSubTitle];
    
    appTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 38, self.view.frame.size.width-100, 24)];
    appTitle.text = @"";
    appTitle.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    appTitle.backgroundColor = [UIColor clearColor];
    appTitle.textColor = [UIColor whiteColor];
    appTitle.alpha = 1.0;
    appTitle.textAlignment = NSTextAlignmentCenter;
    appTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:appTitle];
    
    mapMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainMapView.frame.size.width, 45)];
    mapMenuView.backgroundColor = [UIColor blackColor];
    mapMenuView.alpha = 0.8;
    mapMenuView.tag = 1;
    [mainMapView addSubview:mapMenuView];
    
    mapToolsView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, mainMapView.frame.size.width, 0)];
    mapToolsView.backgroundColor = [UIColor blackColor];
    mapToolsView.alpha = 0.8;
    [mainMapView addSubview:mapToolsView];
    
    fullMapBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    fullMapBTN.frame = CGRectMake(mainMapView.frame.size.width-50, 2, 40, 40);
    [fullMapBTN setBackgroundImage:[UIImage imageNamed:@"Arrow_Out.png"] forState:UIControlStateNormal];
    [fullMapBTN addTarget:self action:@selector(setMapSize) forControlEvents:UIControlEventTouchUpInside];
    [mapMenuView addSubview:fullMapBTN];
    
    profileBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    profileBTN.frame = CGRectMake((mainMapView.frame.size.width/2)-26, -5, 52, 52);
    [profileBTN setBackgroundImage:[UIImage imageNamed:@"LineChart.png"] forState:UIControlStateNormal];
    [profileBTN addTarget:self action:@selector(openStep) forControlEvents:UIControlEventTouchUpInside];
    [mapMenuView addSubview:profileBTN];
    
    shareBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBTN.frame = CGRectMake((mainMapView.frame.size.width/6)*5-38, 5, 21, 28);
    [shareBTN setBackgroundImage:[UIImage imageNamed:@"702-share.png"] forState:UIControlStateNormal];
    [shareBTN addTarget:self action:@selector(shareThis) forControlEvents:UIControlEventTouchUpInside];
    [mapMenuView addSubview:shareBTN];
    
    mapToolsBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    mapToolsBTN.frame = CGRectMake((mainMapView.frame.size.width/2)-26, -5, 52, 52);
    [mapToolsBTN setBackgroundImage:[UIImage imageNamed:@"MapTools.png"] forState:UIControlStateNormal];
    [mapToolsBTN addTarget:self action:@selector(createMapTools) forControlEvents:UIControlEventTouchUpInside];
    [mapMenuView addSubview:mapToolsBTN];
    
    saveLocationBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    saveLocationBTN.frame = CGRectMake(0, -5, 53, 53);
    [saveLocationBTN setBackgroundImage:[UIImage imageNamed:@"UserSavedLocation.png"] forState:UIControlStateNormal];
    [saveLocationBTN addTarget:self action:@selector(checkSavedLocation) forControlEvents:UIControlEventTouchUpInside];
    [mapMenuView addSubview:saveLocationBTN];
    
    locationBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBTN.frame = CGRectMake(0, -5, 53, 53);
    [locationBTN setBackgroundImage:[UIImage imageNamed:@"CurrentLocation.png"] forState:UIControlStateNormal];
    [locationBTN addTarget:self action:@selector(getCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    [mapMenuView addSubview:locationBTN];
    
    locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 80, 30)];
    locationLabel.text = @"Locate Me\nis off";
    locationLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:12];
    locationLabel.backgroundColor = [UIColor clearColor];
    locationLabel.textColor = [UIColor whiteColor];
    locationLabel.alpha = 1.0;
    locationLabel.textAlignment = NSTextAlignmentLeft;
    locationLabel.numberOfLines = 2;
    locationLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [mapMenuView addSubview:locationLabel];
    
    myTableView = [[UIView alloc] initWithFrame:CGRectMake(-(self.view.frame.size.width), 170, self.view.frame.size.width, self.view.frame.size.height-170)];
    myTableView.backgroundColor = [UIColor clearColor];
    [mainView addSubview:myTableView];
    
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, myTableView.frame.size.width, myTableView.frame.size.height) style:UITableViewStylePlain];
    self.mainTableView.dataSource = self;
    self.mainTableView.delegate = self;
    self.mainTableView.backgroundColor = [UIColor clearColor];
    self.mainTableView.alpha = 1.0;
    [myTableView addSubview:self.mainTableView];
  
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(tapGestureHandler:)];
    tgr.delegate = self;
    [self.mapView addGestureRecognizer:tgr];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(tapGestureHandler:)];
    lpgr.minimumPressDuration = 2.0;  //user must press for 2 seconds
    [self.mapView addGestureRecognizer:lpgr];

    //[self addTilesOverlay];

    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(50, 50);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing=5.0;
    layout.minimumInteritemSpacing=5.0;
    cv=[[UICollectionView alloc]
        initWithFrame:CGRectMake(0, mainView.frame.size.height, mainView.frame.size.width, 50)
        collectionViewLayout:layout];
    [cv registerClass:[CustomCollectionCell_H class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [cv setDataSource:self];
    [cv setDelegate:self];
    [cv setBackgroundColor:[UIColor blackColor]];
    [mainView addSubview:cv];
    
    DDView = [[UIView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height, self.view.frame.size.width, (self.view.frame.size.height/2)-20)];
    DDView.backgroundColor = [UIColor blackColor];
    DDView.alpha = 1.0;
    [mainView addSubview:DDView];
    
    titleDDLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, self.view.frame.size.width-20, 20)];
    titleDDLabel.text = @"Driving Direction";
    titleDDLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
    titleDDLabel.backgroundColor = [UIColor clearColor];
    titleDDLabel.textColor = [UIColor whiteColor];
    titleDDLabel.alpha = 1.0;
    titleDDLabel.textAlignment = NSTextAlignmentLeft;
    titleDDLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [DDView addSubview:titleDDLabel];
    
    destinationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, self.view.frame.size.width-20, 20)];
    destinationLabel.text = @"";
    destinationLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:13];
    destinationLabel.backgroundColor = [UIColor clearColor];
    destinationLabel.textColor = [UIColor whiteColor];
    destinationLabel.alpha = 1.0;
    destinationLabel.textAlignment = NSTextAlignmentLeft;
    destinationLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [DDView addSubview:destinationLabel];
    
    distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, self.view.frame.size.width-20, 20)];
    distanceLabel.text = @"";
    distanceLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:13];
    distanceLabel.backgroundColor = [UIColor clearColor];
    distanceLabel.textColor = [UIColor whiteColor];
    distanceLabel.alpha = 1.0;
    distanceLabel.textAlignment = NSTextAlignmentLeft;
    distanceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [DDView addSubview:distanceLabel];
    
    stepsTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 90, self.view.frame.size.width-20, 20)];
    stepsTitle.text = @"";
    stepsTitle.font = [UIFont fontWithName:@"TrebuchetMS" size:13];
    stepsTitle.backgroundColor = [UIColor clearColor];
    stepsTitle.textColor = [UIColor whiteColor];
    stepsTitle.alpha = 1.0;
    stepsTitle.textAlignment = NSTextAlignmentLeft;
    stepsTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [DDView addSubview:stepsTitle];
    
    stepsTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 115, DDView.frame.size.width-20, DDView.frame.size.height-120)];
    stepsTextView.text = @"";
    stepsTextView.font = [UIFont fontWithName:@"TrebuchetMS" size:16];
    stepsTextView.backgroundColor = [UIColor darkGrayColor];
    stepsTextView.textColor = [UIColor whiteColor];
    stepsTextView.textAlignment = NSTextAlignmentLeft;
    stepsTextView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    stepsTextView.editable=FALSE;
    stepsTextView.alpha = 1.0;
    [DDView addSubview:stepsTextView];
    
    voiceBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceBTN.frame = CGRectMake(DDView.frame.size.width-120, 2, 40, 40);
    [voiceBTN setBackgroundImage:[UIImage imageNamed:@"Voice.png"] forState:UIControlStateNormal];
    [voiceBTN addTarget:self action:@selector(showMapItem) forControlEvents:UIControlEventTouchUpInside];
    voiceBTN.alpha = 0;
    [DDView addSubview:voiceBTN];
    
    fullStepBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    fullStepBTN.frame = CGRectMake(DDView.frame.size.width-85, 2, 40, 40);
    [fullStepBTN setBackgroundImage:[UIImage imageNamed:@"Arrow_Out.png"] forState:UIControlStateNormal];
    [fullStepBTN addTarget:self action:@selector(setStepSize) forControlEvents:UIControlEventTouchUpInside];
    [DDView addSubview:fullStepBTN];
    
    exitBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    exitBTN.frame = CGRectMake(DDView.frame.size.width-50, 2, 40, 40);
    [exitBTN setBackgroundImage:[UIImage imageNamed:@"Exit.png"] forState:UIControlStateNormal];
    [exitBTN addTarget:self action:@selector(closeStep) forControlEvents:UIControlEventTouchUpInside];
    [DDView addSubview:exitBTN];
    
    scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 115, DDView.frame.size.width-20, DDView.frame.size.height-120)];
    scroller.backgroundColor = [UIColor darkGrayColor];
    scroller.scrollEnabled=TRUE;
    scroller.pagingEnabled=TRUE;
    scroller.alpha = 0;
    scroller.delegate=self;
    [DDView addSubview:scroller];
    
    navMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, 64)];
    navMenuView.backgroundColor = [UIColor blackColor];
    navMenuView.alpha = 0.5;
    navMenuView.tag = 1;
    [mainView addSubview:navMenuView];
    
    infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height-170)];
    infoView.backgroundColor = [UIColor clearColor];
    [mainView addSubview:infoView];
    
    info_TextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, infoView.frame.size.width-20, infoView.frame.size.height-20)];
    info_TextView.text = @"";
    info_TextView.font = [UIFont fontWithName:@"TrebuchetMS" size:18];
    info_TextView.backgroundColor = [UIColor clearColor];
    info_TextView.textColor = [UIColor whiteColor];
    info_TextView.textAlignment = NSTextAlignmentLeft;
    info_TextView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    info_TextView.editable=FALSE;
    [infoView addSubview:info_TextView];
    
    backBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    backBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    backBTN.frame = CGRectMake(8, 25, 44, 44);
    [backBTN setBackgroundImage:[UIImage imageNamed:@"Arrow_Left.png"] forState:UIControlStateNormal];
    [backBTN addTarget:self action:@selector(back_Click) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:backBTN];
    
    menuBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBTN.frame = CGRectMake(self.view.frame.size.width-58, 32, 44, 44);
    [menuBTN setBackgroundImage:[UIImage imageNamed:@"List_White.png"] forState:UIControlStateNormal];
    [menuBTN addTarget:self action:@selector(getMenu) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:menuBTN];
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    indicator.transform = CGAffineTransformMakeScale(2, 2);
    indicator.backgroundColor = [UIColor clearColor];
    [self.view addSubview:indicator];
    
    tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    tipView.backgroundColor = [UIColor blackColor];
    tipView.alpha = 1.0;
    tipView.tag = 1;
    [self.view addSubview:tipView];
    
    [self.mapView addOverlay:[DrawBoundary buildLine:@"Howard County"]];
    [indicator startAnimating];
    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(initPageTurn) userInfo:nil repeats:NO];
    
    //timer1 = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkMemory) userInfo:nil repeats:YES];
    
    [self openCategory];
}
#pragma mark
//- (void)checkMemory {
//    memoryLabel.text = [NSString stringWithFormat:@"Free Memory: %.0f MB", [[UIDevice currentDevice] availableMemory]];
//}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.parks removeAllObjects];
    [self.mapView removeFromSuperview];
    self.mapView = nil;
}
- (void)appDidBecomeActive:(NSNotification *)notification {
    //[self checkSetting];
}
/*
- (void)checkSetting {
    if (!([CLLocationManager locationServicesEnabled])
        || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        ) {
        uLoc = @"ON";
        [gpsBTN setTitle:@"Location Service is off" forState:UIControlStateNormal];
        locationBTN.hidden = YES;
        locationLabel.hidden = YES;
        saveLocationBTN.hidden = YES;
    } else {
        uLoc = @"OFF";
        [gpsBTN setTitle:@"Location Service is on" forState:UIControlStateNormal];
        locationBTN.hidden = NO;
        locationLabel.hidden = NO;
        saveLocationBTN.hidden = NO;
    }
    if (pageControl.currentPage != 2) {
        [self pageTurn:pageControl];
    }
}
*/
- (void)recreateMap {
    CGRect mapFrame = self.mapView.bounds;
    [self.mapView removeFromSuperview];
    
    self.mapView= [[MKMapView alloc] initWithFrame:CGRectMake(0, 45, mapFrame.size.width, mapFrame.size.height)];
    self.mapView.tag = 0;
    [mainMapView addSubview:self.mapView];
    
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    self.mapView.delegate = self;
    self.mapView.userInteractionEnabled = YES;
    self.mapView.showsUserLocation = NO;
    
    MKCoordinateRegion region = {{0.0, 0.0},{0.0, 0.0}};
    region.center.latitude = locationManager.location.coordinate.latitude;
    region.center.longitude = locationManager.location.coordinate.longitude;
    region.span.latitudeDelta = 0.0005f;
    region.span.longitudeDelta = 0.0005f;
    [self.mapView setRegion:region animated:YES];
    [self.mapView setShowsPointsOfInterest:NO];
    
    [self addTilesOverlay];
    
    [self.mapView addOverlay:[DrawBoundary buildLine:@"Howard County"]];
    [self pageTurn:pageControl];
}
-(void)openCategory {
    
    NSError *error;
    NSError *jsonError = nil;
    
    NSString *jsonFilePath = [[NSBundle mainBundle] pathForResource:[@"dataCategory" stringByReplacingOccurrencesOfString:@" / " withString:@" "] ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath options:kNilOptions error:&jsonError ];
    self.cells = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cells.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *info;
    info = [self.cells objectAtIndex:indexPath.row];
    
    CustomCollectionCell_H *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    cell.customImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_1.png", [info objectForKey:@"type"]]];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(50, 50);
}
- (void)collectionView:(UICollectionView *)colView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithRed:235/255.0f green:0.0f blue:0.0f alpha:.5];
}
- (void)collectionView:(UICollectionView *)colView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info;
    info = [self.cells objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NearestResultViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NearestResultView"];
    vc.searchType = @"Nearest";
    vc.searchItem = [info objectForKey:@"type"];
    vc.searchTitle = [NSString stringWithFormat:@"%@%@", [info objectForKey:@"name_1"],[info objectForKey:@"name_2"]];
    vc.backViewName = @"Main";
    vc.latItem = self.latItem;
    vc.lngItem = self.lngItem;
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)createMapTools {
    if([mapToolsDisplay isEqualToString:@"OFF"]) {
        mapToolsDisplay = @"ON";
        [UIView animateWithDuration:1.0
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             mapToolsView.frame = CGRectMake(0, 45, mainMapView.frame.size.width, 160);
                         }
                         completion:^(BOOL finished) {
                             mapSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 150, 32)];
                             mapSwitchLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:16];
                             mapSwitchLabel.backgroundColor = [UIColor blackColor];
                             mapSwitchLabel.textColor = [UIColor whiteColor];
                             mapSwitchLabel.text = @"Satellite";
                             mapSwitchLabel.alpha = 1.0;
                             mapSwitchLabel.textAlignment = NSTextAlignmentLeft;
                             mapSwitchLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                             [mapToolsView addSubview:mapSwitchLabel];
                             
                             mapSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(10, 10, 0, 0)];
                             [mapSwitch addTarget:self action:@selector(changeMap:) forControlEvents:UIControlEventValueChanged];
                             mapSwitch.transform = CGAffineTransformMakeScale(0.6, 0.6);
                             [mapSwitch setTintColor:[UIColor blackColor]];
                             [mapSwitch setBackgroundColor:[UIColor blackColor]];
                             [mapToolsView addSubview:mapSwitch];
                             if ([mapSatelliteDisplay isEqualToString:@"ON"]) {
                                 [mapSwitch setOn:YES animated:YES];
                             } else if ([mapSatelliteDisplay isEqualToString:@"OFF"]) {
                                 [mapSwitch setOn:NO animated:YES];
                             }
                             
                             trailsSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 45, 150, 32)];
                             trailsSwitchLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:16];
                             trailsSwitchLabel.backgroundColor = [UIColor blackColor];
                             trailsSwitchLabel.textColor = [UIColor whiteColor];
                             trailsSwitchLabel.text = @"Trails Selectable";
                             trailsSwitchLabel.alpha = 1.0;
                             trailsSwitchLabel.textAlignment = NSTextAlignmentLeft;
                             trailsSwitchLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                             [mapToolsView addSubview:trailsSwitchLabel];
                             
                             trailsSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(10, 45, 0, 0)];
                             [trailsSwitch addTarget:self action:@selector(changeTrails:) forControlEvents:UIControlEventValueChanged];
                             trailsSwitch.transform = CGAffineTransformMakeScale(0.6, 0.6);
                             [trailsSwitch setTintColor:[UIColor blackColor]];
                             [trailsSwitch setBackgroundColor:[UIColor blackColor]];
                             [mapToolsView addSubview:trailsSwitch];
                             if ([trailsDisplay isEqualToString:@"ON"]) {
                                 [trailsSwitch setOn:YES animated:YES];
                             } else if ([trailsDisplay isEqualToString:@"OFF"]) {
                                 [trailsSwitch setOn:NO animated:YES];
                             }
                             
                             amenitiesSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 80, 150, 32)];
                             amenitiesSwitchLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:16];
                             amenitiesSwitchLabel.backgroundColor = [UIColor blackColor];
                             amenitiesSwitchLabel.textColor = [UIColor whiteColor];
                             amenitiesSwitchLabel.text = @"Amenities";
                             amenitiesSwitchLabel.alpha = 1.0;
                             amenitiesSwitchLabel.textAlignment = NSTextAlignmentLeft;
                             amenitiesSwitchLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                             [mapToolsView addSubview:amenitiesSwitchLabel];
                             
                             amenitiesSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(10, 80, 0, 0)];
                             [amenitiesSwitch addTarget:self action:@selector(changeAmenities:) forControlEvents:UIControlEventValueChanged];
                             amenitiesSwitch.transform = CGAffineTransformMakeScale(0.6, 0.6);
                             [amenitiesSwitch setTintColor:[UIColor blackColor]];
                             [amenitiesSwitch setBackgroundColor:[UIColor blackColor]];
                             [mapToolsView addSubview:amenitiesSwitch];
                             if ([amenitiesDisplay isEqualToString:@"ON"]) {
                                 [amenitiesSwitch setOn:YES animated:YES];
                             } else if ([amenitiesDisplay isEqualToString:@"OFF"]) {
                                 [amenitiesSwitch setOn:NO animated:YES];
                             }
                             
                             tipSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 115, 150, 32)];
                             tipSwitchLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:16];
                             tipSwitchLabel.backgroundColor = [UIColor blackColor];
                             tipSwitchLabel.textColor = [UIColor whiteColor];
                             tipSwitchLabel.text = @"Tips";
                             tipSwitchLabel.alpha = 1.0;
                             tipSwitchLabel.textAlignment = NSTextAlignmentLeft;
                             tipSwitchLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                             [mapToolsView addSubview:tipSwitchLabel];
                             
                             tipSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(10, 115, 0, 0)];
                             [tipSwitch addTarget:self action:@selector(changeTip:) forControlEvents:UIControlEventValueChanged];
                             tipSwitch.transform = CGAffineTransformMakeScale(0.6, 0.6);
                             [tipSwitch setTintColor:[UIColor blackColor]];
                             [tipSwitch setBackgroundColor:[UIColor blackColor]];
                             [mapToolsView addSubview:tipSwitch];
                             if ([tipDisplay isEqualToString:@"ON"]) {
                                 [tipSwitch setOn:YES animated:YES];
                             } else if ([tipDisplay isEqualToString:@"OFF"]) {
                                 [tipSwitch setOn:NO animated:YES];
                             }
                         }];
    } else if([mapToolsDisplay isEqualToString:@"ON"]) {
        mapToolsDisplay = @"OFF";
        [UIView animateWithDuration:1.0
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             for(UIView *subview in [mapToolsView subviews]) {
                                 [subview removeFromSuperview];
                             }
                         }
                         completion:^(BOOL finished) {
                                  mapToolsView.frame = CGRectMake(0, 45, mainMapView.frame.size.width, 0);
                         }];
    }
}
-(void)addTilesOverlay {
    if(self.tileOverlay) {
        [self.mapView removeOverlay:self.tileOverlay];
        self.tileOverlay = nil;
    }
    NSString *tileDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Tiles"];
    NSURL *tileDirectoryURL = [NSURL fileURLWithPath:tileDirectory isDirectory:YES];
    NSString *tileTemplate = [NSString stringWithFormat:@"%@{z}/{x}/{y}.png", tileDirectoryURL];
    self.tileOverlay = [[MKTileOverlay alloc] initWithURLTemplate:tileTemplate];
    self.tileOverlay.geometryFlipped = YES;
    [self.mapView addOverlay:self.tileOverlay level:MKOverlayLevelAboveRoads];
}
- (void)removeTapCircle {
    for (int i = 2; i < viewTag; i++) {
        for(UIView *subview in [self.mapView subviews]) {
            if([subview isKindOfClass:[UIView class]]) {
                if(subview.tag==i) {
                    [subview removeFromSuperview];
                }
            }
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.mapView];
    self.drawCircle = [[DrawCircle alloc]initWithFrame:CGRectMake(location.x-40, location.y-40, 80.0, 80.0)];
    viewTag = viewTag + 1;
    self.drawCircle.tag = viewTag;
    self.drawCircle.backgroundColor = [UIColor clearColor];
    [self.mapView addSubview:self.drawCircle];
    
    [self.drawCircle fadeOut];
    [indicator startAnimating];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [indicator stopAnimating];
    [self removeTapCircle];
}

- (void)mapView:(MKMapView *)mView regionWillChangeAnimated:(BOOL)animated {
    UIView* view = self.mapView.subviews.firstObject;
    [indicator stopAnimating];
    //	Look through gesture recognizers to determine
    //	whether this region change is from user interaction
    for(UIGestureRecognizer* recognizer in view.gestureRecognizers) {
        //	The user caused of this...
        if(recognizer.state == UIGestureRecognizerStateBegan
           || recognizer.state == UIGestureRecognizerStateEnded) {
            nextRegionChangeIsFromUserInteraction = YES;
            break;
            
        }
    }
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (nextRegionChangeIsFromUserInteraction==YES) {
        nextRegionChangeIsFromUserInteraction = NO;
        [self removeTapCircle];
        self.drawCircle.alpha = 0;
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
#define MAX_DISTANCE_PX 22.0f
- (void)tapGestureHandler:(UITapGestureRecognizer *)tgr {
    
    CGPoint location = [tgr locationInView:self.mapView];
    
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:location toCoordinateFromView:self.mapView];
    //NSLog(@"Tap: Coordinate = %f,%f",touchMapCoordinate.latitude, touchMapCoordinate.longitude);
    
    if ([mapSatelliteDisplay isEqualToString:@"OFF"]) {
        if ([trailsDisplay isEqualToString:@"OFF"]) {
            [indicator stopAnimating];
            [self postTipMessage:@"To get trail or path elevation, please make trail or path selectable." type:(NSString*)@"setting"];
        } else if ([trailsDisplay isEqualToString:@"ON"]) {
            NSInteger wifiAvailable = [NearestResultViewController checkAvailableWiFi];
            NSInteger netAvailable = [NearestResultViewController checkAvailableInternet];
            if (wifiAvailable == 1) {
                [self hasProfile:(CGFloat)touchMapCoordinate.latitude lng:(CGFloat)touchMapCoordinate.longitude];
            } else if (wifiAvailable == 0) {
                if (netAvailable == 2) {
                    [self hasProfile:(CGFloat)touchMapCoordinate.latitude lng:(CGFloat)touchMapCoordinate.longitude];
                } else if (netAvailable == 0) {
                    [self presentViewController:[CustomAlert openMenuInformation:@"No access to www.google.com for profile elevation." mtitle:@"Access Not Available"] animated:YES completion:nil];
                    [indicator stopAnimating];
                }
            }
        }
        
        [self removeTapCircle];
        self.drawCircle.alpha = 0;
    }

    /*
     if ((tgr.state & UIGestureRecognizerStateRecognized) == UIGestureRecognizerStateRecognized) {
     
     // Get map coordinate from touch point
     CGPoint touchPt = [tgr locationInView:self.mapView];
     CLLocationCoordinate2D coord = [self.mapView convertPoint:touchPt toCoordinateFromView:self.mapView];
     
     double maxMeters = [FindNearestPoly metersFromPixel:MAX_DISTANCE_PX atPoint:touchPt mv:(MKMapView *)mapView];
     
     float nearestDistance = MAXFLOAT;
     MKPolyline *nearestPoly = nil;
     
     // for every overlay ...
     for (id <MKOverlay> overlay in mapView.overlays) {
     // .. if MKPolyline ...
     if ([overlay isKindOfClass:[MKPolyline class]]) {
     // ... get the distance ...
     float distance = [FindNearestPoly distanceOfPointOnPolyline:MKMapPointForCoordinate(coord)
     toPoly:overlay];
     // ... and find the nearest one
     if (distance < nearestDistance) {
     nearestDistance = distance;
     nearestPoly = overlay;
     }
     } else if ([overlay isKindOfClass:[MKPolygon class]]) {
     // ... get the distance ...
     float distance = [FindNearestPoly distanceOfPointOnPolygon:MKMapPointForCoordinate(coord)
     toPoly:overlay];
     // ... and find the nearest one
     if (distance < nearestDistance) {
     nearestDistance = distance;
     nearestPoly = overlay;
     }
     }
     }
     if (nearestDistance <= maxMeters) {
     
     self.drawText = [[DrawText alloc] initWithFrame:CGRectMake(location.x-50, location.y-10, 100.0, 20.0)];
     self.drawText.backgroundColor = [UIColor whiteColor];
     viewTag = viewTag + 1;
     self.drawText.tag = viewTag;
     self.drawText.title = nearestPoly.title;
     [self.mapView addSubview:self.drawText];
     
     if ([nearestPoly.title isEqualToString:@"Howard County"]) {
     [self.mapView addOverlay:[DrawBoundary buildLine:@"Sample_Trail"]];
     [CustomZoom zoomToFitPoly:(MKMapView *)mapView poly:(NSString *)@"Sample_Trail"];
     } else if ([nearestPoly.title isEqualToString:@"Sample_Trail"]) {
     [self openProfile];
     }
     
     NSLog(@"Touched poly: %@\ndistance: %f", nearestPoly.title, nearestDistance);
     }
     }*/
}
- (void)hasProfile:(CGFloat)latYItem lng:(CGFloat)lngXItem {
    NSString *hadIt;
    hadIt = [GetJSON getNearestTrail:latYItem lng:lngXItem];
    self.latItem = latYItem;
    self.lngItem = lngXItem;
    
    if ([hadIt isEqualToString:@"NO"]) {
        [indicator stopAnimating];
    } else {
        NSArray *myArray = [hadIt componentsSeparatedByString:@"-"];
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.trails removeAllObjects];
                             //[self.mapView removeOverlay:trailOverlay];
                             [self removeAllAnnotations];
                             [self setPin];
                             self.trails = [GetJSON getTrail:[myArray objectAtIndex:0] searchItem:[myArray objectAtIndex:1]];
                             
                             trailOverlay = [DrawBoundary buildProfile:(MKMapView *)self.mapView myTrails:(NSMutableArray *)self.trails searchItem:(NSString *)[myArray objectAtIndex:3]];
                             //self.trailName = [myArray objectAtIndex:1];
                             self.trailName = [NSString stringWithFormat:@"%@-%ld ft",[myArray objectAtIndex:1],(long)[[myArray objectAtIndex:2]doubleValue]];
                             currentLength = (long)[[myArray objectAtIndex:2]doubleValue];
                             [self.mapView addOverlay:trailOverlay];
                         }
                         completion:^(BOOL finished) {
                             [AnimateLayer animateLayerHorizontal:(mainView.frame.size.width/2)-26 layer:mapToolsBTN];
                             [AnimateLayer animateLayerHorizontal:(mainView.frame.size.width/2)-26 layer:profileBTN];
                             timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setProfileMarker) userInfo:nil repeats:NO];
                             //[self chkSatellite];
                         }];
    }
}
-(void)setProfileMarker {
    NSString *titleCode = @"PROFILE-Pathways / Trails";
    [CustomZoom setMapCenter:self.mapView item:titleCode subItem:self.trailName lat:self.latItem lng:self.lngItem];
    [indicator stopAnimating];
    [self getCalculator];
}
-(void)getCalculator {
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         pulldownMenu = @"YES";
                         navMenuView.frame = CGRectMake(0, 0, mainView.frame.size.width, 170);
                         navMenuView.alpha = 1;
                         if ([fullMap isEqualToString:@"yes"]) {
                             [self setMapSize];
                         }
                         if ([initialCalculation isEqualToString:@"YES"]) {
                             for(UIView *subview in [navMenuView subviews]) {
                                 [subview removeFromSuperview];
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         if ([pulldownMenu isEqualToString:@"YES"]) {
                             [self createCalculator];
                         }
                         mainMapView.alpha = 1;
                     }];
}
-(void)clearCalculator {
    [self.mapView removeOverlays:self.mapView.overlays];
    [self addTilesOverlay];
    initialCalculation = @"YES";
    currentLength = 0;
    totalLength = 0;
    grandTotal = 0;
    calculatorLBL.text = @"";
    totalLBL.text = @"";
    [self chkSatellite];
}
-(void)closeCalculator {
    [self.mapView removeOverlays:self.mapView.overlays];
    [self addTilesOverlay];
    menuBTN.hidden = NO;
    backBTN.hidden = NO;
    appSubTitle.hidden = NO;
    appTitle.hidden = NO;
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         pulldownMenu = @"NO";
                         navMenuView.frame = CGRectMake(0, 0, mainView.frame.size.width, 64);
                         navMenuView.alpha = 0.5;
                         for(UIView *subview in [navMenuView subviews]) {
                             [subview removeFromSuperview];
                         }
                     }
                     completion:^(BOOL finished) {
                         initialCalculation = @"YES";
                         currentLength = 0;
                         totalLength = 0;
                         grandTotal = 0;
                     }];
    [self chkSatellite];
}
-(void)createCalculator {
    lengthUnit = @"F";
    if ([initialCalculation isEqualToString:@"YES"]) {
        initialCalculation = @"NO";
        
        menuBTN.hidden = YES;
        backBTN.hidden = YES;
        appSubTitle.hidden = YES;
        appTitle.hidden = YES;
        
        UILabel *titleLBL = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, self.view.frame.size.width-40, 30)];
        titleLBL.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
        titleLBL.backgroundColor = [UIColor clearColor];
        titleLBL.textColor = [UIColor whiteColor];
        titleLBL.text = @"Pathway / Trail";
        titleLBL.alpha = 1.0;
        titleLBL.textAlignment = NSTextAlignmentLeft;
        titleLBL.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [navMenuView addSubview:titleLBL];
        
        UIImage *pathImage = [UIImage imageNamed:@"Path.png"];
        UIImageView *pathImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 70, 34, 18)];
        pathImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        pathImageView.image = pathImage;
        pathImageView.alpha = 1;
        [navMenuView addSubview:pathImageView];
        
        UIImage *trailImage = [UIImage imageNamed:@"Trail.png"];
        UIImageView *trailImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2), 70, 34, 18)];
        trailImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        trailImageView.image = trailImage;
        trailImageView.alpha = 1;
        [navMenuView addSubview:trailImageView];
        
        UILabel *pathLBL = [[UILabel alloc] initWithFrame:CGRectMake(60, 70, 80, 18)];
        pathLBL.font = [UIFont fontWithName:@"TrebuchetMS" size:16];
        pathLBL.backgroundColor = [UIColor clearColor];
        pathLBL.textColor = [UIColor whiteColor];
        pathLBL.text = @"Paved";
        pathLBL.alpha = 1.0;
        pathLBL.textAlignment = NSTextAlignmentLeft;
        pathLBL.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [navMenuView addSubview:pathLBL];
        
        UILabel *trailLBL = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)+40, 70, 80, 18)];
        trailLBL.font = [UIFont fontWithName:@"TrebuchetMS" size:16];
        trailLBL.backgroundColor = [UIColor clearColor];
        trailLBL.textColor = [UIColor whiteColor];
        trailLBL.text = @"Unpaved";
        trailLBL.alpha = 1.0;
        trailLBL.textAlignment = NSTextAlignmentLeft;
        trailLBL.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [navMenuView addSubview:trailLBL];
        
        
        CGRect row1Frame = CGRectMake(20, 96, self.view.frame.size.width-40, 40);
        
        calculatorLBL = [[UILabel alloc] initWithFrame:row1Frame];
        calculatorLBL.font = [UIFont fontWithName:@"TrebuchetMS" size:16];
        calculatorLBL.backgroundColor = [UIColor clearColor];
        calculatorLBL.textColor = [UIColor greenColor];
        calculatorLBL.alpha = 1.0;
        calculatorLBL.textAlignment = NSTextAlignmentLeft;
        calculatorLBL.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        calculatorLBL.numberOfLines = 2;
        [navMenuView addSubview:calculatorLBL];
        
        row1Frame.origin.y += 34;
        row1Frame.origin.x += 110;
        
        totalLBL = [[UILabel alloc] initWithFrame:row1Frame];
        totalLBL.font = [UIFont fontWithName:@"TrebuchetMS" size:16];
        totalLBL.backgroundColor = [UIColor clearColor];
        totalLBL.textColor = [UIColor greenColor];
        totalLBL.alpha = 1.0;
        totalLBL.textAlignment = NSTextAlignmentLeft;
        totalLBL.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [navMenuView addSubview:totalLBL];
        
        UIButton *clearBTN = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, row1Frame.origin.y+8, 60, 20)];
        [clearBTN addTarget:self action:@selector(clearCalculator) forControlEvents:UIControlEventTouchUpInside];
        [clearBTN setTitle:@"Clear" forState:UIControlStateNormal];
        //clearBTN.backgroundColor = [UIColor colorWithRed:195/255.0f green:195/255.0f blue:195/255.0f alpha:1.0f];
        clearBTN.titleLabel.font = [UIFont systemFontOfSize:16];
        clearBTN.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [navMenuView addSubview:clearBTN];
        
        unitBTN = [[UIButton alloc] initWithFrame:CGRectMake(20, row1Frame.origin.y+8, 110, 20)];
        [unitBTN addTarget:self action:@selector(unitConvert) forControlEvents:UIControlEventTouchUpInside];
        [unitBTN setTitle:@"Total length: " forState:UIControlStateNormal];
        //unitBTN.backgroundColor = [UIColor colorWithRed:195/255.0f green:195/255.0f blue:195/255.0f alpha:1.0f];
        unitBTN.titleLabel.font = [UIFont systemFontOfSize:16];
        unitBTN.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [navMenuView addSubview:unitBTN];
        
        UIButton *exitTipsBTN = [UIButton buttonWithType:UIButtonTypeCustom];
        exitTipsBTN.frame = CGRectMake(self.view.frame.size.width-45, 20, 40, 40);
        [exitTipsBTN setBackgroundImage:[UIImage imageNamed:@"Exit.png"] forState:UIControlStateNormal];
        [exitTipsBTN addTarget:self action:@selector(closeCalculator) forControlEvents:UIControlEventTouchUpInside];
        [navMenuView addSubview:exitTipsBTN];
        
        totalLength = currentLength;
        appenLength = [NSString stringWithFormat:@"%ld", (long)currentLength];
        calculatorLBL.text = [NSString stringWithFormat:@"%@", appenLength];
        //totalLBL.text = [NSString stringWithFormat:@"%ld", (long)currentLength];
        appLen = appenLength;
        grandTotal = currentLength;
        if (grandTotal > 1320) {
            totalLBL.text = [NSString stringWithFormat:@"%.02f mi", grandTotal/5280];
        } else if (grandTotal < 1320) {
            totalLBL.text = [NSString stringWithFormat:@"%.02f ft", grandTotal];
        }
    } else if ([initialCalculation isEqualToString:@"NO"]) {
        grandTotal = totalLength + currentLength;
        appLen = [appLen stringByAppendingString:[NSString stringWithFormat:@" + %ld", (long)currentLength]];
        calculatorLBL.text = [NSString stringWithFormat:@"%@", appLen];
        
        if (grandTotal > 1320) {
            totalLBL.text = [NSString stringWithFormat:@"%.02f mi", grandTotal/5280];
        } else if (grandTotal < 1320) {
            totalLBL.text = [NSString stringWithFormat:@"%.02f ft", grandTotal];
        }
        totalLength = grandTotal;
    }
}
-(void)unitConvert {
    if ([lengthUnit isEqualToString:@"F"]) {
        lengthUnit = @"M";
        if (grandTotal > 1320) {
            totalLBL.text = [NSString stringWithFormat:@"%.02f mi", (grandTotal)/5280];
        } else if (grandTotal < 1320) {
            totalLBL.text = [NSString stringWithFormat:@"%.02f ft", grandTotal];
        }
        grandTotal = grandTotal*0.3048;
    } else if ([lengthUnit isEqualToString:@"M"]) {
        lengthUnit = @"F";
        if (grandTotal > 1000) {
            totalLBL.text = [NSString stringWithFormat:@"%.02f km", (grandTotal)/1000];
        } else if (grandTotal < 1320) {
            totalLBL.text = [NSString stringWithFormat:@"%.02f m", grandTotal];
        }
        grandTotal = grandTotal*3.28084;
    }
}
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)lpgr {
    //CGPoint touchPoint = [lpgr locationInView:self.mapView];
    //CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    //NSLog(@"LongPress: Coordinate = %f,%f",touchMapCoordinate.latitude, touchMapCoordinate.longitude);
    [self removeTapCircle];
    self.drawCircle.alpha = 0;
}
- (void)changeTip:(id)sender{
    if([sender isOn]) {
        tipDisplay = @"ON";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"ON" forKey:@"tips"];
        [defaults synchronize];
    } else {
        tipDisplay = @"OFF";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"OFF" forKey:@"tips"];
        [defaults synchronize];
    }
}
- (void)changeTrails:(id)sender{
    if([sender isOn]) {
        [self postTipMessage:(NSString*)@"Press and hold at pathway or trail line on a map to get profile elevation."  type:(NSString*)@""];
        trailsDisplay = @"ON";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"ON" forKey:@"trails"];
        [defaults synchronize];
    } else {
        trailsDisplay = @"OFF";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"OFF" forKey:@"trails"];
        [defaults synchronize];
    }
    [self chkSatellite];
}
-(void)chkSatellite {
    if ([mapSatelliteDisplay isEqualToString:@"ON"]) {
        [self.mapView setMapType:MKMapTypeSatellite];
        if(self.tileOverlay) {
            [self.mapView removeOverlay:self.tileOverlay];
            self.tileOverlay = nil;
        }
    } else if ([mapSatelliteDisplay isEqualToString:@"OFF"]) {
        [self.mapView setMapType:MKMapTypeStandard];
        [self addTilesOverlay];
    }
}
- (void)changeMap:(id)sender{
    if([sender isOn]) {
        mapSatelliteDisplay = @"ON";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"ON" forKey:@"satellite"];
        [defaults synchronize];
        [self chkSatellite];
    } else {
        mapSatelliteDisplay = @"OFF";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"OFF" forKey:@"satellite"];
        [defaults synchronize];
        [self chkSatellite];
    }
}
- (void)changeAmenities:(id)sender{
    if([sender isOn]) {
        amenitiesDisplay = @"ON";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"ON" forKey:@"amenities"];
        [defaults synchronize];
        [self removeAllAnnotations];
        [self.amenities removeAllObjects];
        searchItem = @"Amenities";
        self.amenities = [GetJSON getFeatureByParkID:@"All" searchItem:@"Some_Amenities" mv:self.mapView];
        [self setPin];

    } else {
        amenitiesDisplay = @"OFF";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"OFF" forKey:@"amenities"];
        [defaults synchronize];
        [self removeAllAnnotations];
        [self.parks removeAllObjects];
        searchItem = originalItem;
        self.parks = [GetJSON getNearest:searchType searchItem:searchItem mv:self.mapView];
        [self setPin];
    }
    [self chkSatellite];
}
-(void)getMenu {
    [self clearCalculator];
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if ([pulldownMenu isEqualToString:@"NO"]) {
                             pulldownMenu = @"YES";
                             navMenuView.frame = CGRectMake(0, 0, mainView.frame.size.width, 170);
                             navMenuView.alpha = 1;
                             if ([fullMap isEqualToString:@"yes"]) {
                                 [self setMapSize];
                             }
                         } else if ([pulldownMenu isEqualToString:@"YES"]) {
                             pulldownMenu = @"NO";
                             navMenuView.frame = CGRectMake(0, 0, mainView.frame.size.width, 64);
                             navMenuView.alpha = 0.5;
                             for(UIView *subview in [navMenuView subviews]) {
                                 [subview removeFromSuperview];
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         if ([pulldownMenu isEqualToString:@"YES"]) {
                             [self createMenu];
                         }
                         mainMapView.alpha = 1;
                     }];
}
-(void)createMenu {
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    
    CIImage *inputImage1 = [CIImage imageWithCGImage:[[UIImage imageNamed:@"NearestParksBG.jpeg"] CGImage]];
    [gaussianBlurFilter setValue:inputImage1 forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@30 forKey:kCIInputRadiusKey];
    
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context   = [CIContext contextWithOptions:nil];
    cgimg     = [context createCGImage:outputImage fromRect:[inputImage1 extent]];
    
    self.menuImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, navMenuView.frame.size.width, navMenuView.frame.size.height)];
    self.menuImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.menuImage.image = [UIImage imageWithCGImage:cgimg];
    self.menuImage.alpha = 1;
    [navMenuView addSubview:self.menuImage];
    
    CGRect row1Frame = CGRectMake((self.view.frame.size.width/2)-144, 80, 32, 32);
    
    r1BTN1 = [UIButton buttonWithType:UIButtonTypeCustom];
    r1BTN1.frame = row1Frame;
    r1BTN1.tag = 1;
    [r1BTN1 setBackgroundImage:[UIImage imageNamed:@"phone.png"] forState:UIControlStateNormal];
    [r1BTN1 addTarget:self action:@selector(openCall) forControlEvents:UIControlEventTouchUpInside];
    [navMenuView addSubview:r1BTN1];
    
    row1Frame.origin.x += 62;
    r1BTN2 = [UIButton buttonWithType:UIButtonTypeCustom];
    r1BTN2.frame = row1Frame;
    r1BTN2.tag = 2;
    [r1BTN2 setBackgroundImage:[UIImage imageNamed:@"rules.png"] forState:UIControlStateNormal];
    [r1BTN2 addTarget:self action:@selector(openRule) forControlEvents:UIControlEventTouchUpInside];
    [navMenuView addSubview:r1BTN2];
    
    r1BTN3 = [UIButton buttonWithType:UIButtonTypeCustom];
    r1BTN3.frame = CGRectMake((self.view.frame.size.width/2)-25, 80, 50, 50);
    r1BTN3.tag = 3;
    [r1BTN3 setBackgroundImage:[UIImage imageNamed:@"tellHoCo.png"] forState:UIControlStateNormal];
    [r1BTN3 addTarget:self action:@selector(openTellHoCo) forControlEvents:UIControlEventTouchUpInside];
    [navMenuView addSubview:r1BTN3];
    
    row1Frame.origin.x += 136;
    r1BTN4 = [UIButton buttonWithType:UIButtonTypeCustom];
    r1BTN4.frame = row1Frame;
    r1BTN4.tag = 4;
    [r1BTN4 setBackgroundImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    [r1BTN4 addTarget:self action:@selector(openSearch) forControlEvents:UIControlEventTouchUpInside];
    [navMenuView addSubview:r1BTN4];
    
    row1Frame.origin.x += 62;
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
    vc.searchType = self.searchType;
    vc.searchItem = self.searchItem;
    vc.searchSelected = self.searchSelected;
    vc.searchTitle = self.searchTitle;
    vc.park_id = self.park_id;
    vc.site_name = self.site_name;
    vc.feature_id = self.feature_id;
    vc.latItem = self.latItem;
    vc.lngItem = self.lngItem;
    vc.backViewName = @"NearestResult";
    vc.site_id = self.site_id;
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
    vc.searchType = self.searchType;
    vc.searchItem = self.searchItem;
    vc.searchSelected = self.searchSelected;
    vc.searchTitle = self.searchTitle;
    vc.park_id = self.park_id;
    vc.site_name = self.site_name;
    vc.feature_id = self.feature_id;
    vc.latItem = self.latItem;
    vc.lngItem = self.lngItem;
    vc.backViewName = @"NearestResult";
    vc.site_id = self.site_id;
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)openCall {
    [self presentViewController:[CustomAlert makePhoneCall] animated:YES completion:nil];
}
-(void)openProfile:(NSMutableArray *)myprofiles {
    backBTN.hidden = NO;
    menuBTN.hidden = NO;
    appSubTitle.hidden = NO;
    appTitle.hidden = NO;
    [fullStepBTN setBackgroundImage:[UIImage imageNamed:@"Arrow_Out.png"] forState:UIControlStateNormal];
    fullStep = @"no";
    for(UIView *subview in [scroller subviews]) {
        [subview removeFromSuperview];
    }
    
    //NSLog(@"%lu", (unsigned long)myprofiles.count);
    //NSLog(@"%@", myprofiles);
    
    [self.distances removeAllObjects];
    self.distances = [GetJSON getDistanceProfile:myprofiles];

    float maxDist = 0.0;
    for(int i=0; i< [self.distances count]; i++) {
        NSDictionary *loc = [self.distances objectAtIndex:i];
        float currentValue = [[loc objectForKey:@"sum_distance"]floatValue];
        if (currentValue > maxDist) {
            maxDist = currentValue;
        }
    }
    
    float maxV = 0.0;
    for(int i=0; i< [self.distances count]; i++) {
        NSDictionary *loc = [self.distances objectAtIndex:i];
        float currentValue = [[loc objectForKey:@"elevation"]floatValue];
        if (currentValue > maxV) {
            maxV = currentValue;
        }
    }
    
    float minV = maxV;
    for(int i=0; i< [self.distances count]; i++) {
        NSDictionary *loc = [self.distances objectAtIndex:i];
        float currentValue = [[loc objectForKey:@"elevation"]floatValue];
        if (currentValue < minV) {
            minV = currentValue;
        }
    }
    
    //float diff = maxV - minV;
    
    scroller.contentSize = CGSizeMake(maxDist+20, 250);

    self.drawProfile = nil;
    self.drawProfile = [[DrawProfile alloc] initWithFrame:CGRectMake(0, 0, maxDist+20, 250)];
    self.drawProfile.backgroundColor = [UIColor whiteColor];
    [scroller addSubview:self.drawProfile];
    
    profileView.image = nil;
    profileView = nil;
    profileView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxDist+20, 250)];
    [scroller addSubview:profileView];
    
    //NSLog(@"Length:%f",maxDist);
    //NSLog(@"Maxi:%f",maxV);
    //NSLog(@"Mani:%f",minV);
    //NSLog(@"Diff:%f",diff);

    NSString *unit;
    float sumDistInMi = 0.0;
    float minVInFt = minV*3.28084;
    float maxVInFt = maxV*3.28084;
    
    if (maxDist*3.28084 > 1320) {
        sumDistInMi = (maxDist*3.28084)/5280;
        unit = @"mi";
    } else if (maxDist*3.28084 < 1320) {
        sumDistInMi = maxDist*3.28084;
        unit = @"ft";
    }
    X_Line = 0;
    Y_Line = 250-minV;
    
    for(int i=0; i< [self.distances count]; i++) {
        NSDictionary *loc = [self.distances objectAtIndex:i];
        x = [[loc objectForKey:@"sum_distance"]floatValue];
        y = 250-[[loc objectForKey:@"elevation"]floatValue];
        [self createGraph];
        if (i==0) {
            self.drawStartPoint = [[DrawStartPoint alloc] initWithFrame:CGRectMake(x-8, y-8, 16.0, 16.0)];
            self.drawStartPoint.backgroundColor = [UIColor clearColor];
            [scroller addSubview:self.drawStartPoint];
        } else if (i+1==[self.distances count]) {
            self.drawEndPoint = [[DrawEndPoint alloc] initWithFrame:CGRectMake(x-8, y-8, 16.0, 16.0)];
            self.drawEndPoint.backgroundColor = [UIColor clearColor];
            [scroller addSubview:self.drawEndPoint];
        }
    }
    fullMap = @"yes";
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         mainMapView.frame = CGRectMake(0, 64, self.view.frame.size.width, (self.view.frame.size.height/2)-64);
                         self.mapView.frame = CGRectMake(0, 45, mainMapView.frame.size.width, mainMapView.frame.size.height-45);
                         myTableView.alpha = 0;
                         stepsTextView.alpha = 0;
                         self.titleImage.alpha = 0;
                         scroller.alpha = 1;
                         if ([pulldownMenu isEqualToString:@"YES"]) {
                             [self getMenu];
                         }
                     }
                     completion:^(BOOL finished) {
                         [fullMapBTN setBackgroundImage:[UIImage imageNamed:@"Arrow_In.png"] forState:UIControlStateNormal];
                         [AnimateLayer animateLayerHorizontal:-(mainView.frame.size.width) layer:myTableView];
                         [UIView animateWithDuration:1.0
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              DDView.frame = CGRectMake(0, (self.view.frame.size.height/2), self.view.frame.size.width, (self.view.frame.size.height/2));
                                          }
                                          completion:^(BOOL finished) {
                                              titleDDLabel.text = @"Path / Trail Profile";
                                              destinationLabel.text = [NSString stringWithFormat:@"Trail Name: %@", self.trailName];
                                              distanceLabel.text = [NSString stringWithFormat:@"Distance: %.02f m.(%.02f %@)",maxDist,sumDistInMi,unit];
                                              stepsTitle.text = [NSString stringWithFormat:@"Elev. Lo-Hi: %.02f-%.02f m.(%.02f-%.02f ft.)",minV,maxV,minVInFt,maxVInFt];
                                              [indicator stopAnimating];
                                              [self postTipMessage:(NSString*)@"To select another pathway or trail, press and hold at a line on a map."  type:(NSString*)@""];
                                              [profileBTN setBackgroundImage:[UIImage imageNamed:@"LineChart.png"] forState:UIControlStateNormal];
                                              voiceBTN.alpha = 0;
                                          }];
                     }];
}
-(void)createGraph {

    UIGraphicsBeginImageContext(profileView.frame.size);
    CGRect graphRect = CGRectMake(0, 0, profileView.frame.size.width, profileView.frame.size.height);
    [profileView.image drawInRect:graphRect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 6.0);
    CGContextMoveToPoint(context, X_Line, Y_Line);
    CGContextAddLineToPoint(context, x , y);
    CGContextStrokePath(context);
    profileView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    X_Line = x;
    Y_Line = y;
}
-(void)showMapItem {
    for (int i = 0; i < [self.parks count]; i++) {
        NSDictionary *loc = [self.parks objectAtIndex:i];
        NSString *sid = [loc objectForKey:@"id"];
        if ([sid isEqualToString:self.site_id]) {
            //MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
            double destLat, destLng;
            destLat = [[loc objectForKey:@"latitude"]doubleValue];
            destLng = [[loc objectForKey:@"longitude"]doubleValue];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(destLat, destLng);
            
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:placemark];
            NSDictionary *options = @{
                                      MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving
                                      };
            [mapItem openInMapsWithLaunchOptions:options];
        }
    }
}
- (void)openDirectionMap:(NSString *)item {
    for (int i = 0; i < [self.parks count]; i++) {
        NSDictionary *loc = [self.parks objectAtIndex:i];
        NSString *sid = [loc objectForKey:@"id"];
        if ([sid isEqualToString:self.site_id]) {
            MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
            double destLat, destLng;
            destLat = [[loc objectForKey:@"latitude"]doubleValue];
            destLng = [[loc objectForKey:@"longitude"]doubleValue];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(destLat, destLng);
            
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
            
            [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
            [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:placemark]];
            directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
            MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
            
            [self.mapView removeOverlay:routeDetails.polyline];
            
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                if (error) {
                    //NSLog(@"Error %@", error.description);
                } else {
                    routeDetails = response.routes.lastObject;
                    titleDDLabel.text = @"Driving Directions";
                    destinationLabel.text = [NSString stringWithFormat:@"Destination: %@", item];
                    distanceLabel.text = [NSString stringWithFormat:@"Distance: %0.1f Miles", routeDetails.distance/1609.344];
                    stepsTitle.text = @"Steps: ";
                    allSteps = @"";
                    for (int i = 0; i < routeDetails.steps.count; i++) {
                        MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
                        NSString *newStep = step.instructions;
                        allSteps = [allSteps stringByAppendingString:newStep];
                        allSteps = [allSteps stringByAppendingString:@"\n\n"];
                        stepsTextView.text = allSteps;
                    }
                    
                    [self.mapView addOverlay:routeDetails.polyline];
                    [self zoomToPolyLine:routeDetails.polyline animated:YES];
                }
            }];
            fullMap = @"yes";
            [UIView animateWithDuration:1.0
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 mainMapView.frame = CGRectMake(0, 64, self.view.frame.size.width, (self.view.frame.size.height/2)-64);
                                 self.mapView.frame = CGRectMake(0, 45, mainMapView.frame.size.width, mainMapView.frame.size.height-45);
                                 myTableView.alpha = 0;
                                 stepsTextView.alpha = 1;
                                 self.titleImage.alpha = 0;
                                 scroller.alpha = 0;
                                 if ([pulldownMenu isEqualToString:@"YES"]) {
                                     [self getMenu];
                                 }
                             }
                             completion:^(BOOL finished) {
                                 [fullMapBTN setBackgroundImage:[UIImage imageNamed:@"Arrow_In.png"] forState:UIControlStateNormal];
                                 [AnimateLayer animateLayerHorizontal:-(mainView.frame.size.width) layer:myTableView];
                                 [UIView animateWithDuration:1.0
                                                       delay:0.0
                                                     options:UIViewAnimationOptionCurveEaseInOut
                                                  animations:^{
                                                            DDView.frame = CGRectMake(0, (self.view.frame.size.height/2), self.view.frame.size.width, (self.view.frame.size.height/2));
                                                  }
                                                  completion:^(BOOL finished) {
                                                      [profileBTN setBackgroundImage:[UIImage imageNamed:@"List.png"] forState:UIControlStateNormal];
                                                      voiceBTN.alpha = 1.0;
                                                      [self postTipMessage:(NSString*)@"To get turn by turn voice navigatior"  type:(NSString*)@"voice"];
                                                  }];
                             }];
            
        }
    }
}
-(void)zoomToPolyLine:(MKPolyline*)polyline animated: (BOOL)animated {
    [self.mapView setVisibleMapRect:[polyline boundingMapRect] edgePadding:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0) animated:animated];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.parks.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info;
    info = [self.parks objectAtIndex:indexPath.row];
    UILabel *parkLabel, *distLabel;
    self.cell = nil;
    if (self.cell == nil) {
        static NSString *CellIdentifier = @"Cell";
        self.cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        self.cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        self.cell.backgroundColor = [UIColor clearColor];
        
        UIImageView *tableImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
        tableImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        tableImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_1.png", [info objectForKey:@"feature_type"]]];
        tableImage.alpha = 1;
        [self.cell addSubview:tableImage];
        
        UIImageView *arImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.mainTableView.frame.size.width-50, 5, 40, 40)];
        arImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        arImage.image = [UIImage imageNamed:@"Arrow_Right_Black.png"];
        arImage.alpha = 1;
        [self.cell addSubview:arImage];
        
        CGRect myFrame = CGRectMake(60.0, 5.0, self.mainTableView.frame.size.width-100, 25.0);
        parkLabel = [[UILabel alloc] initWithFrame:myFrame];
        parkLabel.backgroundColor = [UIColor clearColor];
        parkLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
        parkLabel.textColor = [UIColor blackColor];
        [self.cell.contentView addSubview:parkLabel];
        
        myFrame.origin.y += 20;
        distLabel = [[UILabel alloc] initWithFrame:myFrame];
        distLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:14];
        if ([[info objectForKey:@"feature_name"] isEqualToString:@"Portable Toilet"]) {
            distLabel.textColor = [UIColor whiteColor];
        } else {
            distLabel.textColor = [UIColor blackColor];
        }
        
        distLabel.backgroundColor = [UIColor clearColor];
        [self.cell.contentView addSubview:distLabel];
    }
    if ([self.cell respondsToSelector:@selector(setSeparatorInset:)]) {
        self.cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 10);
    }
    CLLocation *pinLocation = [[CLLocation alloc]
                               initWithLatitude:[[info objectForKey:@"latitude"]floatValue]
                               longitude:[[info objectForKey:@"longitude"]floatValue]];
    CLLocation *userLocation = [[CLLocation alloc]
                                initWithLatitude:self.mapView.userLocation.coordinate.latitude
                                longitude:self.mapView.userLocation.coordinate.longitude];
    CLLocationDistance dist = [userLocation distanceFromLocation:pinLocation];
    
    if ([searchItem isEqualToString:@"Parks"]
        || [searchItem isEqualToString:@"Historic Sites"]
        ) {
        parkLabel.text = [info objectForKey:@"feature_name"];
        if ([uLoc isEqualToString:@"OFF"]) {
           distLabel.text = [NSString stringWithFormat:@"Distance: %.02f mi.", dist/1609.34];
        } else if ([uLoc isEqualToString:@"ON"]) {
           distLabel.text = [NSString stringWithFormat:@"Distance: Not available"];
        }
    } else if ([searchItem isEqualToString:@"Pavilions"]
        || [searchItem isEqualToString:@"Playgrounds"]
        ) {
        parkLabel.text = [info objectForKey:@"site_name"];
        if ([uLoc isEqualToString:@"OFF"]) {
            distLabel.text = [NSString stringWithFormat:@"%@(%.02f mi.)", [info objectForKey:@"feature_name"],dist/1609.34];
        } else if ([uLoc isEqualToString:@"ON"]) {
            distLabel.text = [NSString stringWithFormat:@"Distance: Not available"];
        }
    } else {
        parkLabel.text = [info objectForKey:@"site_name"];
        if ([uLoc isEqualToString:@"OFF"]) {
            distLabel.text = [NSString stringWithFormat:@"%@(%.02f mi.)", [info objectForKey:@"feature_name"],dist/1609.34];
        } else if ([uLoc isEqualToString:@"ON"]) {
            distLabel.text = [NSString stringWithFormat:@"Distance: Not available"];
        }
    }
    return self.cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info;
    info = [self.parks objectAtIndex:indexPath.row];
    self.latItem = [[info objectForKey:@"latitude"]floatValue];
    self.lngItem = [[info objectForKey:@"longitude"]floatValue];
    selectedRow = [info objectForKey:@"feature_name"];
    NSString *s_name = [info objectForKey:@"site_name"];
    NSString *s_id = [info objectForKey:@"id"];
    NSString *f_type = [info objectForKey:@"feature_type"];
    NSString *f_id = [info objectForKey:@"feature_id"];
    NSString *p_id = [info objectForKey:@"park_id"];
    
    NSString *parkCode;
    
    if([amenitiesDisplay isEqualToString:@"ON"]) {

    } else if([amenitiesDisplay isEqualToString:@"OFF"]) {

    }
    
    NSString *titleCode = [NSString stringWithFormat:@"%@-%@", f_type,selectedRow];
    
    //amenitiesDisplay = @"OFF";
    
    pageControl.currentPage = 2;
    [self pageTurn:pageControl];
    
    if ([f_type isEqualToString:@"PARK"]
        || [f_type isEqualToString:@"PAVILION"]
        || [f_type isEqualToString:@"PLAYGROUND"]
        || [f_type isEqualToString:@"HISTORIC"]
        ) {
        [self postTipMessage:@"Get more information on selected item." type:(NSString*)@"information"];
    } else {
        [self postTipMessage:@"For driving or walking directions." type:(NSString*)@"direction"];
    }
    appTitle.text = [NSString stringWithFormat:@"%@", [info objectForKey:@"site_name"]];


    if ([f_type isEqualToString:@"PARK"]) {
        if([amenitiesDisplay isEqualToString:@"ON"]) {
            parkCode = [NSString stringWithFormat:@"%@-P%@-%@", p_id,s_id,s_name];
        } else if([amenitiesDisplay isEqualToString:@"OFF"]) {
            parkCode = [NSString stringWithFormat:@"%@-%@-%@", p_id,s_id,s_name];
        }
        
        inImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", [info objectForKey:@"site_name"]]];
        [self.mapView addOverlay:[DrawBoundary buildBoundary:[info objectForKey:@"site_name"]]];
        [CustomZoom zoomToFitPoly:(MKMapView *)self.mapView poly:[info objectForKey:@"site_name"]];
    } else if ([f_type isEqualToString:@"HISTORIC"]) {
        if([amenitiesDisplay isEqualToString:@"ON"]) {
            parkCode = [NSString stringWithFormat:@"%@-H%@-%@", p_id,s_id,s_name];
        } else if([amenitiesDisplay isEqualToString:@"OFF"]) {
            parkCode = [NSString stringWithFormat:@"%@-%@-%@", p_id,s_id,s_name];
        }
        inImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", [info objectForKey:@"site_name"]]];
    } else if ([f_type isEqualToString:@"PAVILION"]
               || [f_type isEqualToString:@"PLAYGROUND"]
               ) {
        parkCode = [NSString stringWithFormat:@"%@-%@-%@", p_id,s_id,s_name];
        inImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", f_id]];
        [self.mapView addOverlay:[DrawBoundary buildBoundary:[info objectForKey:@"site_name"]]];
        [CustomZoom zoomToFitPoly:(MKMapView *)self.mapView poly:[info objectForKey:@"site_name"]];
    } else {
        parkCode = [NSString stringWithFormat:@"%@-%@-%@", p_id,s_id,s_name];
        inImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", [info objectForKey:@"site_name"]]];
        [self.mapView addOverlay:[DrawBoundary buildBoundary:[info objectForKey:@"site_name"]]];
        [CustomZoom zoomToFitPoly:(MKMapView *)self.mapView poly:[info objectForKey:@"site_name"]];
    }
    [CustomZoom setMapCenter:self.mapView item:titleCode subItem:parkCode lat:self.latItem lng:self.lngItem];
    self.titleImage.image = inImage;
    //[self checkSetting];

}
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithRed:235/255.0f green:0.0f blue:0.0f alpha:.5];
}
-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
}
- (void)callSetting {
    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication]openURL:settingsURL];
}
- (void)appLocationSetting {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"App Permission Denied"
                                          message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Setting"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                   [[UIApplication sharedApplication]openURL:settingsURL];
                               }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action)
                                   {
                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                   }];
    [alertController addAction:actionOk];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)getCurrentLocation {
    if (!([CLLocationManager locationServicesEnabled])
        || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        ) {
        [self appLocationSetting];
    } else {
        if ([uLoc isEqualToString:@"OFF"]) {
            [self postTipMessage:@"Mark your spot or starting point for later navigate back whenever you get lost" type:(NSString*)@"location"];
            [AnimateLayer animateLayerHorizontal:(mainMapView.frame.size.width/4)+10 layer:saveLocationBTN];
            uLoc = @"ON";
            locationLabel.text = @"Locate Me\nis on";
            [self startLocationUpdates];
        } else if ([uLoc isEqualToString:@"ON"]) {
            [AnimateLayer animateLayerHorizontal:0 layer:saveLocationBTN];
            uLoc = @"OFF";
            locationLabel.text = @"Locate Me\nis off";
            [self stopLocationUpdates];
        }
    }
}
- (void)stopLocationUpdates {
    self.mapView.showsUserLocation = NO;
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
}
- (void)startLocationUpdates {
    self.mapView.showsUserLocation = YES;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied) {
        [self appLocationSetting];  
    } else if (status==kCLAuthorizationStatusAuthorizedAlways || status==kCLAuthorizationStatusAuthorizedWhenInUse) {
        [locationManager requestAlwaysAuthorization];
        if (nil == locationManager) {
            locationManager = [[CLLocationManager alloc] init];
        }
        //locationManager.delegate = self;
        //locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        //locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        //locationManager.headingFilter = kCLHeadingFilterNone;
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.activityType = CLActivityTypeFitness;
        locationManager.distanceFilter = 10; // meters
        
        
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
        [locationManager startUpdatingLocation];
        [locationManager startUpdatingHeading];
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *newLocation in locations) {
        NSDate *eventDate = newLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
            latUserLocation = newLocation.coordinate.latitude;
            lngUserLocation = newLocation.coordinate.longitude;
            MKCoordinateRegion region =
            MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
            [self.mapView setRegion:region animated:YES];
            self.latItem = newLocation.coordinate.latitude;
            self.lngItem = newLocation.coordinate.longitude;
        }
    }
    
    if ([uLoc isEqualToString:@"OFF"]) {
        [self.mainTableView reloadData];
        [locationManager stopUpdatingLocation];
        [locationManager stopUpdatingHeading];
    }
}
/*
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    latUserLocation = newLocation.coordinate.latitude;
    lngUserLocation = newLocation.coordinate.longitude;
    
    MKCoordinateRegion region;
    region.center.latitude = newLocation.coordinate.latitude;
    region.center.longitude = newLocation.coordinate.longitude;
    region.span.latitudeDelta = 0.002f;
    region.span.longitudeDelta = 0.002f;
    [self.mapView setRegion:region animated:YES];
    
    self.latItem = newLocation.coordinate.latitude;
    self.lngItem = newLocation.coordinate.longitude;
    
    [geoCoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        locationItem = [NSString stringWithFormat:@"%@",locatedAt];
    }];
    if ([uLoc isEqualToString:@"OFF"]) {
        [self.mainTableView reloadData];
        [locationManager stopUpdatingLocation];
        [locationManager stopUpdatingHeading];
    }
}
*/
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}
-(void)back_ClickNext {
    pageControl.currentPage = 1;
    [self pageTurn:pageControl];
}
-(void)back_Click {
    if ([appSubTitle.text isEqualToString:@"Map"]) {
        if ([fullMap isEqualToString:@"yes"]) {
            [self setMapSize];
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(back_ClickNext) userInfo:nil repeats:NO];
        } else if ([fullMap isEqualToString:@"no"]) {
            pageControl.currentPage = 1;
            [self pageTurn:pageControl];
        }
    } else if ([appSubTitle.text isEqualToString:@"Alphabetical"]) {
        pageControl.currentPage = 0;
        [self pageTurn:pageControl];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        if ([self.backViewName isEqualToString:@"Main"]) {
            MainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainView"];
            [self presentViewController:vc animated:YES completion:nil];
        } else if ([self.backViewName isEqualToString:@"MainAmenities"]){
            MainAmenitiesViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainAmenitiesView"];
            [self presentViewController:vc animated:YES completion:nil];
        } else if ([self.backViewName isEqualToString:@"NearestResult"]){
            MainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainView"];
            [self presentViewController:vc animated:YES completion:nil];
        }
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
    } else if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonRenderer *plRenderer = [[MKPolygonRenderer alloc] initWithPolygon:overlay];
        plRenderer.strokeColor = [UIColor clearColor];
        plRenderer.lineWidth = 1;
        plRenderer.alpha = 0.5;
        return plRenderer;
    } else if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline* polyline = (MKPolyline *)overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        if ([polyline.title isEqualToString:@"Howard County"]) {
            routeRenderer.strokeColor = [UIColor grayColor];
            routeRenderer.lineWidth = 2;
        } else if ([polyline.title isEqualToString:@"TRAIL"]
                   || [polyline.title isEqualToString:@"TRAILVIA"]
                   ) {
            routeRenderer.strokeColor = [UIColor redColor];
            routeRenderer.lineWidth = 6;
            routeRenderer.alpha = 0.5;
            routeRenderer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:8],[NSNumber numberWithFloat:8], nil];
        } else {
            routeRenderer.strokeColor = [UIColor blueColor];
            routeRenderer.lineWidth = 6;
            routeRenderer.alpha = 0.5;
            routeRenderer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:8],[NSNumber numberWithFloat:8], nil];
        }
        return routeRenderer;
    }
    return nil;
}
-(void)removeAllAnnotations {
    id userAnnotation = self.mapView.userLocation;
    NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.mapView.annotations];
    [annotations removeObject:userAnnotation];
    [self.mapView removeAnnotations:annotations];
}
- (void)setPinBlank {
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    self.mapView.showsUserLocation = YES;
    
    NSMutableArray *pindata;
    
    if([amenitiesDisplay isEqualToString:@"ON"]) {
        pindata = self.amenities;
    } else if([amenitiesDisplay isEqualToString:@"OFF"]) {
        pindata = self.parks;
    }
    
    CLLocationCoordinate2D location;
    
    for (int i = 0; i < [pindata count]; i++) {
        NSDictionary *loc = [pindata objectAtIndex:i];
        location.latitude = [[loc objectForKey:@"latitude"]doubleValue];
        location.longitude = [[loc objectForKey:@"longitude"]doubleValue];
        NSString *title = [loc objectForKey:@"feature_name"];
        NSString *s_name = [loc objectForKey:@"site_name"];
        NSString *s_id = [loc objectForKey:@"id"];
        NSString *f_id = [loc objectForKey:@"feature_id"];
        NSString *f_type = [loc objectForKey:@"feature_type"];
        NSString *p_id = [loc objectForKey:@"park_id"];
        
        NSString *parkCode;
        if ([f_type isEqualToString:@"PAVILION"]) {
            parkCode = [NSString stringWithFormat:@"%@-%@-%@", p_id,f_id,s_name];
        } else {
            parkCode = [NSString stringWithFormat:@"%@-%@-%@", p_id,s_id,s_name];
        }
        
        BlankAnnotation *ann1 = [[BlankAnnotation alloc] init];
        ann1.title = title;
        ann1.subtitle = parkCode;
        ann1.coordinate = location;
        [self.mapView addAnnotation:ann1];
    }
}
- (void)setPin {
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    self.mapView.showsUserLocation = YES;
    
    NSMutableArray *pindata;
    
    if([amenitiesDisplay isEqualToString:@"ON"]) {
        pindata = self.amenities;
    } else if([amenitiesDisplay isEqualToString:@"OFF"]) {
        pindata = self.parks;
    }
    
    CLLocationCoordinate2D location;
    
    for (int i = 0; i < [pindata count]; i++) {
        NSDictionary *loc = [pindata objectAtIndex:i];
        location.latitude = [[loc objectForKey:@"latitude"]doubleValue];
        location.longitude = [[loc objectForKey:@"longitude"]doubleValue];
        NSString *title = [loc objectForKey:@"feature_name"];
        NSString *s_name = [loc objectForKey:@"site_name"];
        NSString *s_id = [loc objectForKey:@"id"];
        //NSString *f_id = [loc objectForKey:@"feature_id"];
        NSString *f_type = [loc objectForKey:@"feature_type"];
        NSString *p_id = [loc objectForKey:@"park_id"];
        
        NSString *parkCode;
        //if ([f_type isEqualToString:@"PAVILION"]) {
        //    parkCode = [NSString stringWithFormat:@"%@-%@-%@", p_id,f_id,s_name];
        //} else {
            parkCode = [NSString stringWithFormat:@"%@-%@-%@", p_id,s_id,s_name];
        //}
        
        if ([searchItem isEqualToString:@"Parks"]) {
            ParksAnnotation *ann1 = [[ParksAnnotation alloc] init];
            ann1.title = title;
            ann1.subtitle = parkCode;
            ann1.coordinate = location;
            [self.mapView addAnnotation:ann1];
        } else if ([searchItem isEqualToString:@"Playgrounds"]) {
            PlaygroundsAnnotation *ann2 = [[PlaygroundsAnnotation alloc] init];
            ann2.title = title;
            ann2.subtitle = parkCode;
            ann2.coordinate = location;
            [self.mapView addAnnotation:ann2];
        } else if ([searchItem isEqualToString:@"Pavilions"]) {
            PavilionsAnnotation *ann3 = [[PavilionsAnnotation alloc] init];
            ann3.title = title;
            ann3.subtitle = parkCode;
            ann3.coordinate = location;
            [self.mapView addAnnotation:ann3];
        } else if ([searchItem isEqualToString:@"Historic Sites"]) {
            HistoricSitesAnnotation *ann4 = [[HistoricSitesAnnotation alloc] init];
            ann4.title = title;
            ann4.subtitle = parkCode;
            ann4.coordinate = location;
            [self.mapView addAnnotation:ann4];
        } else {
            if ([f_type isEqualToString:@"BALLFIELD"]) {
                BaseballFieldAnnotation *ann5 = [[BaseballFieldAnnotation alloc] init];
                ann5.title = title;
                ann5.subtitle = parkCode;
                ann5.coordinate = location;
                [self.mapView addAnnotation:ann5];
            } else if ([f_type isEqualToString:@"BASKETBALL"]) {
                BasketballCourtAnnotation *ann6 = [[BasketballCourtAnnotation alloc] init];
                ann6.title = title;
                ann6.subtitle = parkCode;
                ann6.coordinate = location;
                [self.mapView addAnnotation:ann6];
            } else if ([f_type isEqualToString:@"CRICKET"]) {
                CricketFieldAnnotation *ann7 = [[CricketFieldAnnotation alloc] init];
                ann7.title = title;
                ann7.subtitle = parkCode;
                ann7.coordinate = location;
                [self.mapView addAnnotation:ann7];
            } else if ([f_type isEqualToString:@"DISCGOLF"]) {
                DiscGolfCourseAnnotation *ann8 = [[DiscGolfCourseAnnotation alloc] init];
                ann8.title = title;
                ann8.subtitle = parkCode;
                ann8.coordinate = location;
                [self.mapView addAnnotation:ann8];
            } else if ([f_type isEqualToString:@"FIRERING"]) {
                FireRingAnnotation *ann9 = [[FireRingAnnotation alloc] init];
                ann9.title = title;
                ann9.subtitle = parkCode;
                ann9.coordinate = location;
                [self.mapView addAnnotation:ann9];
            } else if ([f_type isEqualToString:@"FISHING"]) {
                FishingAnnotation *ann10 = [[FishingAnnotation alloc] init];
                ann10.title = title;
                ann10.subtitle = parkCode;
                ann10.coordinate = location;
                [self.mapView addAnnotation:ann10];
            } else if ([f_type isEqualToString:@"HANDBALL"]) {
                HandballCourtAnnotation *ann11 = [[HandballCourtAnnotation alloc] init];
                ann11.title = title;
                ann11.subtitle = parkCode;
                ann11.coordinate = location;
                [self.mapView addAnnotation:ann11];
            } else if ([f_type isEqualToString:@"HOCKEYRINK"]) {
                HockeyRinkAnnotation *ann12 = [[HockeyRinkAnnotation alloc] init];
                ann12.title = title;
                ann12.subtitle = parkCode;
                ann12.coordinate = location;
                [self.mapView addAnnotation:ann12];
            } else if ([f_type isEqualToString:@"HORSESHOE"]) {
                HorseshoePitAnnotation *ann13 = [[HorseshoePitAnnotation alloc] init];
                ann13.title = title;
                ann13.subtitle = parkCode;
                ann13.coordinate = location;
                [self.mapView addAnnotation:ann13];
            } else if ([f_type isEqualToString:@"MULTIPURPOSE"]) {
                MultipurposeFieldAnnotation *ann14 = [[MultipurposeFieldAnnotation alloc] init];
                ann14.title = title;
                ann14.subtitle = parkCode;
                ann14.coordinate = location;
                [self.mapView addAnnotation:ann14];
            } else if ([f_type isEqualToString:@"RQBALL"]) {
                RacquetballCourtAnnotation *ann15 = [[RacquetballCourtAnnotation alloc] init];
                ann15.title = title;
                ann15.subtitle = parkCode;
                ann15.coordinate = location;
                [self.mapView addAnnotation:ann15];
            } else if ([f_type isEqualToString:@"SKATESPOT"]) {
                SkatespotAnnotation *ann16 = [[SkatespotAnnotation alloc] init];
                ann16.title = title;
                ann16.subtitle = parkCode;
                ann16.coordinate = location;
                [self.mapView addAnnotation:ann16];
            } else if ([f_type isEqualToString:@"TENNIS"]) {
                TennisCourtAnnotation *ann17 = [[TennisCourtAnnotation alloc] init];
                ann17.title = title;
                ann17.subtitle = parkCode;
                ann17.coordinate = location;
                [self.mapView addAnnotation:ann17];
            } else if ([f_type isEqualToString:@"VOLLEYBALL"]) {
                VolleyballCourtAnnotation *ann18 = [[VolleyballCourtAnnotation alloc] init];
                ann18.title = title;
                ann18.subtitle = parkCode;
                ann18.coordinate = location;
                [self.mapView addAnnotation:ann18];
            } else if ([f_type isEqualToString:@"PICNICTABLE"]) {
                PicnicTableAnnotation *ann19 = [[PicnicTableAnnotation alloc] init];
                ann19.title = title;
                ann19.subtitle = parkCode;
                ann19.coordinate = location;
                [self.mapView addAnnotation:ann19];
            } else if ([f_type isEqualToString:@"GRILL"]) {
                GrillAnnotation *ann20 = [[GrillAnnotation alloc] init];
                ann20.title = title;
                ann20.subtitle = parkCode;
                ann20.coordinate = location;
                [self.mapView addAnnotation:ann20];
            } else if ([f_type isEqualToString:@"EQUESTRIAN"]) {
                EquestrianAnnotation *ann21 = [[EquestrianAnnotation alloc] init];
                ann21.title = title;
                ann21.subtitle = parkCode;
                ann21.coordinate = location;
                [self.mapView addAnnotation:ann21];
            } else if ([f_type isEqualToString:@"PLAYGROUND"]) {
                PlaygroundsAnnotation *ann22 = [[PlaygroundsAnnotation alloc] init];
                ann22.title = title;
                ann22.subtitle = parkCode;
                ann22.coordinate = location;
                [self.mapView addAnnotation:ann22];
            } else if ([f_type isEqualToString:@"PAVILION"]) {
                PavilionsAnnotation *ann23 = [[PavilionsAnnotation alloc] init];
                ann23.title = title;
                ann23.subtitle = parkCode;
                ann23.coordinate = location;
                [self.mapView addAnnotation:ann23];
            } else if ([f_type isEqualToString:@"TRAILHEAD"]) {
                TrailsAnnotation *ann24 = [[TrailsAnnotation alloc] init];
                ann24.title = title;
                ann24.subtitle = parkCode;
                ann24.coordinate = location;
                [self.mapView addAnnotation:ann24];
            } else if ([f_type isEqualToString:@"RESTROOM"]) {
                RestroomsAnnotation *ann25 = [[RestroomsAnnotation alloc] init];
                ann25.title = title;
                ann25.subtitle = parkCode;
                ann25.coordinate = location;
                [self.mapView addAnnotation:ann25];
            } else if ([f_type isEqualToString:@"BUILDING"]) {
                BuildingAnnotation *ann26 = [[BuildingAnnotation alloc] init];
                ann26.title = title;
                ann26.subtitle = parkCode;
                ann26.coordinate = location;
                [self.mapView addAnnotation:ann26];
            } else if ([f_type isEqualToString:@"DOG"]) {
                DogAnnotation *ann27 = [[DogAnnotation alloc] init];
                ann27.title = title;
                ann27.subtitle = parkCode;
                ann27.coordinate = location;
                [self.mapView addAnnotation:ann27];
            } else if ([f_type isEqualToString:@"ENTRANCE"]) {
                EntranceAnnotation *ann28 = [[EntranceAnnotation alloc] init];
                ann28.title = title;
                ann28.subtitle = parkCode;
                ann28.coordinate = location;
                [self.mapView addAnnotation:ann28];
            } else if ([f_type isEqualToString:@"PARKING"]) {
                ParkingAnnotation *ann29 = [[ParkingAnnotation alloc] init];
                ann29.title = title;
                ann29.subtitle = parkCode;
                ann29.coordinate = location;
                [self.mapView addAnnotation:ann29];
            } else if ([f_type isEqualToString:@"SKILLSPARK"]) {
                SkillsParkAnnotation *ann30 = [[SkillsParkAnnotation alloc] init];
                ann30.title = title;
                ann30.subtitle = parkCode;
                ann30.coordinate = location;
                [self.mapView addAnnotation:ann30];
            } else if ([f_type isEqualToString:@"BOCCEBALL"]) {
                BocceBallAnnotation *ann31 = [[BocceBallAnnotation alloc] init];
                ann31.title = title;
                ann31.subtitle = parkCode;
                ann31.coordinate = location;
                [self.mapView addAnnotation:ann31];
            } else if ([f_type isEqualToString:@"AMPHITHEATER"]) {
                AmphitheaterAnnotation *ann32 = [[AmphitheaterAnnotation alloc] init];
                ann32.title = title;
                ann32.subtitle = parkCode;
                ann32.coordinate = location;
                [self.mapView addAnnotation:ann32];
            } else if ([f_type isEqualToString:@"OBSERVATORY"]) {
                ObservatoryAnnotation *ann33 = [[ObservatoryAnnotation alloc] init];
                ann33.title = title;
                ann33.subtitle = parkCode;
                ann33.coordinate = location;
                [self.mapView addAnnotation:ann33];
            } else if ([f_type isEqualToString:@"BOATRAMP"]) {
                BoatRampAnnotation *ann34 = [[BoatRampAnnotation alloc] init];
                ann34.title = title;
                ann34.subtitle = parkCode;
                ann34.coordinate = location;
                [self.mapView addAnnotation:ann34];
            } else if ([f_type isEqualToString:@"GAZEBO"]) {
                GazeboAnnotation *ann35 = [[GazeboAnnotation alloc] init];
                ann35.title = title;
                ann35.subtitle = parkCode;
                ann35.coordinate = location;
                [self.mapView addAnnotation:ann35];
            } else if ([f_type isEqualToString:@"PARK"]) {
                ParksAnnotation *ann36 = [[ParksAnnotation alloc] init];
                ann36.title = title;
                ann36.subtitle = parkCode;
                ann36.coordinate = location;
                [self.mapView addAnnotation:ann36];
            } else if ([f_type isEqualToString:@"HISTORIC"]) {
                HistoricSitesAnnotation *ann37 = [[HistoricSitesAnnotation alloc] init];
                ann37.title = title;
                ann37.subtitle = parkCode;
                ann37.coordinate = location;
                [self.mapView addAnnotation:ann37];
            } else if ([f_type isEqualToString:@"ARCHERY"]) {
                ArcheryAnnotation *ann38 = [[ArcheryAnnotation alloc] init];
                ann38.title = title;
                ann38.subtitle = parkCode;
                ann38.coordinate = location;
                [self.mapView addAnnotation:ann38];
            }
        }
        
    }
}
-(MKAnnotationView *)mapView:(MKMapView *)mView viewForAnnotation:(id <MKAnnotation>)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    UIButton *informationBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    informationBTN.frame = CGRectMake(0, 0, 32, 32);
    informationBTN.tag = 0;
    [informationBTN setBackgroundImage:[UIImage imageNamed:@"Info.png"] forState:UIControlStateNormal];
    informationBTN.backgroundColor = [UIColor clearColor];
    
    UIButton *directionBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    directionBTN.frame = CGRectMake(0, 0, 32, 32);
    directionBTN.tag = 1;
    [directionBTN setBackgroundImage:[UIImage imageNamed:@"DrivingDirection.png"] forState:UIControlStateNormal];
    directionBTN.backgroundColor = [UIColor clearColor];
    
    UIButton *elevationProfileBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    elevationProfileBTN.frame = CGRectMake(0, 0, 32, 32);
    elevationProfileBTN.tag = 2;
    [elevationProfileBTN setBackgroundImage:[UIImage imageNamed:@"Profile.png"] forState:UIControlStateNormal];
    elevationProfileBTN.backgroundColor = [UIColor blackColor];
    
    if ([annotation isKindOfClass:[BaseballFieldAnnotation class]]) {
        static NSString *annotationIdentifier1 = @"AnnotationIdentifier1";
        MKAnnotationView *pinView1 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier1];
        if (!pinView1) {
            MKAnnotationView *annotationView1 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:annotationIdentifier1];
            annotationView1.canShowCallout = YES;
            imgname = @"BALLFIELD_2.png";
            annotationView1.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView1.opaque = NO;
            annotationView1.leftCalloutAccessoryView = directionBTN;
            return annotationView1;
        }
        return pinView1;
    } else if ([annotation isKindOfClass:[BasketballCourtAnnotation class]]) {
        static NSString *annotationIdentifier2 = @"AnnotationIdentifier2";
        MKAnnotationView *pinView2 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier2];
        if (!pinView2) {
            MKAnnotationView *annotationView2 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:annotationIdentifier2];
            annotationView2.canShowCallout = YES;
            imgname = @"BASKETBALL_2.png";
            annotationView2.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView2.opaque = NO;
            annotationView2.leftCalloutAccessoryView = directionBTN;
            return annotationView2;
        }
        return pinView2;
    } else if ([annotation isKindOfClass:[DiscGolfCourseAnnotation class]]) {
        static NSString *annotationIdentifier3 = @"AnnotationIdentifier3";
        MKAnnotationView *pinView3 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier3];
        if (!pinView3) {
            MKAnnotationView *annotationView3 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:annotationIdentifier3];
            annotationView3.canShowCallout = YES;
            imgname = @"DISCGOLF_2.png";
            annotationView3.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView3.opaque = NO;
            annotationView3.leftCalloutAccessoryView = directionBTN;
            return annotationView3;
        }
        return pinView3;
    } else if ([annotation isKindOfClass:[FireRingAnnotation class]]) {
        static NSString *annotationIdentifier4 = @"AnnotationIdentifier4";
        MKAnnotationView *pinView4 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier4];
        if (!pinView4) {
            MKAnnotationView *annotationView4 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:annotationIdentifier4];
            annotationView4.canShowCallout = YES;
            imgname = @"FIRERING_2.png";
            annotationView4.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView4.opaque = NO;
            annotationView4.leftCalloutAccessoryView = directionBTN;
            return annotationView4;
        }
        return pinView4;
    } else if ([annotation isKindOfClass:[FishingAnnotation class]]) {
        static NSString *annotationIdentifier5 = @"AnnotationIdentifier5";
        MKAnnotationView *pinView5 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier5];
        if (!pinView5) {
            MKAnnotationView *annotationView5 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:annotationIdentifier5];
            annotationView5.canShowCallout = YES;
            imgname = @"FISHING_2.png";
            annotationView5.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView5.opaque = NO;
            annotationView5.leftCalloutAccessoryView = directionBTN;
            return annotationView5;
        }
        return pinView5;
    } else if ([annotation isKindOfClass:[HandballCourtAnnotation class]]) {
        static NSString *annotationIdentifier6 = @"AnnotationIdentifier6";
        MKAnnotationView *pinView6 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier6];
        if (!pinView6) {
            MKAnnotationView *annotationView6 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:annotationIdentifier6];
            annotationView6.canShowCallout = YES;
            imgname = @"HANDBALL_2.png";
            annotationView6.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView6.opaque = NO;
            annotationView6.leftCalloutAccessoryView = directionBTN;
            return annotationView6;
        }
        return pinView6;
    } else if ([annotation isKindOfClass:[HockeyRinkAnnotation class]]) {
        static NSString *annotationIdentifier7 = @"AnnotationIdentifier7";
        MKAnnotationView *pinView7 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier7];
        if (!pinView7) {
            MKAnnotationView *annotationView7 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:annotationIdentifier7];
            annotationView7.canShowCallout = YES;
            imgname = @"HOCKEYRINK_2.png";
            annotationView7.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView7.opaque = NO;
            annotationView7.leftCalloutAccessoryView = directionBTN;
            return annotationView7;
        }
        return pinView7;
    } else if ([annotation isKindOfClass:[HorseshoePitAnnotation class]]) {
        static NSString *annotationIdentifier8 = @"AnnotationIdentifier8";
        MKAnnotationView *pinView8 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier8];
        if (!pinView8) {
            MKAnnotationView *annotationView8 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:annotationIdentifier8];
            annotationView8.canShowCallout = YES;
            imgname = @"HORSESHOE_2.png";
            annotationView8.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView8.opaque = NO;
            annotationView8.leftCalloutAccessoryView = directionBTN;
            return annotationView8;
        }
        return pinView8;
    } else if ([annotation isKindOfClass:[MultipurposeFieldAnnotation class]]) {
        static NSString *annotationIdentifier9 = @"AnnotationIdentifier9";
        MKAnnotationView *pinView9 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier9];
        if (!pinView9) {
            MKAnnotationView *annotationView9 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:annotationIdentifier9];
            annotationView9.canShowCallout = YES;
            imgname = @"MULTIPURPOSE_2.png";
            annotationView9.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView9.opaque = NO;
            annotationView9.leftCalloutAccessoryView = directionBTN;
            return annotationView9;
        }
        return pinView9;
    } else if ([annotation isKindOfClass:[RacquetballCourtAnnotation class]]) {
        static NSString *annotationIdentifier10 = @"AnnotationIdentifier10";
        MKAnnotationView *pinView10 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier10];
        if (!pinView10) {
            MKAnnotationView *annotationView10 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier10];
            annotationView10.canShowCallout = YES;
            imgname = @"RQBALL_2.png";
            annotationView10.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView10.opaque = NO;
            annotationView10.leftCalloutAccessoryView = directionBTN;
            return annotationView10;
        }
        return pinView10;
    } else if ([annotation isKindOfClass:[SkatespotAnnotation class]]) {
        static NSString *annotationIdentifier11 = @"AnnotationIdentifier11";
        MKAnnotationView *pinView11 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier11];
        if (!pinView11) {
            MKAnnotationView *annotationView11 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier11];
            annotationView11.canShowCallout = YES;
            imgname = @"SKATESPOT_2.png";
            annotationView11.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView11.opaque = NO;
            annotationView11.leftCalloutAccessoryView = directionBTN;
            return annotationView11;
        }
        return pinView11;
    } else if ([annotation isKindOfClass:[TennisCourtAnnotation class]]) {
        static NSString *annotationIdentifier13 = @"AnnotationIdentifier13";
        MKAnnotationView *pinView13 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier13];
        if (!pinView13) {
            MKAnnotationView *annotationView13 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier13];
            annotationView13.canShowCallout = YES;
            imgname = @"TENNIS_2.png";
            annotationView13.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView13.opaque = NO;
            annotationView13.leftCalloutAccessoryView = directionBTN;
            return annotationView13;
        }
        return pinView13;
    } else if ([annotation isKindOfClass:[VolleyballCourtAnnotation class]]) {
        static NSString *annotationIdentifier14 = @"AnnotationIdentifier14";
        MKAnnotationView *pinView14 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier14];
        if (!pinView14) {
            MKAnnotationView *annotationView14 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier14];
            annotationView14.canShowCallout = YES;
            imgname = @"VOLLEYBALL_2.png";
            annotationView14.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView14.opaque = NO;
            annotationView14.leftCalloutAccessoryView = directionBTN;
            return annotationView14;
        }
        return pinView14;
    } else if ([annotation isKindOfClass:[PavilionsAnnotation class]]) {
        static NSString *annotationIdentifier15 = @"AnnotationIdentifier15";
        MKAnnotationView *pinView15 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier15];
        if (!pinView15) {
            MKAnnotationView *annotationView15 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier15];
            annotationView15.canShowCallout = YES;
            imgname = @"PAVILION_2.png";
            annotationView15.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView15.opaque = NO;
            /*if ([searchItem isEqualToString:@"Parks"]
                || [searchItem isEqualToString:@"Pavilions"]
                || [searchItem isEqualToString:@"Playgrounds"]
                || [searchItem isEqualToString:@"Historic Sites"]) {*/
                annotationView15.rightCalloutAccessoryView = informationBTN;
            //}
            
            annotationView15.leftCalloutAccessoryView = directionBTN;
            return annotationView15;
        }
        return pinView15;
    } else if ([annotation isKindOfClass:[PlaygroundsAnnotation class]]) {
        static NSString *annotationIdentifier16 = @"AnnotationIdentifier16";
        MKAnnotationView *pinView16 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier16];
        if (!pinView16) {
            MKAnnotationView *annotationView16 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier16];
            annotationView16.canShowCallout = YES;
            imgname = @"PLAYGROUND_2.png";
            annotationView16.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView16.opaque = NO;
            /*if ([searchItem isEqualToString:@"Parks"]
                || [searchItem isEqualToString:@"Pavilions"]
                || [searchItem isEqualToString:@"Playgrounds"]
                || [searchItem isEqualToString:@"Historic Sites"]) {*/
                annotationView16.rightCalloutAccessoryView = informationBTN;
            //}
            annotationView16.leftCalloutAccessoryView = directionBTN;
            return annotationView16;
        }
        return pinView16;
    } else if ([annotation isKindOfClass:[ParksAnnotation class]]) {
        static NSString *annotationIdentifier17 = @"AnnotationIdentifier17";
        MKAnnotationView *pinView17 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier17];
        if (!pinView17) {
            MKAnnotationView *annotationView17 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier17];
            annotationView17.canShowCallout = YES;
            imgname = @"PARK_2.png";
            annotationView17.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView17.opaque = NO;
            /*if ([searchItem isEqualToString:@"Parks"]
                || [searchItem isEqualToString:@"Pavilions"]
                || [searchItem isEqualToString:@"Playgrounds"]
                || [searchItem isEqualToString:@"Historic Sites"]) {*/
                annotationView17.rightCalloutAccessoryView = informationBTN;
            //}
            annotationView17.leftCalloutAccessoryView = directionBTN;
            return annotationView17;
        }
        return pinView17;
    } else if ([annotation isKindOfClass:[HistoricSitesAnnotation class]]) {
        static NSString *annotationIdentifier18 = @"AnnotationIdentifier18";
        MKAnnotationView *pinView18 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier18];
        if (!pinView18) {
            MKAnnotationView *annotationView18 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier18];
            annotationView18.canShowCallout = YES;
            imgname = @"HISTORIC_2.png";
            annotationView18.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView18.opaque = NO;
            /*if ([searchItem isEqualToString:@"Parks"]
                || [searchItem isEqualToString:@"Pavilions"]
                || [searchItem isEqualToString:@"Playgrounds"]
                || [searchItem isEqualToString:@"Historic Sites"]) {*/
                annotationView18.rightCalloutAccessoryView = informationBTN;
            //}
            annotationView18.leftCalloutAccessoryView = directionBTN;
            return annotationView18;
        }
        return pinView18;
    } else if ([annotation isKindOfClass:[BlankAnnotation class]]) {
        static NSString *annotationIdentifier19 = @"AnnotationIdentifier19";
        MKAnnotationView *pinView19 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier19];
        if (!pinView19) {
            MKAnnotationView *annotationView19 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier19];
            annotationView19.canShowCallout = YES;
            imgname = @"Blank.png";
            annotationView19.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView19.opaque = NO;
            annotationView19.leftCalloutAccessoryView = directionBTN;
            return annotationView19;
        }
        return pinView19;
    } else if ([annotation isKindOfClass:[TrailsAnnotation class]]) {
        static NSString *annotationIdentifier20 = @"AnnotationIdentifier20";
        MKAnnotationView *pinView20 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier20];
        if (!pinView20) {
            MKAnnotationView *annotationView20 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier20];
            annotationView20.canShowCallout = YES;
            imgname = @"TRAILHEAD_2.png";
            annotationView20.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView20.opaque = NO;
            annotationView20.leftCalloutAccessoryView = directionBTN;
            return annotationView20;
        }
        return pinView20;
    } else if ([annotation isKindOfClass:[RestroomsAnnotation class]]) {
        static NSString *annotationIdentifier21 = @"AnnotationIdentifier21";
        MKAnnotationView *pinView21 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier21];
        if (!pinView21) {
            MKAnnotationView *annotationView21 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier21];
            annotationView21.canShowCallout = YES;
            imgname = @"RESTROOM_2.png";
            annotationView21.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView21.opaque = NO;
            annotationView21.leftCalloutAccessoryView = directionBTN;
            return annotationView21;
        }
        return pinView21;
    } else if ([annotation isKindOfClass:[CricketFieldAnnotation class]]) {
        static NSString *annotationIdentifier22 = @"AnnotationIdentifier22";
        MKAnnotationView *pinView22 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier22];
        if (!pinView22) {
            MKAnnotationView *annotationView22 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier22];
            annotationView22.canShowCallout = YES;
            imgname = @"CRICKET_2.png";
            annotationView22.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView22.opaque = NO;
            annotationView22.leftCalloutAccessoryView = directionBTN;
            return annotationView22;
        }
        return pinView22;
    } else if ([annotation isKindOfClass:[StartAnnotation class]]) {
        static NSString *annotationIdentifier23 = @"AnnotationIdentifier23";
        MKAnnotationView *pinView23 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier23];
        if (!pinView23) {
            MKAnnotationView *annotationView23 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier23];
            annotationView23.canShowCallout = YES;
            imgname = @"Start.png";
            annotationView23.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:32];
            annotationView23.opaque = NO;
            return annotationView23;
        }
        return pinView23;
    } else if ([annotation isKindOfClass:[EndAnnotation class]]) {
        static NSString *annotationIdentifier24 = @"AnnotationIdentifier24";
        MKAnnotationView *pinView24 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier24];
        if (!pinView24) {
            MKAnnotationView *annotationView24 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier24];
            annotationView24.canShowCallout = YES;
            imgname = @"End.png";
            annotationView24.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:32];
            annotationView24.opaque = NO;
            return annotationView24;
        }
        return pinView24;
    } else if ([annotation isKindOfClass:[PicnicTableAnnotation class]]) {
        static NSString *annotationIdentifier25 = @"AnnotationIdentifier25";
        MKAnnotationView *pinView25 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier25];
        if (!pinView25) {
            MKAnnotationView *annotationView25 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier25];
            annotationView25.canShowCallout = YES;
            imgname = @"PICNICTABLE_2.png";
            annotationView25.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView25.opaque = NO;
            annotationView25.leftCalloutAccessoryView = directionBTN;
            return annotationView25;
        }
        return pinView25;
    } else if ([annotation isKindOfClass:[GrillAnnotation class]]) {
        static NSString *annotationIdentifier26 = @"AnnotationIdentifier26";
        MKAnnotationView *pinView26 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier26];
        if (!pinView26) {
            MKAnnotationView *annotationView26 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier26];
            annotationView26.canShowCallout = YES;
            imgname = @"GRILL_2.png";
            annotationView26.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView26.opaque = NO;
            annotationView26.leftCalloutAccessoryView = directionBTN;
            return annotationView26;
        }
        return pinView26;
    } else if ([annotation isKindOfClass:[EquestrianAnnotation class]]) {
        static NSString *annotationIdentifier27 = @"AnnotationIdentifier27";
        MKAnnotationView *pinView27 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier27];
        if (!pinView27) {
            MKAnnotationView *annotationView27 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier27];
            annotationView27.canShowCallout = YES;
            imgname = @"EQUESTRIAN_2.png";
            annotationView27.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView27.opaque = NO;
            annotationView27.leftCalloutAccessoryView = directionBTN;
            return annotationView27;
        }
        return pinView27;
    } else if ([annotation isKindOfClass:[EmptyAnnotation class]]) {
        static NSString *annotationIdentifier28 = @"AnnotationIdentifier28";
        MKAnnotationView *pinView28 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier28];
        if (!pinView28) {
            MKAnnotationView *annotationView28 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier28];
            annotationView28.canShowCallout = YES;
            imgname = @"Blank.png";
            annotationView28.opaque = NO;
            annotationView28.rightCalloutAccessoryView = informationBTN;
            annotationView28.leftCalloutAccessoryView = directionBTN;
            return annotationView28;
        }
        return pinView28;
    } else if ([annotation isKindOfClass:[ProfileAnnotation class]]) {
        static NSString *annotationIdentifier29 = @"AnnotationIdentifier29";
        MKAnnotationView *pinView29 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier29];
        if (!pinView29) {
            MKAnnotationView *annotationView29 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier29];
            annotationView29.canShowCallout = YES;
            imgname = @"Blank.png";
            annotationView29.leftCalloutAccessoryView = elevationProfileBTN;
            return annotationView29;
        }
        return pinView29;
    } else if ([annotation isKindOfClass:[BuildingAnnotation class]]) {
        static NSString *annotationIdentifier30 = @"AnnotationIdentifier30";
        MKAnnotationView *pinView30 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier30];
        if (!pinView30) {
            MKAnnotationView *annotationView30 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier30];
            annotationView30.canShowCallout = YES;
            imgname = @"BUILDING_2.png";
            annotationView30.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView30.opaque = NO;
            annotationView30.leftCalloutAccessoryView = directionBTN;
            return annotationView30;
        }
        return pinView30;
    } else if ([annotation isKindOfClass:[DogAnnotation class]]) {
        static NSString *annotationIdentifier31 = @"AnnotationIdentifier31";
        MKAnnotationView *pinView31 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier31];
        if (!pinView31) {
            MKAnnotationView *annotationView31 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier31];
            annotationView31.canShowCallout = YES;
            imgname = @"DOG_2.png";
            annotationView31.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView31.opaque = NO;
            annotationView31.leftCalloutAccessoryView = directionBTN;
            return annotationView31;
        }
        return pinView31;
    } else if ([annotation isKindOfClass:[EntranceAnnotation class]]) {
        static NSString *annotationIdentifier32 = @"AnnotationIdentifier32";
        MKAnnotationView *pinView32 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier32];
        if (!pinView32) {
            MKAnnotationView *annotationView32 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier32];
            annotationView32.canShowCallout = YES;
            imgname = @"ENTRANCE_2.png";
            annotationView32.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView32.opaque = NO;
            annotationView32.leftCalloutAccessoryView = directionBTN;
            return annotationView32;
        }
        return pinView32;
    } else if ([annotation isKindOfClass:[ParkingAnnotation class]]) {
        static NSString *annotationIdentifier33 = @"AnnotationIdentifier33";
        MKAnnotationView *pinView33 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier33];
        if (!pinView33) {
            MKAnnotationView *annotationView33 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier33];
            annotationView33.canShowCallout = YES;
            imgname = @"PARKING_2.png";
            annotationView33.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView33.opaque = NO;
            annotationView33.leftCalloutAccessoryView = directionBTN;
            return annotationView33;
        }
        return pinView33;
    } else if ([annotation isKindOfClass:[SkillsParkAnnotation class]]) {
        static NSString *annotationIdentifier34 = @"AnnotationIdentifier34";
        MKAnnotationView *pinView34 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier34];
        if (!pinView34) {
            MKAnnotationView *annotationView34 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier34];
            annotationView34.canShowCallout = YES;
            imgname = @"SKILLSPARK_2.png";
            annotationView34.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView34.opaque = NO;
            annotationView34.leftCalloutAccessoryView = directionBTN;
            return annotationView34;
        }
        return pinView34;
    } else if ([annotation isKindOfClass:[BocceBallAnnotation class]]) {
        static NSString *annotationIdentifier35 = @"AnnotationIdentifier35";
        MKAnnotationView *pinView35 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier35];
        if (!pinView35) {
            MKAnnotationView *annotationView35 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier35];
            annotationView35.canShowCallout = YES;
            imgname = @"BOCCEBALL_2.png";
            annotationView35.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView35.opaque = NO;
            annotationView35.leftCalloutAccessoryView = directionBTN;
            return annotationView35;
        }
        return pinView35;
    } else if ([annotation isKindOfClass:[AmphitheaterAnnotation class]]) {
        static NSString *annotationIdentifier36 = @"AnnotationIdentifier36";
        MKAnnotationView *pinView36 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier36];
        if (!pinView36) {
            MKAnnotationView *annotationView36 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier36];
            annotationView36.canShowCallout = YES;
            imgname = @"AMPHITHEATER_2.png";
            annotationView36.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView36.opaque = NO;
            annotationView36.leftCalloutAccessoryView = directionBTN;
            return annotationView36;
        }
        return pinView36;
    } else if ([annotation isKindOfClass:[ObservatoryAnnotation class]]) {
        static NSString *annotationIdentifier37 = @"AnnotationIdentifier37";
        MKAnnotationView *pinView37 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier37];
        if (!pinView37) {
            MKAnnotationView *annotationView37 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier37];
            annotationView37.canShowCallout = YES;
            imgname = @"OBSERVATORY_2.png";
            annotationView37.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView37.opaque = NO;
            annotationView37.leftCalloutAccessoryView = directionBTN;
            return annotationView37;
        }
        return pinView37;
    } else if ([annotation isKindOfClass:[BoatRampAnnotation class]]) {
        static NSString *annotationIdentifier38 = @"AnnotationIdentifier38";
        MKAnnotationView *pinView38 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier38];
        if (!pinView38) {
            MKAnnotationView *annotationView38 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier38];
            annotationView38.canShowCallout = YES;
            imgname = @"BOATRAMP_2.png";
            annotationView38.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView38.opaque = NO;
            annotationView38.leftCalloutAccessoryView = directionBTN;
            return annotationView38;
        }
        return pinView38;
    } else if ([annotation isKindOfClass:[GazeboAnnotation class]]) {
        static NSString *annotationIdentifier39 = @"AnnotationIdentifier39";
        MKAnnotationView *pinView39 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier39];
        if (!pinView39) {
            MKAnnotationView *annotationView39 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier39];
            annotationView39.canShowCallout = YES;
            imgname = @"GAZEBO_2.png";
            annotationView39.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView39.opaque = NO;
            annotationView39.leftCalloutAccessoryView = directionBTN;
            return annotationView39;
        }
        return pinView39;
    } else if ([annotation isKindOfClass:[ArcheryAnnotation class]]) {
        static NSString *annotationIdentifier40 = @"AnnotationIdentifier40";
        MKAnnotationView *pinView40 = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier40];
        if (!pinView40) {
            MKAnnotationView *annotationView40 = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                              reuseIdentifier:annotationIdentifier40];
            annotationView40.canShowCallout = YES;
            imgname = @"ARCHERY_2.png";
            annotationView40.image = [ParksViewController resizeIMG:(NSString *)imgname mv:(UIView *)self.view size:24];
            annotationView40.opaque = NO;
            annotationView40.leftCalloutAccessoryView = directionBTN;
            return annotationView40;
        }
        return pinView40;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mv annotationView:(MKAnnotationView *)pin calloutAccessoryControlTapped:(UIControl *)control {
    [indicator startAnimating];
    if ([control isKindOfClass:[UIButton class]]) {
        if (control.tag == 0) {
            Annotation *theAnnotation = (Annotation *) pin.annotation;
            NSArray *myArray = [theAnnotation.subtitle componentsSeparatedByString:@"-"];
            self.park_id = [myArray objectAtIndex:0];
            self.site_id = [myArray objectAtIndex:1];
            self.site_name = [myArray objectAtIndex:2];
            [self prepareOpenViewFromPin];
        } else if (control.tag == 1) {
            Annotation *theAnnotation = (Annotation *) pin.annotation;
            NSArray *myArray = [theAnnotation.subtitle componentsSeparatedByString:@"-"];
            self.park_id = [myArray objectAtIndex:0];
            self.site_id = [myArray objectAtIndex:1];
            self.site_name = [myArray objectAtIndex:2];
            [self openGoogleDirection];
        } else if (control.tag == 2) {
            NSMutableArray *myprofile;
            myprofile = [GetJSON getProfile:(NSMutableArray *)self.trails];
            [self openProfile:(NSMutableArray *)myprofile];
        }
    }
}
-(void)openGoogleDirection {
    NSInteger wifiAvailable = [NearestResultViewController checkAvailableWiFi];
    NSInteger netAvailable = [NearestResultViewController checkAvailableInternet];
    if (wifiAvailable == 1) {
        [self hasDirection];
    } else if (wifiAvailable == 0) {
        if (netAvailable == 2) {
            [self hasDirection];
        } else if (netAvailable == 0) {
            [self presentViewController:[CustomAlert openMenuInformation:@"No access to www.google.com for driving or walking directions." mtitle:@"Access Not Available"] animated:YES completion:nil];
            [indicator stopAnimating];
        }
    }
}
-(void)hasDirection {
    NSMutableArray *pindata;
    if([amenitiesDisplay isEqualToString:@"ON"]) {
        pindata = self.amenities;
    } else if([amenitiesDisplay isEqualToString:@"OFF"]) {
        pindata = self.parks;
    }
    double destLat = 0.0, destLng = 0.0;
    for (int i = 0; i < [pindata count]; i++) {
        NSDictionary *loc = [pindata objectAtIndex:i];
        NSString *sid = [loc objectForKey:@"id"];
        if ([sid isEqualToString:self.site_id]) {
            destLat = [[loc objectForKey:@"latitude"]doubleValue];
            destLng = [[loc objectForKey:@"longitude"]doubleValue];
            
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps-x-callback://"]]) {
                NSString *gURL = [NSString stringWithFormat:@"comgooglemaps-x-callback://?daddr=%f,%f&center=%f,%f&directionsmode=driving&zoom=14&x-success=gov.howardcountymd.iOSHoCoParks://?resume=true&x-source=Parks", destLat, destLng,destLat, destLng];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:gURL]];
            } else {
                //NSLog(@"Can't use comgooglemaps://");
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:@"Google Maps Not Found"
                                                      message:@"Google Maps App is required for this device."
                                                      preferredStyle:UIAlertControllerStyleAlert];
                

                
                UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Get Google Maps App"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action)
                                           {
                                               [self getGoogleMapsApp];
                                           }];
                
                UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:^(UIAlertAction * action)
                                               {
                                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                                               }];
                
                [alertController addAction:actionOk];
                [alertController addAction:actionCancel];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }
}
-(void)prepareOpenViewFromPin {
    NSMutableArray *pindata;
    if([amenitiesDisplay isEqualToString:@"ON"]) {
        pindata = self.amenities;
    } else if([amenitiesDisplay isEqualToString:@"OFF"]) {
        pindata = self.parks;
    }
    for (int i = 0; i < [pindata count]; i++) {
        NSDictionary *loc = [pindata objectAtIndex:i];
        NSString *sid = [loc objectForKey:@"id"];
        if ([sid isEqualToString:self.site_id]) {
            self.feature_id = [loc objectForKey:@"feature_id"];
            self.feature_type = [loc objectForKey:@"feature_type"];
            self.feature_name = [loc objectForKey:@"feature_name"];
            self.latItem = [[loc objectForKey:@"latitude"]doubleValue];
            self.lngItem = [[loc objectForKey:@"longitude"]doubleValue];
            [self openViewFromPin:self.feature_name feature:self.feature_type];
        }
    }
}
-(void)openViewFromPin:(NSString *)f_name feature:(NSString *)f_type {
    NSLog(@"Name:%@", f_name);
    NSLog(@"Type:%@", f_type);

    [locationManager stopUpdatingLocation];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([f_type isEqualToString:@"PARK"]) {
        ParksViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ParksView"];
        vc.searchType = searchType;
        vc.searchItem = @"Parks";
        vc.searchSelected = f_name;
        vc.park_id = self.park_id;
        vc.site_name = self.site_name;
        vc.feature_id = self.feature_id;
        vc.latItem = self.latItem;
        vc.lngItem = self.lngItem;
        vc.backViewName = @"NearestResult";
        vc.site_id = self.site_id;
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([f_type isEqualToString:@"PAVILION"]) {
        PavilionsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PavilionsView"];
        vc.searchType = searchType;
        vc.searchItem = @"Pavilions";
        vc.searchSelected = f_name;
        vc.park_id = self.park_id;
        vc.site_name = self.site_name;
        vc.feature_id = self.feature_id;
        vc.latItem = self.latItem;
        vc.lngItem = self.lngItem;
        vc.backViewName = @"NearestResult";
        vc.site_id = self.site_id;
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([f_type isEqualToString:@"PLAYGROUND"]) {
        PlaygroundsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PlaygroundsView"];
        vc.searchType = searchType;
        vc.searchItem = @"Playgrounds";
        vc.searchSelected = f_name;
        vc.park_id = self.park_id;
        vc.site_name = self.site_name;
        vc.feature_id = self.feature_id;
        vc.latItem = self.latItem;
        vc.lngItem = self.lngItem;
        vc.backViewName = @"NearestResult";
        vc.site_id = self.site_id;
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([f_type isEqualToString:@"HISTORIC"]) {
        HistoricSitesViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HistoricSitesView"];
        vc.searchType = searchType;
        vc.searchItem = @"Historic Sites";
        vc.searchSelected = f_name;
        vc.park_id = self.park_id;
        vc.site_name = self.site_name;
        vc.feature_id = self.feature_id;
        vc.latItem = self.latItem;
        vc.lngItem = self.lngItem;
        vc.backViewName = @"NearestResult";
        vc.site_id = self.site_id;
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        ParksViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ParksView"];
        vc.searchType = searchType;
        vc.searchItem = f_type;
        vc.searchSelected = self.site_name;
        vc.park_id = self.park_id;
        vc.searchTitle = f_name;
        vc.site_name = self.site_name;
        vc.feature_id = self.feature_id;
        vc.latItem = self.latItem;
        vc.lngItem = self.lngItem;
        vc.backViewName = @"MainAmenities";
        vc.site_id = self.site_id;
        [self presentViewController:vc animated:YES completion:nil];
    }
}
-(void)postTipMessage:(NSString*)aMessage type:(NSString*)iconName {
    [timer invalidate];
    for(UIView *subview in [tipView subviews]) {
        [subview removeFromSuperview];
    }
    if ([tipDisplay isEqualToString:@"ON"]) {
        [UIView animateWithDuration:1.0
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             tipView.frame = CGRectMake(0, 0, self.view.frame.size.width, 104);
                             tipView.alpha = 0.8;
                         }
                         completion:^(BOOL finished) {
                             
                             if ([iconName isEqualToString:@"voice"]) {
                                 BTN1 = [UIButton buttonWithType:UIButtonTypeCustom];
                                 BTN1 = [UIButton buttonWithType:UIButtonTypeCustom];
                                 BTN1.frame = CGRectMake(8, 20, 40, 40);
                                 [BTN1 setBackgroundImage:[UIImage imageNamed:@"Voice.png"] forState:UIControlStateNormal];
                                 [BTN1 addTarget:self action:@selector(showMapItem) forControlEvents:UIControlEventTouchUpInside];
                                 [tipView addSubview:BTN1];
                             } else if ([iconName isEqualToString:@"setting"]) {
                                 BTN1 = [UIButton buttonWithType:UIButtonTypeCustom];
                                 BTN1 = [UIButton buttonWithType:UIButtonTypeCustom];
                                 BTN1.frame = CGRectMake(0, 15, 52, 52);
                                 [BTN1 setBackgroundImage:[UIImage imageNamed:@"MapTools.png"] forState:UIControlStateNormal];
                                 [BTN1 addTarget:self action:@selector(createMapTools) forControlEvents:UIControlEventTouchUpInside];
                                 [tipView addSubview:BTN1];
                             } else if ([iconName isEqualToString:@"current"]) {
                                 BTN1 = [UIButton buttonWithType:UIButtonTypeCustom];
                                 BTN1 = [UIButton buttonWithType:UIButtonTypeCustom];
                                 BTN1.frame = CGRectMake(0, 15, 52, 52);
                                 [BTN1 setBackgroundImage:[UIImage imageNamed:@"CurrentLocation.png"] forState:UIControlStateNormal];
                                 [BTN1 addTarget:self action:@selector(getCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
                                 [tipView addSubview:BTN1];
                             } else if ([iconName isEqualToString:@"location"]) {
                                     BTN1 = [UIButton buttonWithType:UIButtonTypeCustom];
                                     BTN1 = [UIButton buttonWithType:UIButtonTypeCustom];
                                     BTN1.frame = CGRectMake(0, 15, 52, 52);
                                     [BTN1 setBackgroundImage:[UIImage imageNamed:@"UserSavedLocation.png"] forState:UIControlStateNormal];
                                     [BTN1 addTarget:self action:@selector(checkSavedLocation) forControlEvents:UIControlEventTouchUpInside];
                                     [tipView addSubview:BTN1];
                             } else if ([iconName isEqualToString:@"information"]) {
                                 BTN1 = [UIButton buttonWithType:UIButtonTypeCustom];
                                 BTN1 = [UIButton buttonWithType:UIButtonTypeCustom];
                                 BTN1.frame = CGRectMake(10, 30, 32, 32);
                                 [BTN1 setBackgroundImage:[UIImage imageNamed:@"Info.png"] forState:UIControlStateNormal];
                                 [BTN1 addTarget:self action:@selector(checkSavedLocation) forControlEvents:UIControlEventTouchUpInside];
                                 [tipView addSubview:BTN1];
                             } else if ([iconName isEqualToString:@"direction"]) {
                                 BTN1 = [UIButton buttonWithType:UIButtonTypeCustom];
                                 BTN1 = [UIButton buttonWithType:UIButtonTypeCustom];
                                 BTN1.frame = CGRectMake(10, 30, 32, 32);
                                 [BTN1 setBackgroundImage:[UIImage imageNamed:@"DrivingDirection_White.png"] forState:UIControlStateNormal];
                                 //[BTN1 addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                                 [tipView addSubview:BTN1];
                             }
                             CGRect row1Frame = CGRectMake(55, 24, self.view.frame.size.width-100, 60);
                             
                             UILabel *tipLBL = [[UILabel alloc] initWithFrame:row1Frame];
                             tipLBL.text = aMessage;
                             tipLBL.font = [UIFont fontWithName:@"TrebuchetMS" size:14];
                             tipLBL.backgroundColor = [UIColor clearColor];
                             tipLBL.textColor = [UIColor yellowColor];
                             tipLBL.alpha = 1.0;
                             tipLBL.textAlignment = NSTextAlignmentLeft;
                             tipLBL.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                             tipLBL.numberOfLines = 3;
                             [tipView addSubview:tipLBL];
                             
                             UIButton *exitTipsBTN = [UIButton buttonWithType:UIButtonTypeCustom];
                             exitTipsBTN.frame = CGRectMake(self.view.frame.size.width-45, 20, 40, 40);
                             [exitTipsBTN setBackgroundImage:[UIImage imageNamed:@"Exit.png"] forState:UIControlStateNormal];
                             [exitTipsBTN addTarget:self action:@selector(closeNotify) forControlEvents:UIControlEventTouchUpInside];
                             [tipView addSubview:exitTipsBTN];
                             
                             countdown = 5;
                             
                             timerLBL = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 60, 30, 40)];
                             timerLBL.text = [NSString stringWithFormat:@"%d", countdown];
                             timerLBL.font = [UIFont fontWithName:@"TrebuchetMS" size:20];
                             timerLBL.backgroundColor = [UIColor clearColor];
                             timerLBL.textColor = [UIColor redColor];
                             timerLBL.alpha = 1.0;
                             timerLBL.textAlignment = NSTextAlignmentRight;
                             timerLBL.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                             [tipView addSubview:timerLBL];
                             
                             timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
                         }];
    }
}
-(void)countDown {
    countdown -= 1;
    timerLBL.text = [NSString stringWithFormat:@"%d", countdown];
    if (countdown==0) {
        [timer invalidate];
        [self closeNotify];
    }
}
-(void)closeNotify {
    [timer invalidate];
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                             tipView.frame = CGRectMake(0, 0, self.view.frame.size.width, 0);
                             tipView.alpha = 1.0;
                             for(UIView *subview in [tipView subviews]) {
                                 [subview removeFromSuperview];
                             }
                     }
                     completion:^(BOOL finished) {

                     }];
}
+ (NetworkStatus)checkAvailableInternet {
    Reachability *internetReachability;
    internetReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [internetReachability currentReachabilityStatus];
    return netStatus;
}
+ (NetworkStatus)checkAvailableWiFi {
    Reachability *wifiReachability;
    wifiReachability = [Reachability reachabilityForLocalWiFi];
    NetworkStatus netStatus = [wifiReachability currentReachabilityStatus];
    return netStatus;
}
-(void)openSearch {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchView"];
    vc.searchType = self.searchType;
    vc.searchItem = self.searchItem;
    vc.searchSelected = self.feature_type;
    vc.searchTitle = self.searchTitle;
    vc.latItem = self.latItem;
    vc.lngItem = self.lngItem;
    vc.backViewName = @"NearestResult";
    [self presentViewController:vc animated:YES completion:nil];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}
- (void)shareThis {
    //gpsBTN.hidden = YES;
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
                         menuBTN.hidden = YES;
                         backBTN.hidden = YES;
                         appTitle.hidden = YES;
                         appSubTitle.hidden = YES;
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
    menuBTN.hidden = NO;
    backBTN.hidden = NO;
    appSubTitle.hidden = NO;
    appTitle.hidden = NO;
    //gpsBTN.hidden = NO;
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
                                          message:@"Your device is running low on memory, to gain more memory, map need to reset."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Reset Map"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   [self recreateMap];
                               }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action)
                                   {
                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                   }];
    [alertController addAction:actionOk];
    [alertController addAction:actionCancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
