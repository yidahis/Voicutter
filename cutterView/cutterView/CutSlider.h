//
//  CutSlider.h
//  cutterView
//
//  Created by zhouyi on 15/10/15.
//  Copyright © 2015年 yiwanjun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kGetSelfRectWidth CGRectGetWidth(self.frame)
#define kGetSelfRectHeight CGRectGetHeight(self.frame)

@protocol CutSliderDelegate <NSObject>

@optional
- (void)didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;

- (void)didGestureStateEndedLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;
@end

@interface CutSlider : UIView

@property (nonatomic, weak) id <CutSliderDelegate> delegate;
@property (nonatomic) CGFloat leftPoint;
@property (nonatomic) CGFloat rightPoint;
@end

