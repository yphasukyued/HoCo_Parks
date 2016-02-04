//
//  WebViewController.h
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 6/8/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIAlertViewDelegate>
    
@property (strong, nonatomic) id webItem;
@property (strong, nonatomic) id searchItem;
@property (strong, nonatomic) id searchType;
@property (strong, nonatomic) id searchTitle;
@property (strong, nonatomic) id searchSelected;
@property (strong, nonatomic) id feature_type;
@property (strong, nonatomic) id feature_name;
@property (strong, nonatomic) id feature_id;
@property (strong, nonatomic) id park_id;
@property (strong, nonatomic) id site_id;
@property (strong, nonatomic) id site_name;
@property (strong, nonatomic) id backViewName;
@property (assign, nonatomic) CGFloat latItem;
@property (assign, nonatomic) CGFloat lngItem;

@end
