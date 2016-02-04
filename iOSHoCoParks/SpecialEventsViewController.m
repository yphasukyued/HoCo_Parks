//
//  SpecialEventsViewController.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 8/10/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "SpecialEventsViewController.h"
#import "NearestResultViewController.h"
#import "MainViewController.h"
#import "ParksViewController.h"
#import "PavilionsViewController.h"
#import "PlaygroundsViewController.h"
#import "HistoricSitesViewController.h"
#import "MainAmenitiesViewController.h"
#import "WebViewController.h"
#import "CustomAlert.h"

@interface SpecialEventsViewController () {
    UIView *mainView;
    UIView *myTableView;
    UIView *navMenuView;
    UIWebView *webView;
    NSMutableArray *json;
    UITableView *mainTableView;
    NSString *selectedRow;
    NSString *pulldownMenu;
    UIButton *backBTN;
    UITableViewCell *cell;
}

@end

@implementation SpecialEventsViewController

@synthesize searchItem, searchType, backViewName, searchSelected, park_id, latItem, lngItem, feature_id;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pulldownMenu = @"NO";
    
    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    mainView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:mainView];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, mainView.frame.size.width, mainView.frame.size.height)];
    webView.backgroundColor = [UIColor blackColor];
    webView.autoresizesSubviews = YES;
    webView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    webView.scalesPageToFit=YES;
    [mainView addSubview:webView];
    
    UIImageView *tableImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    tableImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    tableImage.backgroundColor = [UIColor grayColor];
    tableImage.alpha = 1;
    [mainView addSubview:tableImage];
    
    myTableView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    myTableView.backgroundColor = [UIColor clearColor];
    [mainView addSubview:myTableView];
    
    mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, myTableView.frame.size.width, myTableView.frame.size.height) style:UITableViewStylePlain];
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.backgroundColor = [UIColor clearColor];
    mainTableView.alpha = 1.0;
    [myTableView addSubview:mainTableView];
    
    navMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, 64)];
    navMenuView.backgroundColor = [UIColor blackColor];
    navMenuView.alpha = 0.3;
    navMenuView.tag = 1;
    [mainView addSubview:navMenuView];
    
    UILabel *appTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, self.view.frame.size.width-100, 40)];
    appTitle.text = @"Special Events";
    appTitle.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:24];
    appTitle.backgroundColor = [UIColor clearColor];
    appTitle.textColor = [UIColor whiteColor];
    appTitle.alpha = 1.0;
    appTitle.textAlignment = NSTextAlignmentCenter;
    appTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:appTitle];
    
    backBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    backBTN.frame = CGRectMake(8, 25, 44, 44);
    [backBTN setBackgroundImage:[UIImage imageNamed:@"Arrow_Left.png"] forState:UIControlStateNormal];
    [backBTN addTarget:self action:@selector(back_Click) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:backBTN];

    [self getData];
    [mainTableView reloadData];
    
}

-(void)getData {
    NSError *error;
    NSError *jsonError = nil;
    
    NSString *jsonFilePath = [[NSBundle mainBundle] pathForResource:[@"dataSpecialEvents" stringByReplacingOccurrencesOfString:@" / " withString:@" "] ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath options:kNilOptions error:&jsonError ];
    json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
}

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
        vc.backViewName = @"Main";
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return json.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary *info = [json objectAtIndex:indexPath.row];

    UILabel *eventLabel, *detailLabel1, *detailLabel2;
    cell = nil;
    if (cell == nil) {
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 80, 80)];
        [cell addSubview:imageView];
        UIImageView *tableImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        tableImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

        tableImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [info objectForKey:@"name"]]];
        tableImage.alpha = 1;
        [imageView addSubview:tableImage];
        
        UIImageView *arImage = [[UIImageView alloc] initWithFrame:CGRectMake(mainTableView.frame.size.width-50, 25, 40, 40)];
        arImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        arImage.image = [UIImage imageNamed:@"Arrow_Right.png"];
        arImage.alpha = 1;
        [cell addSubview:arImage];
        
        cell.backgroundColor = [UIColor clearColor];
        
        CGRect myFrame = CGRectMake(95.0, 5.0, mainTableView.frame.size.width-110, 25.0);
        eventLabel = [[UILabel alloc] initWithFrame:myFrame];
        eventLabel.backgroundColor = [UIColor clearColor];
        eventLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
        eventLabel.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:eventLabel];
        
        myFrame.origin.y += 20;
        detailLabel1 = [[UILabel alloc] initWithFrame:myFrame];
        detailLabel1.font = [UIFont fontWithName:@"TrebuchetMS" size:14];
        detailLabel1.textColor = [UIColor whiteColor];
        detailLabel1.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:detailLabel1];
        
        myFrame.origin.y += 20;
        detailLabel2 = [[UILabel alloc] initWithFrame:myFrame];
        detailLabel2.font = [UIFont fontWithName:@"TrebuchetMS" size:14];
        detailLabel2.textColor = [UIColor whiteColor];
        detailLabel2.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:detailLabel2];
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 10);
    }
    
    eventLabel.text = [info objectForKey:@"name"];
    detailLabel1.text = [info objectForKey:@"address1"];
    detailLabel2.text = [info objectForKey:@"address2"];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = [json objectAtIndex:indexPath.row];
    selectedRow = [info objectForKey:@"url"];
    
    NSURL *webURL = [NSURL URLWithString:selectedRow];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:webURL];
    [webView loadRequest:requestURL];
    [webView setScalesPageToFit:YES];
    
}
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell1 = [tableView cellForRowAtIndexPath:indexPath];
    cell1.contentView.backgroundColor = [UIColor colorWithRed:235/255.0f green:0.0f blue:0.0f alpha:.5];
}
-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell1 = [tableView cellForRowAtIndexPath:indexPath];
    cell1.contentView.backgroundColor = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self presentViewController:[CustomAlert lowMemoryAlert] animated:YES completion:nil];
}

@end
