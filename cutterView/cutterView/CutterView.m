//
//  cutterView.m
//  cutterView
//
//  Created by zhouyi on 15/10/15.
//  Copyright © 2015年 yiwanjun. All rights reserved.
//

#import "CutterView.h"

@implementation CutterView{
    CutSlider *slider;
    UIView *rightIndicator;
    UIView *leftIndicator;
}

- (void)awakeFromNib{
    [self initSlider];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:0.129 green:0.133 blue:0.110 alpha:1.000]];
        [self initSlider];
        [self initIndicator];
    }
    return self;
}

- (void)initSlider{
    slider = [[CutSlider alloc]initWithFrame:CGRectMake(0, kGetSelfRectHeight-40, kGetSelfRectWidth, 40)];
    slider.delegate = self;
    [self addSubview:slider];
}

- (void)initIndicator{
   
    
    leftIndicator = [[UIView alloc]initWithFrame:CGRectMake(slider.leftPoint-1, 0, 1, kGetSelfRectHeight-40+12)];
    [leftIndicator setBackgroundColor:[UIColor redColor]];
    [self addSubview:leftIndicator];
    
    rightIndicator = [[UIView alloc]initWithFrame:CGRectMake(slider.rightPoint, 0, 1, kGetSelfRectHeight-40+12)];
    [rightIndicator setBackgroundColor:[UIColor redColor]];
    [self addSubview:rightIndicator];
}

- (void)didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition{
    [rightIndicator setCenter:CGPointMake(rightPosition+1, rightIndicator.center.y)];
    [leftIndicator setCenter:CGPointMake(leftPosition-1, leftIndicator.center.y)];
    [self setNeedsLayout];
}


@end
