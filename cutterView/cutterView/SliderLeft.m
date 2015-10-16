//
//  SliderLeft.m
//  cutterView
//
//  Created by zhouyi on 15/10/16.
//  Copyright © 2015年 yiwanjun. All rights reserved.
//

#import "SliderLeft.h"

@implementation SliderLeft
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    [self drawCanvas1WithFrame:rect];
}


- (void)drawCanvas1WithFrame: (CGRect)frame;
{
    //// Color Declarations
    UIColor* color = [UIColor redColor];
    
    //// Bezier 2 Drawing
    
    CGFloat height = CGRectGetHeight(frame);
    
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + height, CGRectGetMinY(frame) + 0)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0, CGRectGetMinY(frame) + height)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + height, CGRectGetMinY(frame) + height)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + height, CGRectGetMinY(frame) + 0)];
    [color setFill];
    [bezierPath fill];
    [color setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
}




@end
