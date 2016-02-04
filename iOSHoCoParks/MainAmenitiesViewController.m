//
//  MainAmenitiesViewController.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 7/30/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "MainAmenitiesViewController.h"
#import "SpecialEventsViewController.h"
#import "MainViewController.h"
#import "WebViewController.h"
#import "NearestResultViewController.h"
#import "DrawCircle.h"
#import "DrawText.h"
#import "DrawProfile.h"
#import "FindNearestPoly.h"
#import "CustomAlert.h"
#import "SearchViewController.h"
#import "CustomCollectionCell.h"

@interface MainAmenitiesViewController () {
    UIView *mainView;
    UIView *navMenuView;
    UIWebView *webView;
    CIImage *inputImage;
    UICollectionView *cv;
    CLLocationManager *locationManager;
    UILabel *appTitle;
    NSString *pulldownMenu;
    NSString *locationItem;
    UIButton *backBTN;
    UIButton *menuBTN;
    CGImageRef cgimg;
    UIButton *phoneBTN;
    UIButton *ruleBTN;
    UIButton *thcBTN;
    UIButton *searchBTN;
    UIButton *calendarBTN;
}

@end

@implementation MainAmenitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.headingFilter = 1;
    locationManager.delegate = self;
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    pulldownMenu = @"NO";
    
    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    mainView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:mainView];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, mainView.frame.size.width, mainView.frame.size.height)];
    webView.backgroundColor = [UIColor blackColor];
    webView.autoresizesSubviews = YES;
    webView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    webView.scalesPageToFit=YES;
    [mainView addSubview:webView];
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    
    inputImage = [CIImage imageWithCGImage:[[UIImage imageNamed:@"NearestParksBG.jpeg"] CGImage]];
    [gaussianBlurFilter setValue:inputImage forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@30 forKey:kCIInputRadiusKey];

    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    cgimg = [context createCGImage:outputImage fromRect:[inputImage extent]];
    
    UIImageView *tableImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    tableImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    tableImage.image = [UIImage imageWithCGImage:cgimg];
    tableImage.alpha = 1;
    [mainView addSubview:tableImage];

    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(60, 85);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    cv=[[UICollectionView alloc]
        initWithFrame:CGRectMake(10, 80, mainView.frame.size.width-20, mainView.frame.size.height-100)
        collectionViewLayout:layout];
    [cv registerClass:[CustomCollectionCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [cv setDataSource:self];
    [cv setDelegate:self];
    [cv setBackgroundColor:[UIColor clearColor]];
    [mainView addSubview:cv];
    
    navMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, 64)];
    navMenuView.backgroundColor = [UIColor blackColor];
    navMenuView.alpha = 0.3;
    navMenuView.tag = 1;
    [mainView addSubview:navMenuView];
    
    appTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, self.view.frame.size.width-100, 40)];
    appTitle.text = @"Amenities";
    appTitle.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:24];
    appTitle.backgroundColor = [UIColor clearColor];
    appTitle.textColor = [UIColor whiteColor];
    appTitle.alpha = 1.0;
    appTitle.textAlignment = NSTextAlignmentCenter;
    appTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:appTitle];
    
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
    

    [self openCategory];
}
-(void)openCategory {
    
    NSError *error;
    NSError *jsonError = nil;
    
    NSString *jsonFilePath = [[NSBundle mainBundle] pathForResource:[@"dataCategory" stringByReplacingOccurrencesOfString:@" / " withString:@" "] ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath options:kNilOptions error:&jsonError ];
    self.parks = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];

}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.parks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *info;
    info = [self.parks objectAtIndex:indexPath.row];
    
    CustomCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    cell.customImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_1.png", [info objectForKey:@"type"]]];
    cell.customLabel_1.text = [info objectForKey:@"name_1"];
    cell.customLabel_2.text = [info objectForKey:@"name_2"];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(60, 85);
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
    info = [self.parks objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NearestResultViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NearestResultView"];
    vc.searchType = @"Nearest";
    vc.searchItem = [info objectForKey:@"type"];
    vc.searchTitle = [NSString stringWithFormat:@"%@%@", [info objectForKey:@"name_1"],[info objectForKey:@"name_2"]];
    vc.backViewName = @"MainAmenities";
    vc.latItem = self.latItem;
    vc.lngItem = self.lngItem;
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)getMenu {
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if ([pulldownMenu isEqualToString:@"NO"]) {
                             pulldownMenu = @"YES";
                             navMenuView.alpha = 1;
                             navMenuView.frame = CGRectMake(0, 0, mainView.frame.size.width, 170);
                             navMenuView.alpha = 1;
                         } else if ([pulldownMenu isEqualToString:@"YES"]) {
                             pulldownMenu = @"NO";
                             navMenuView.frame = CGRectMake(0, 0, mainView.frame.size.width, 64);
                             navMenuView.alpha = 0.3;
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
    
    CIImage *inputImage1 = [CIImage imageWithCGImage:[[UIImage imageNamed:@"NearestParksBG.jpeg"] CGImage]];
    [gaussianBlurFilter setValue:inputImage1 forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@30 forKey:kCIInputRadiusKey];
    
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    cgimg = [context createCGImage:outputImage fromRect:[inputImage1 extent]];
    
    UIImageView *menuImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, navMenuView.frame.size.width, navMenuView.frame.size.height)];
    menuImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    menuImage.image = [UIImage imageWithCGImage:cgimg];
    menuImage.alpha = 1;
    [navMenuView addSubview:menuImage];
    
    CGRect row1Frame = CGRectMake((self.view.frame.size.width/2)-144, 80, 32, 32);
    
    phoneBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    phoneBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    phoneBTN.frame = row1Frame;
    phoneBTN.tag = 1;
    [phoneBTN setBackgroundImage:[UIImage imageNamed:@"phone.png"] forState:UIControlStateNormal];
    [phoneBTN addTarget:self action:@selector(openCall) forControlEvents:UIControlEventTouchUpInside];
    [navMenuView addSubview:phoneBTN];
    
    row1Frame.origin.x += 62;
    ruleBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    ruleBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    ruleBTN.frame = row1Frame;
    ruleBTN.tag = 2;
    [ruleBTN setBackgroundImage:[UIImage imageNamed:@"rules.png"] forState:UIControlStateNormal];
    [ruleBTN addTarget:self action:@selector(openRule) forControlEvents:UIControlEventTouchUpInside];
    [navMenuView addSubview:ruleBTN];
    
    thcBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    thcBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    thcBTN.frame = CGRectMake((self.view.frame.size.width/2)-25, 80, 50, 50);
    thcBTN.tag = 3;
    [thcBTN setBackgroundImage:[UIImage imageNamed:@"tellHoCo.png"] forState:UIControlStateNormal];
    [thcBTN addTarget:self action:@selector(openTellHoCo) forControlEvents:UIControlEventTouchUpInside];
    [navMenuView addSubview:thcBTN];
    
    row1Frame.origin.x += 136;
    searchBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBTN.frame = row1Frame;
    searchBTN.tag = 4;
    [searchBTN setBackgroundImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    [searchBTN addTarget:self action:@selector(openSearch) forControlEvents:UIControlEventTouchUpInside];
    [navMenuView addSubview:searchBTN];
    
    row1Frame.origin.x += 62;
    calendarBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    calendarBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    calendarBTN.frame = row1Frame;
    calendarBTN.tag = 5;
    [calendarBTN setBackgroundImage:[UIImage imageNamed:@"calendar.png"] forState:UIControlStateNormal];
    [calendarBTN addTarget:self action:@selector(openSpecialEvents) forControlEvents:UIControlEventTouchUpInside];
    [navMenuView addSubview:calendarBTN];
    
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
    vc.backViewName = @"MainAmenities";
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
    vc.backViewName = @"MainAmenities";
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)openCall {
    [self presentViewController:[CustomAlert makePhoneCall] animated:YES completion:nil];
}
-(void)back_Click {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainView"];
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)openView:(UIButton *)btn {
    //NSLog(@"%ld", (long)btn.tag);

    NSMutableArray *json;
    NSError *error;
    NSError *jsonError = nil;
        
    NSString *jsonFilePath = [[NSBundle mainBundle] pathForResource:[@"dataCategory" stringByReplacingOccurrencesOfString:@" / " withString:@" "] ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath options:kNilOptions error:&jsonError ];
    json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    NSString *searchItem;
    NSString *searchTitle;
    for(int i=0; i< [json count]; i++) {
        NSDictionary *cat = [json objectAtIndex:i];
        NSInteger id = [[cat objectForKey:@"id"]integerValue];
        if (btn.tag == id) {
            //NSLog(@"%ld", (long)btn.tag);
            searchItem = [cat objectForKey:@"type"];
            searchTitle = [cat objectForKey:@"name"];
        }
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NearestResultViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NearestResultView"];
    vc.searchType = @"Nearest";
    vc.searchItem = searchItem;
    vc.searchTitle = searchTitle;
    vc.backViewName = @"MainAmenities";
    vc.latItem = self.latItem;
    vc.lngItem = self.lngItem;
    [self presentViewController:vc animated:YES completion:nil];
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
    
    [locationManager stopUpdatingLocation];
}
-(void)openSearch {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SearchView"];
    vc.backViewName = @"MainAmenities";
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self presentViewController:[CustomAlert lowMemoryAlert] animated:YES completion:nil];
}

@end
