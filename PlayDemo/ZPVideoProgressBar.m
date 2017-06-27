//
//  ZPVideoProgressView.m
//  PlayDemo
//
//  Created by HZP on 2017/5/27.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ZPVideoProgressBar.h"
#import "ZPTools.h"
static const CGFloat kZPVideoProgressBarHeigth = 5.0f;
static const CGFloat kZPVideoProgressBarButtonSize = 10.0f;

@interface ZPVideoProgressBar ()
/**背景*/
@property (nonatomic, weak) UIView *backgroundView;
/**缓存进度*/
@property (nonatomic, weak) UIView *bufferView;
/**播放进度*/
@property (nonatomic, weak) UIView *progressView;
/**可拖动的按钮*/
@property (nonatomic, weak) UIButton *sliderButton;
/**在拖动时显示的按钮*/
@property (nonatomic, weak) UIButton *hiddenButton;
/**滑动按钮所在的位置*/
//@property (nonatomic, assign) CGPoint sliderButtonPoint;
@property (nonatomic, weak) UILabel *timeLabel;

@property (nonatomic, assign) BOOL isFirstLayousSubView;

@end


@implementation ZPVideoProgressBar

#pragma mark - Init
-(instancetype)init {
    return [self initWithMaxValue:1.0f minValue:0.0f progressColor:[UIColor brownColor] bufferColor:[UIColor grayColor] backgoundColor:[UIColor clearColor] sliderButtonColor:[UIColor whiteColor]];
}
-(instancetype)initWithMaxValue:(CGFloat)maxVal minValue:(CGFloat)minVal progressColor:(UIColor*)proColor bufferColor:(UIColor*)bufCol backgoundColor:(UIColor*)color sliderButtonColor:(UIColor*)btnColor {
    if (self = [super init]) {
        _maxValue = maxVal;
        _minValue = minVal;
        _progressColor = proColor;
        _bufferColor = bufCol;
        _backColor = color;
        _sliderButtonColor = btnColor;
        _isDraging = NO;
        _isFirstLayousSubView = YES;
        [self createSubview];
    }
    return self;
}

+(instancetype)videoProgressWithMaxValue:(CGFloat)maxVal minValue:(CGFloat)minVal progressColor:(UIColor*)proColor bufferColor:(UIColor*)bufCol backgoundColor:(UIColor*)color sliderButtonColor:(UIColor*)btnColor {
    return [[self alloc]initWithMaxValue:maxVal minValue:minVal progressColor:proColor bufferColor:bufCol backgoundColor:color sliderButtonColor:btnColor];
}

#pragma mark - Setter
/**
 *  误差
 */
static const CGFloat Inaccuracy = 0.0001f;
/**
 *  设置进度值
 */
-(void)setProgressValue:(CGFloat)progressValue {
    //值没有改变
    CGFloat deta = progressValue - _progressValue;
    if (ABS(deta) < Inaccuracy) return;
    //播放进度不可能超过缓冲进度
    if ((progressValue < 0.0f) || (progressValue > self.bufferValue)) return;
    _progressValue = progressValue;
    
    //调整进度条的值
    CGFloat viewW = [self viewWidthWithValue:progressValue];
    CGRect progressViewFrame = {self.progressView.frame.origin, {viewW, self.progressView.frame.size.height}};
    self.progressView.frame = progressViewFrame;
    
    NSString *currentPlayBackTimeStr = [ZPTools formatTime:self.progressValue];
    NSString *totalTimeStr = [ZPTools formatTime:self.maxValue];
    
    NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentPlayBackTimeStr, totalTimeStr];
    self.timeLabel.text = timeStr;
//    CGRect timelabelFrame = self.timeLabel.frame;
//    NSLog(@"%@", timelabelFrame);
    
    //调整进度条按钮的值
    self.sliderButton.center = CGPointMake(viewW, self.sliderButton.center.y);
}

-(void)setBufferValue:(CGFloat)bufferValue {
    if (ABS(_bufferValue - bufferValue) < Inaccuracy) return;
    if ((bufferValue < 0.0f) || (bufferValue > self.maxValue)) return;
    _bufferValue = bufferValue;
    
    CGFloat bufViewW = [self viewWidthWithValue:bufferValue];
    
    CGRect bufferViewRect = {self.bufferView.frame.origin, {bufViewW, self.bufferView.frame.size.height}};
    self.bufferView.frame = bufferViewRect;
}

#pragma mark - Create Subview
-(void) createSubview {
    [self createBackgroundView];
    [self createBufferView];
    [self createProgressView];
    [self createSliderButton];
    [self createTimeLabel];
}

-(void) createBackgroundView {
    UIView *backgroundView = [[UIView alloc]init];
    backgroundView.backgroundColor = self.backColor;
//    backgroundView.backgroundColor = [UIColor redColor];
    [self addSubview:backgroundView];
    self.backgroundView = backgroundView;
}

