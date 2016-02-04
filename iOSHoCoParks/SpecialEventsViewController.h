//
//  SpecialEventsViewController.h
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 8/10/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpecialEventsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) id searchItem;
@property (weak, nonatomic) id searchType;
@property (weak, nonatomic) id searchTitle;
@property (weak, nonatomic) id searchSelected;
@property (weak, nonatomic) id feature_type;
@property (weak, nonatomic) id feature_name;
@property (weak, nonatomic) id feature_id;
@property (weak, nonatomic) id park_id;
@property (weak, nonatomic) id site_id;
@property (weak, nonatomic) id site_name;
@property (weak, nonatomic) id backViewName;
@property (assign, nonatomic) CGFloat latItem;
@property (assign, nonatomic) CGFloat lngItem;

@end
