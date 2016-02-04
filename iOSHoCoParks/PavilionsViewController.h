//
//  PavilionsViewController.h
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 6/16/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@class DrawCircle;
@class DrawText;
@class DrawProfile;
@class DrawStartPoint;
@class DrawEndPoint;

@interface PavilionsViewController : UIViewController
<UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIActionSheetDelegate,
UIGestureRecognizerDelegate,
UIScrollViewDelegate,
CLLocationManagerDelegate,
MKMapViewDelegate>

@property(nonatomic, retain) DrawCircle *drawCircle;
@property(nonatomic, retain) DrawStartPoint *drawStartPoint;
@property(nonatomic, retain) DrawEndPoint *drawEndPoint;
@property(nonatomic, retain) DrawText *drawText;
@property(nonatomic, retain) DrawProfile *drawProfile;

@property (strong, nonatomic) id searchItem;
@property (strong, nonatomic) id searchType;
@property (strong, nonatomic) id searchSelected;
@property (strong, nonatomic) id feature_id;
@property (strong, nonatomic) id feature_type;
@property (strong, nonatomic) id feature_name;
@property (strong, nonatomic) id site_name;
@property (strong, nonatomic) id site_id;
@property (strong, nonatomic) id park_id;
@property (strong, nonatomic) id trailID;
@property (strong, nonatomic) id trailName;
@property (strong, nonatomic) id hasSavedLocation;
@property (strong, nonatomic) id backViewName;
@property (strong, nonatomic) id initialOption;

@property(nonatomic, retain) NSMutableArray *parks;
@property(nonatomic, retain) NSMutableArray *trails;
@property(nonatomic, retain) NSMutableArray *amenities;
@property(nonatomic, retain) MKMapView *mapView;
@property(nonatomic, retain) MKTileOverlay *tileOverlay;

@property (assign, nonatomic) CGFloat latItem;
@property (assign, nonatomic) CGFloat lngItem;
@property (assign, nonatomic) CGFloat latSaved;
@property (assign, nonatomic) CGFloat lngSaved;

@end
