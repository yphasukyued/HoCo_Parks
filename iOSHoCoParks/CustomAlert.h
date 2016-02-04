//
//  CustomAlert.h
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 8/25/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CustomAlert : UIViewController

+ (UIViewController *)makePhoneCall;
+ (UIViewController *)openMenuInformation:(NSString *)info mtitle:(NSString *)title;
+ (UIViewController *)lowMemoryAlert;
@end
