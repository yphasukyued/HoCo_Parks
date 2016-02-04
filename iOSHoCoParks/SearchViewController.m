//
//  SearchViewController.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 9/9/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "SearchViewController.h"
#import "NearestResultViewController.h"
#import "MainViewController.h"
#import "MainAmenitiesViewController.h"
#import "SpecialEventsViewController.h"
#import "ParksViewController.h"
#import "PavilionsViewController.h"
#import "PlaygroundsViewController.h"
#import "HistoricSitesViewController.h"
#import "WebViewController.h"
#import "CustomAlert.h"
#import "GetJSON.h"

@interface SearchViewController () {
    UIView *mainView;
    UIView *myTableView;
    UIView *navMenuView;
    UIWebView *webView;
    NSMutableArray *json;
    NSMutableArray *searchResults;
    UIImage *inImage;
    NSString *pulldownMenu;
    UITextField *searchField;
    UIButton *backBTN;
    UIButton *menuBTN;
    UIButton *r1BTN1;
    UIButton *r1BTN2;
    UIButton *r1BTN3;
    UIButton *r1BTN4;
    UIButton *r1BTN5;
    CGImageRef cgimg;
}

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchType = @"Nearest";
    self.searchItem = @"Parks";
    pulldownMenu = @"NO";
    
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
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    
    inImage = [UIImage imageNamed:@"Centennial Park.jpg"];

    CIImage *inputImage0 = [CIImage imageWithCGImage:[[UIImage imageNamed:@"NearestParksBG.jpeg"] CGImage]];
    [gaussianBlurFilter setValue:inputImage0 forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@30 forKey:kCIInputRadiusKey];
    
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    cgimg = [context createCGImage:outputImage fromRect:[inputImage0 extent]];
    
    _titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, 170)];
    _titleImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _titleImage.image = inImage;
    _titleImage.alpha = 1;
    [mainView addSubview:_titleImage];
    
    UIImageView *tableImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height-170)];
    tableImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    tableImage.image = [UIImage imageWithCGImage:cgimg];
    tableImage.alpha = 1;
    [mainView addSubview:tableImage];
    
    myTableView = [[UIView alloc] initWithFrame:CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height-170)];
    myTableView.backgroundColor = [UIColor clearColor];
    [mainView addSubview:myTableView];
    
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, myTableView.frame.size.width, myTableView.frame.size.height) style:UITableViewStylePlain];
    self.mainTableView.dataSource = self;
    self.mainTableView.delegate = self;
    self.mainTableView.backgroundColor = [UIColor clearColor];
    self.mainTableView.alpha = 1.0;
    [myTableView addSubview:self.mainTableView];
    
    navMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, 64)];
    navMenuView.backgroundColor = [UIColor blackColor];
    navMenuView.alpha = 0.5;
    navMenuView.tag = 1;
    [mainView addSubview:navMenuView];
    
    searchField = [[UITextField alloc] initWithFrame:CGRectMake(60, 25, mainView.frame.size.width-120, 30)];
    searchField.borderStyle = UITextBorderStyleRoundedRect;
    searchField.font = [UIFont systemFontOfSize:15];
    searchField.placeholder = @"search";
    searchField.autocorrectionType = UITextAutocorrectionTypeNo;
    searchField.keyboardType = UIKeyboardTypeDefault;
    searchField.returnKeyType = UIReturnKeyDone;
    searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    searchField.delegate = self;
    [searchField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [mainView addSubview:searchField];
    
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
    
    NSError *error;
    NSError *jsonError = nil;
    NSString* jsonFilePath = [[NSBundle mainBundle] pathForResource:[@"dataSome_Amenities" stringByReplacingOccurrencesOfString:@" / " withString:@" "] ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath options:kNilOptions error:&jsonError ];
    json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    [self.mainTableView reloadData];
    searchResults = json;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info;
    info = [searchResults objectAtIndex:indexPath.row];
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
        distLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:12];
        distLabel.textColor = [UIColor blackColor];
        distLabel.backgroundColor = [UIColor clearColor];
        [self.cell.contentView addSubview:distLabel];
    }
    
    if ([self.cell respondsToSelector:@selector(setSeparatorInset:)]) {
        self.cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 10);
    }
    
    parkLabel.text = [info objectForKey:@"site_name"];
    distLabel.text = [NSString stringWithFormat:@"%@", [info objectForKey:@"feature_name"]];

    return self.cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = [searchResults objectAtIndex:indexPath.row];
    self.feature_id = [info objectForKey:@"feature_id"];
    self.feature_type = [info objectForKey:@"feature_type"];
    self.feature_name = [info objectForKey:@"feature_name"];
    self.latItem = [[info objectForKey:@"latitude"]floatValue];
    self.lngItem = [[info objectForKey:@"longitude"]floatValue];
    self.site_id = [info objectForKey:@"id"];
    self.park_id = [info objectForKey:@"park_id"];
    self.site_name = [info objectForKey:@"site_name"];
    if ([self.feature_type isEqualToString:@"PAVILION"]) {
        [self openPavilions];
    } else if ([self.feature_type isEqualToString:@"PLAYGROUND"]) {
        [self openPlaygrounds];
    } else {
        [self openAmenities];
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
-(void)openPavilions {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PavilionsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PavilionsView"];
    vc.searchItem = @"Pavilions";
    vc.searchSelected = self.feature_name;
    vc.feature_id = self.feature_id;
    vc.site_name = self.site_name;
    vc.park_id = self.park_id;
    vc.latItem = self.latItem;
    vc.lngItem = self.lngItem;
    vc.backViewName = @"Parks";
    vc.initialOption = @"Map";
    vc.site_id = self.site_id;
    vc.feature_name = self.feature_name;
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)openPlaygrounds {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PlaygroundsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PlaygroundsView"];
    vc.searchItem = @"Playgrounds";
    vc.searchSelected = self.feature_name;
    vc.feature_id = self.feature_id;
    vc.site_name = self.site_name;
    vc.park_id = self.park_id;
    vc.latItem = self.latItem;
    vc.lngItem = self.lngItem;
    vc.backViewName = @"Parks";
    vc.initialOption = @"Map";
    vc.site_id = self.site_id;
    vc.feature_name = self.feature_name;
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)openAmenities {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ParksViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ParksView"];
    vc.searchItem = @"Parks";
    vc.searchSelected = self.site_name;
    vc.feature_id = self.feature_id;
    vc.site_name = self.site_name;
    vc.park_id = self.park_id;
    vc.latItem = self.latItem;
    vc.lngItem = self.lngItem;
    vc.backViewName = @"NearestResult";
    vc.initialOption = @"Map";
    vc.site_id = self.site_id;
    vc.feature_name = self.feature_name;
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)back_Click {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([self.backViewName isEqualToString:@"Main"]) {
        MainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainView"];
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([self.backViewName isEqualToString:@"MainAmenities"]){
        MainAmenitiesViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainAmenitiesView"];
        vc.backViewName = self.backViewName;
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([self.backViewName isEqualToString:@"Parks"]){
        ParksViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ParksView"];
        vc.searchItem = self.searchItem;
        vc.searchSelected = self.site_name;
        vc.park_id = self.park_id;
        vc.site_name = self.site_name;
        vc.feature_id = self.feature_id;
        vc.latItem = self.latItem;
        vc.lngItem = self.lngItem;
        vc.backViewName = @"NearestResult";
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([self.backViewName isEqualToString:@"Pavilions"]){
        PavilionsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PavilionsView"];
        vc.searchItem = self.searchItem;
        vc.searchSelected = self.site_name;
        vc.park_id = self.park_id;
        vc.site_name = self.site_name;
        vc.feature_id = self.feature_id;
        vc.latItem = self.latItem;
        vc.lngItem = self.lngItem;
        vc.backViewName = @"NearestResult";
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([self.backViewName isEqualToString:@"Playgrounds"]){
        PlaygroundsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PlaygroundsView"];
        vc.searchItem = self.searchItem;
        vc.searchSelected = self.site_name;
        vc.park_id = self.park_id;
        vc.site_name = self.site_name;
        vc.feature_id = self.feature_id;
        vc.latItem = self.latItem;
        vc.lngItem = self.lngItem;
        vc.backViewName = @"NearestResult";
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([self.backViewName isEqualToString:@"HistoricSites"]){
        HistoricSitesViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HistoricSitesView"];
        vc.searchItem = self.searchItem;
        vc.searchSelected = self.searchSelected;
        vc.park_id = self.park_id;
        vc.site_name = self.site_name;
        vc.feature_id = self.feature_id;
        vc.latItem = self.latItem;
        vc.lngItem = self.lngItem;
        vc.backViewName = @"NearestResult";
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([self.backViewName isEqualToString:@"NearestResult"]){
        NearestResultViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NearestResultView"];
        vc.searchType = self.searchType;
        vc.searchItem = self.searchItem;
        vc.searchTitle = self.searchTitle;
        vc.latItem = self.latItem;
        vc.lngItem = self.lngItem;
        vc.backViewName = @"Main";
        [self presentViewController:vc animated:YES completion:nil];
    }
}
-(void)getMenu {
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if ([pulldownMenu isEqualToString:@"NO"]) {
                             pulldownMenu = @"YES";
                             navMenuView.frame = CGRectMake(0, 0, mainView.frame.size.width, 170);
                             navMenuView.alpha = 1;
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
    vc.backViewName = @"SearchView";
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)openSurvey {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WebView"];
    vc.webItem = @"survey";
    vc.backViewName = @"SearchView";
    vc.searchType = self.searchType;
    vc.searchItem = self.searchItem;
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
    vc.backViewName = @"SearchView";
    vc.searchType = self.searchType;
    vc.searchItem = self.searchItem;
    [self presentViewController:vc animated:YES completion:nil];
}
-(void)openCall {
    [self presentViewController:[CustomAlert makePhoneCall] animated:YES completion:nil];
}

- (void)updateFilteredContent:(NSString *)searchName {
    
    if (searchName == nil) {
        json = [json mutableCopy];
    } else {
        NSArray *search;
        NSMutableArray *searchs = [[NSMutableArray alloc] init];
        for(int i=0; i< [json count]; i++) {
            NSDictionary *loc = [json objectAtIndex:i];
            NSString *stringSiteName = [[loc objectForKey:@"site_name"]lowercaseString];
            NSString *stringFeatureName = [[loc objectForKey:@"feature_name"]lowercaseString];
            NSString *stringSearch = [searchName lowercaseString];
            if ([stringSiteName containsString:stringSearch]
                || [stringFeatureName containsString:stringSearch]
                ) {
                NSDictionary * dict =[NSMutableDictionary new];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"feature_name"]] forKey:@"feature_name"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"latitude"]] forKey:@"latitude"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"longitude"]] forKey:@"longitude"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"id"]] forKey:@"id"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"park_id"]] forKey:@"park_id"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"site_name"]] forKey:@"site_name"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"feature_type"]] forKey:@"feature_type"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"feature_id"]] forKey:@"feature_id"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"address1"]] forKey:@"address1"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"address2"]] forKey:@"address2"];
                [dict setValue:[NSString stringWithFormat:@"%@",[loc objectForKey:@"description"]] forKey:@"description"];
                search =[[NSArray alloc]initWithObjects:dict, nil];
                [searchs addObjectsFromArray:search];

            }
            searchResults = searchs;
        }
        
        [self.mainTableView reloadData];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}
-(void)textFieldDidChange:(UITextField *)textField {
    NSString *searchString = textField.text;
    [self updateFilteredContent:searchString];
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
