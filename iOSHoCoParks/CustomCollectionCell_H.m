//
//  CustomCollectionCell_H.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 9/30/15.
//  Copyright © 2015 Howard County. All rights reserved.
//

#import "CustomCollectionCell_H.h"

@implementation CustomCollectionCell_H

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.customImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
        self.customImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.customImageView.alpha = 1;
        [self addSubview:self.customImageView];
    }
    return self;
}

@end
