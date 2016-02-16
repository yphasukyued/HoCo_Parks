//
//  CustomCollectionCell.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 9/29/15.
//  Copyright © 2015 Howard County. All rights reserved.
//

#import "CustomCollectionCell.h"

@implementation CustomCollectionCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.customImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
        self.customImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        self.customImageView.alpha = 1;
        [self addSubview:self.customImageView];
        
        CGRect myFrame = CGRectMake(-8, 57.0, 75.0, 15.0);
        self.customLabel_1 = [[UILabel alloc] initWithFrame:myFrame];
        self.customLabel_1.backgroundColor = [UIColor clearColor];
        self.customLabel_1.font = [UIFont fontWithName:@"TrebuchetMS" size:13];
        self.customLabel_1.textColor = [UIColor blackColor];
        self.customLabel_1.textAlignment = NSTextAlignmentCenter;
        self.customLabel_1.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.customLabel_1];
        
        myFrame.origin.y += 15.0;
        self.customLabel_2 = [[UILabel alloc] initWithFrame:myFrame];
        self.customLabel_2.backgroundColor = [UIColor clearColor];
        self.customLabel_2.font = [UIFont fontWithName:@"TrebuchetMS" size:13];
        self.customLabel_2.textColor = [UIColor blackColor];
        self.customLabel_2.textAlignment = NSTextAlignmentCenter;
        self.customLabel_2.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.customLabel_2];
    }
    return self;
}

@end
