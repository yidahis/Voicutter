//
//  CutSlider.m
//  cutterView
//
//  Created by zhouyi on 15/10/15.
//  Copyright © 2015年 yiwanjun. All rights reserved.
//

#import "CutSlider.h"
#import "SliderLeft.h"
#import "SliderRight.h"


#define ksliderWidth 40 //slidercontainer宽度
#define ksliderTopInset 8  //slider 距离父视图的顶部间距
#define minGap 8 //两个slider合拢的时候中间的间距

@implementation CutSlider{
    SliderLeft *sliderLeft;
    SliderRight *sliderRight;
    CGFloat leftPosition;
    CGFloat rightPosition;
    UIView *sliderLeftContainer;
    UIView *sliderRightContainer;
    UIView *sliderLeftIndicator;
    UIView *sliderRightIndicator;
    
    CGFloat originalRightPositon;
    
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor grayColor]];
        
        [self initSliderLeft];
        [self initSliderRight];
        
        rightPosition = sliderRightContainer.frame.origin.x;
        leftPosition = 0;
        originalRightPositon = sliderRightContainer.frame.origin.x;
    }
    return self;
}

- (void)initSliderLeft{
    sliderLeftContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ksliderWidth, CGRectGetHeight(self.frame))];
//    [sliderLeftContainer setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:sliderLeftContainer];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleLeft:)];
    [sliderLeftContainer addGestureRecognizer:pan];
    
    CGFloat sliderWidth = CGRectGetHeight(sliderLeftContainer.frame ) - 2 * ksliderTopInset;
    sliderLeft = [[SliderLeft alloc ]initWithFrame:CGRectMake(0, ksliderTopInset, sliderWidth, sliderWidth)];
    sliderLeft.center = CGPointMake(sliderLeftContainer.frame.size.width/2, sliderLeft.center.y);
    [sliderLeftContainer addSubview:sliderLeft];
    
    
    

}
- (void)initSliderRight{
    sliderRightContainer = [[UIView alloc]initWithFrame:CGRectMake(kGetSelfRectWidth-ksliderWidth, 0, ksliderWidth, CGRectGetHeight(self.frame))];
//    [sliderRightContainer setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:sliderRightContainer];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleRight:)];
    [sliderRightContainer addGestureRecognizer:pan];
    
    CGFloat sliderWidth = CGRectGetHeight(sliderRightContainer.frame ) - 2 * ksliderTopInset;
    sliderRight = [[SliderRight  alloc]initWithFrame:CGRectMake(0, ksliderTopInset,sliderWidth,sliderWidth )];
    sliderRight.center = CGPointMake(sliderRightContainer.frame.size.width/2, sliderRight.center.y);
    [sliderRightContainer addSubview:sliderRight];
    
}

#pragma mark - handle
- (void)handleLeft:(UIPanGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self];
        leftPosition += translation.x;
        if (leftPosition < 0) {
            leftPosition = 0;
        }
        
        CGFloat gap = sliderLeft.frame.origin.x*2 - minGap;
        
        if (rightPosition - leftPosition + gap <= sliderLeftContainer.frame.size.width/2 + sliderRightContainer.frame.size.width/2) {
            leftPosition -= translation.x;
        }
        
        [self delegateNotification];
        
        [gesture setTranslation:CGPointZero inView:self];
        [self setNeedsLayout];
    }
}

- (void)handleRight:(UIPanGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self];
        rightPosition += translation.x;
        if (rightPosition < 0) {
            rightPosition = 0;
        }
        
        if (rightPosition > CGRectGetWidth(self.frame)-CGRectGetWidth(sliderRightContainer.frame)) {
            rightPosition = originalRightPositon;
        }
        
        CGFloat gap = sliderRight.frame.origin.x*2 - minGap;
        
        if (rightPosition - leftPosition <= 0 || (rightPosition - leftPosition +  gap <= CGRectGetWidth(sliderLeftContainer.frame)/2 + CGRectGetWidth(sliderRightContainer.frame)/2)) {
            rightPosition -= translation.x;
        }
        
        [self delegateNotification];
        
        [gesture setTranslation:CGPointZero inView:self];
        [self setNeedsLayout];
    }
}

- (void)delegateNotification
{
    if ([_delegate respondsToSelector:@selector(didChangeLeftPosition:rightPosition:)]){
        _leftPoint = leftPosition + CGRectGetWidth(sliderLeft.frame) + sliderLeft.frame.origin.x;
        _rightPoint = rightPosition + sliderRight.frame.origin.x;
        [_delegate didChangeLeftPosition:_leftPoint rightPosition:_rightPoint];
    }
    
}


- (void)layoutSubviews{
    NSLog(@"layoutSubviews action");
    CGFloat inset = sliderLeftContainer.frame.size.width/2;
    sliderLeftContainer.center = CGPointMake(leftPosition + inset, sliderLeftContainer.center.y);
    sliderRightContainer.center = CGPointMake(rightPosition + inset, sliderRightContainer.center.y);
}

#pragma mark - getter

- (CGFloat)leftPoint{
    return  leftPosition + CGRectGetWidth(sliderLeft.frame) + sliderLeft.frame.origin.x;
}
- (CGFloat)rightPoint{
    return rightPosition + sliderRight.frame.origin.x;
}


@end
