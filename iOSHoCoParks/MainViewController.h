//
//  MainViewController.h
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 6/11/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <SpriteKit/SpriteKit.h>

@interface MainViewController : UIViewController
<CLLocationManagerDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
UISearchDisplayDelegate,
UISearchBarDelegate> {

}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (assign, nonatomic) CGFloat latItem;
@property (assign, nonatomic) CGFloat lngItem;
@property (strong, nonatomic) id myAgreeItem;
@property (strong, nonatomic) UITableView *mainTableView;

@end