-(void) createProgressView {
    UIView *progressView = [[UIView alloc]init];
    progressView.backgroundColor = self.progressColor;
    [self addSubview:progressView];
    self.progressView = progressView;
}

-(void) createBufferView {
    UIView *bufferView = [[UIView alloc]init];
    bufferView.backgroundColor = self.bufferColor;
    [self addSubview:bufferView];
    self.bufferView = bufferView;
}

-(void) createSliderButton {
    UIButton *sliderBtn = [[UIButton alloc]init];
    sliderBtn.backgroundColor = self.sliderButtonColor;
    
    
    [sliderBtn addTarget:self action:@selector(sliderButtonBeginSliding) forControlEvents:UIControlEventTouchDown];
    [sliderBtn addTarget:self action:@selector(sliderButtonEndSliding) forControlEvents:UIControlEventTouchCancel];
    [sliderBtn addTarget:self action:@selector(sliderButtonEndSliding) forControlEvents:UIControlEventTouchDragExit];
    [sliderBtn addTarget:self action:@selector(sliderButtonEndSliding) forControlEvents:UIControlEventTouchUpInside];
    [sliderBtn addTarget:self action:@selector(dragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    
    sliderBtn.layer.cornerRadius = kZPVideoProgressBarButtonSize / 2;
    sliderBtn.layer.masksToBounds = YES;
    
    [self addSubview:sliderBtn];
    self.sliderButton = sliderBtn;
}

-(void)createTimeLabel {
    UILabel *timeLabel = [[UILabel alloc]init];
//    timeLabel.backgroundColor = [UIColor redColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.textColor = [UIColor whiteColor];
    [self addSubview:timeLabel];
    self.timeLabel = timeLabel;
}


-(void)layoutSubviews {
    [super layoutSubviews];
//    NSLog(@"layout subview");
    
    //只有第一次加载时才需要布局子控件
    if (!self.isFirstLayousSubView) return;
    
    CGFloat boundsHeight = self.bounds.size.height;
    
    //1.设置背景
    CGFloat backgroundViewW = self.bounds.size.width;
    CGFloat backgroundViewH = kZPVideoProgressBarHeigth;
    CGFloat backgroundViewX = 0;
    CGFloat backgroundViewY = (boundsHeight - kZPVideoProgressBarHeigth) / 2;
    self.backgroundView.frame = CGRectMake(backgroundViewX, backgroundViewY, backgroundViewW, backgroundViewH);
    
    //2.设置进度条和缓冲条
    CGRect viewInitialFrame = CGRectMake(0, backgroundViewY, 0, kZPVideoProgressBarHeigth);
    self.bufferView.frame = viewInitialFrame;
    self.progressView.frame = viewInitialFrame;
    
    //3.设置按钮
    CGFloat btnW = kZPVideoProgressBarButtonSize;
    CGFloat btnH = btnW;
    CGFloat btnX = -0.5 * btnW;
    CGFloat btnY = 0.5 * (boundsHeight - btnH);
    self.sliderButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
    
    //4.label
    CGFloat labelW = backgroundViewW;
    CGFloat labelH = (boundsHeight - backgroundViewH) / 2;
    CGFloat labelX = 0;
    CGFloat labelY = boundsHeight - labelH;
    self.timeLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
    self.isFirstLayousSubView = NO;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - Convert method
-(CGFloat)viewWidthWithValue:(CGFloat)value {
    return value / self.maxValue * self.bounds.size.width;
}

-(CGFloat)valueWithViewWidth:(CGFloat)width {
    return width * self.bounds.size.width / self.maxValue;
}

-(void)dealloc {
    NSLog(@"progressbar dealloc");
//    [self.subviews firstObject]removeFromSuperview
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}


#pragma mark - Action
-(void)dragMoving:(UIButton*)btn withEvent:(UIEvent*)event {
    CGPoint touchPoint = [[[event allTouches]anyObject]locationInView:self];
    NSLog(@"%f %f", touchPoint.x, touchPoint.y);
    CGFloat offset = touchPoint.x - btn.center.x;
    CGFloat progressNewValue = self.progressValue + (offset / self.bounds.size.width * self.maxValue);
    [self setProgressValue:progressNewValue];
}

-(void) sliderButtonBeginSliding {
    NSLog(@"start drag");
    self.isDraging = YES;
}

-(void) sliderButtonEndSliding {
    NSLog(@"end drag");
    self.isDraging = NO;
    CGFloat val = self.sliderButton.center.x / self.bounds.size.width * self.maxValue;
    if ([self.delegate respondsToSelector:@selector(videoProgressEndSlidingWithValue:)]) {
        [self.delegate performSelector:@selector(videoProgressEndSlidingWithValue:) withObject:@(val)];
    }
}
@end
