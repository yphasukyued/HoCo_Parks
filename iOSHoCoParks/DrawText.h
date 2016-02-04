//
//  DrawText.h
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 8/3/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface DrawText : UIView {
    NSString *title;
}

@property (nonatomic, copy) NSString *title;

@end
