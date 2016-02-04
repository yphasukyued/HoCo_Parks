//
//  SearchViewController.h
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 9/9/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController
<UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate>

@property (strong, nonatomic) id searchItem;
@property (strong, nonatomic) id searchType;
@property (strong, nonatomic) id searchTitle;
@property (strong, nonatomic) id searchSelected;
@property (strong, nonatomic) id feature_id;
@property (strong, nonatomic) id feature_name;
@property (strong, nonatomic) id feature_type;
@property (strong, nonatomic) id park_id;
@property (strong, nonatomic) id site_id;
@property (strong, nonatomic) id site_name;
@property (strong, nonatomic) id backViewName;

@property(nonatomic, retain) UIImageView *titleImage;
@property(nonatomic, retain) UITableView *mainTableView;
@property(nonatomic, retain) UITableViewCell *cell;

@property (assign, nonatomic) CGFloat latItem;
@property (assign, nonatomic) CGFloat lngItem;
@end
