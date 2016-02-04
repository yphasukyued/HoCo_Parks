//
//  DrawText.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 8/3/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "DrawText.h"

@implementation DrawText
@synthesize title;

- (void)drawRect:(CGRect)rect {

    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds );
    
    NSAttributedString *attString = [[NSAttributedString alloc]initWithString:title];
    
    CTFramesetterRef framesetter =
    CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef frame =
    CTFramesetterCreateFrame(framesetter,
                             CFRangeMake(0, [attString length]), path, NULL);
    
    CTFrameDraw(frame, context);
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);


}


@end
