//
//  ZPVideoProgressView.h
//  PlayDemo
//
//  Created by HZP on 2017/5/27.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import <UIKit/UIKit.h>
#pragma mark - delegate
/**
 *  视频播放进度条协议
 */
@protocol ZPVideoProgressBarDelegate <NSObject>
@optional
/**
 *  开始拖动
 */
- (void)videoProgressStartSliding;
/**
 *  结束拖动
 */
- (void)videoProgressEndSliding;
- (void) videoProgressEndSlidingWithValue:(id)value;
/**
 *  拖动值发生改变
 */
- (void)videoProgressValueDidChange;
@end

#pragma mark - Class
/**
 *  可以显示缓冲的进度条
 */
@interface ZPVideoProgressBar : UIView
/**代理*/
@property (nonatomic, weak) id<ZPVideoProgressBarDelegate> delegate;
/**最大值*/
@property (nonatomic, assign, readonly) CGFloat maxValue;
/**最小值*/
@property (nonatomic, assign, readonly) CGFloat minValue;

/**进度值*/
@property (nonatomic, assign) CGFloat progressValue;
/**缓冲值*/
@property (nonatomic, assign) CGFloat bufferValue;

/**进度条颜色*/
@property (nonatomic, strong) UIColor *progressColor;
/**缓冲条颜色*/
@property (nonatomic, strong) UIColor *bufferColor;
/**背景颜色*/
@property (nonatomic, strong) UIColor *backColor;
/**滑动按钮颜色*/
@property (nonatomic, strong) UIColor *sliderButtonColor;
/**是否由用户在拖动*/
@property (nonatomic, assign) BOOL isDraging;

-(instancetype)init;
-(instancetype)initWithMaxValue:(CGFloat)maxVal minValue:(CGFloat)minVal progressColor:(UIColor*)proColor bufferColor:(UIColor*)bufCol backgoundColor:(UIColor*)color sliderButtonColor:(UIColor*)btnColor;
+(instancetype)videoProgressWithMaxValue:(CGFloat)maxVal minValue:(CGFloat)minVal progressColor:(UIColor*)proColor bufferColor:(UIColor*)bufCol backgoundColor:(UIColor*)color sliderButtonColor:(UIColor*)btnColor;

@end
