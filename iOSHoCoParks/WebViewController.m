//
//  WebViewController.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 6/8/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "WebViewController.h"
#import "MainViewController.h"
#import "NearestResultViewController.h"
#import "ParksViewController.h"
#import "PavilionsViewController.h"
#import "PlaygroundsViewController.h"
#import "HistoricSitesViewController.h"
#import "MainAmenitiesViewController.h"
#import "CustomAlert.h"

@interface WebViewController () {
    UIView *mainWebView;
    UIWebView *webView;
    UINavigationBar *navBar;
    UINavigationItem *navItem;
}

@end

@implementation WebViewController
@synthesize backViewName, searchType, searchItem, webItem;

-(void)back_Click {
    if ([backViewName isEqualToString:@"Main"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainView"];
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([backViewName isEqualToString:@"NearestResult"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NearestResultViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NearestResultView"];
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
    } else if ([backViewName isEqualToString:@"Parks"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ParksViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ParksView"];
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
    } else if ([backViewName isEqualToString:@"Pavilions"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PavilionsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PavilionsView"];
        vc.searchType = self.searchType;
        vc.searchItem = self.searchItem;
        vc.searchSelected = self.searchSelected;
        vc.park_id = self.park_id;
        vc.site_name = self.site_name;
        vc.feature_id = self.feature_id;
        vc.latItem = self.latItem;
        vc.lngItem = self.lngItem;
        vc.backViewName = @"NearestResult";
        vc.site_id = self.site_id;
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([backViewName isEqualToString:@"Playgrounds"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PlaygroundsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PlaygroundsView"];
        vc.searchType = self.searchType;
        vc.searchItem = self.searchItem;
        vc.searchSelected = self.searchSelected;
        vc.park_id = self.park_id;
        vc.site_name = self.site_name;
        vc.feature_id = self.feature_id;
        vc.latItem = self.latItem;
        vc.lngItem = self.lngItem;
        vc.backViewName = @"NearestResult";
        vc.site_id = self.site_id;
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([backViewName isEqualToString:@"HistoricSites"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        HistoricSitesViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HistoricSitesView"];
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
    } else if ([backViewName isEqualToString:@"MainAmenities"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainAmenitiesViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainAmenitiesView"];
        vc.backViewName = @"Main";
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    navItem = [[UINavigationItem alloc] init];
    navItem.title = @"Howard County Parks";
    navBar.items = @[navItem];
    [self.view addSubview:navBar];
    
    mainWebView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    mainWebView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:mainWebView];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, mainWebView.frame.size.width, mainWebView.frame.size.height)];
    webView.backgroundColor = [UIColor clearColor];
    webView.autoresizesSubviews = YES;
    webView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    webView.scalesPageToFit=YES;
    [mainWebView addSubview:webView];
    [self open_WebSite];
}

- (void)open_WebSite {

    NSString *URL;
    if ([webItem isEqualToString:@"tellHoCo"]) {
        navItem.title = @"tell HoCo";
        URL = @"https://itunes.apple.com/us/app/tell-hoco/id874344402?mt=8";
    } else if ([webItem isEqualToString:@"rules"]) {
        navItem.title = @"Rules & Regulations";
        URL = @"http://www.howardcountymd.gov/WorkArea/linkit.aspx?LinkIdentifier=id&ItemID=6442463031&libID=6442463022";
    } else if ([webItem isEqualToString:@"survey"]) {
        navItem.title = @"Trail Use Survey";
        URL = @"http://www.tinyurl.com/trailusesurvey";
    } else if ([webItem isEqualToString:@"Belmont"]) {
        navItem.title = @"Belmont Manor and Historic Park";
        URL = @"http://www.belmontmanormd.com/";
    }

    NSURL *webURL = [NSURL URLWithString:URL];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:webURL];
    [webView loadRequest:requestURL];
    [webView setScalesPageToFit:YES];
    
    UIBarButtonItem *backBTN = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(back_Click)];
    backBTN.image = [UIImage imageNamed:@"09-arrow-west.png"];
    navItem.leftBarButtonItem = backBTN;
    navBar.items = @[navItem];
    [self.view addSubview:navBar];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self presentViewController:[CustomAlert lowMemoryAlert] animated:YES completion:nil];
}

@end
