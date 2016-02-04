//
//  MainAmenitiesViewController.h
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 7/30/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MainAmenitiesViewController : UIViewController
<UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIGestureRecognizerDelegate,
CLLocationManagerDelegate>

@property (assign, nonatomic) CGFloat latItem;
@property (assign, nonatomic) CGFloat lngItem;
@property (weak, nonatomic) id backViewName;
@property(nonatomic, retain) NSMutableArray *parks;
@end
