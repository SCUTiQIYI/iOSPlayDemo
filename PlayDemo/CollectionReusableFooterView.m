//
//  CollectionReusableFooterView.m
//  PlayDemo
//
//  Created by 肖杰 on 2017/6/17.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "CollectionReusableFooterView.h"

#define kFooterViewBtnTitleFont [UIFont systemFontOfSize:14]

static const CGFloat kSeparatorHeight = 15;
@interface CollectionReusableFooterView()
@property (nonatomic, weak) UIView *buttonSepartor;

@end

@implementation CollectionReusableFooterView
- (instancetype)init {
    return [[CollectionReusableFooterView alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self myInit];
    }
    return self;
}

- (void)myInit {
    [self setupSubView];
}

/**
 *  创建子控件
 */
-(void)setupSubView {
    //1. 更多视频按钮
    UIButton *moreVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreVideoBtn.titleLabel.font = kFooterViewBtnTitleFont;
    [moreVideoBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [moreVideoBtn setImage:[UIImage imageNamed:@"more-highlightened"] forState:UIControlStateHighlighted];
    [moreVideoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [moreVideoBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [moreVideoBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:moreVideoBtn];
    self.moreVideoBtn = moreVideoBtn;
    [self.moreVideoBtn.titleLabel setBackgroundColor:[UIColor whiteColor]];
    self.moreVideoBtn.titleLabel.clipsToBounds = YES;
  
    //2. 换一批视频按钮
    UIButton *changeVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];

    changeVideoBtn.titleLabel.font = kFooterViewBtnTitleFont;
    [changeVideoBtn setTitle:@"  换一批" forState:UIControlStateNormal];
    [changeVideoBtn setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [changeVideoBtn setImage:[UIImage imageNamed:@"refresh-highlightened"] forState:UIControlStateHighlighted];
    [changeVideoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [changeVideoBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [changeVideoBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:changeVideoBtn];
    self.changeVideoBtn = changeVideoBtn;
    self.changeVideoBtn.titleLabel.clipsToBounds = YES;
    [self.changeVideoBtn.titleLabel setBackgroundColor:[UIColor whiteColor]];
    
    //3. 分割线
    UIView *separator = [[UIView alloc]init];
    separator.backgroundColor = [UIColor blackColor];
    [self addSubview:separator];
    self.buttonSepartor = separator;
}

-(void)layoutSubviews {
    CGSize boundSize = self.bounds.size;
    CGSize btnSize = CGSizeMake(boundSize.width / 2, boundSize.height);
    
    self.moreVideoBtn.frame = CGRectMake(0, 0, btnSize.width, btnSize.height);
    self.changeVideoBtn.frame = CGRectMake(btnSize.width, 0, btnSize.width, btnSize.height);
    
    CGFloat separatorH = kSeparatorHeight;
    CGFloat separatorW = 1;
    CGFloat separatorX = btnSize.width;
    CGFloat separatorY = (boundSize.height - separatorH) / 2;
    
    self.buttonSepartor.frame = CGRectMake(separatorX, separatorY, separatorW, separatorH);
}

- (void)btnClick:(UIButton *)btn {
    if ([[btn titleForState:UIControlStateNormal]isEqualToString:@"  换一批"]) {
        if ([self.delegate respondsToSelector:@selector(CollectionReusableFooterViewChangeVideoBtnClick:)]) {
            [self.delegate performSelector:@selector(CollectionReusableFooterViewChangeVideoBtnClick:) withObject:btn];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(CollectionReusableFooterViewMoreVideoBtnClick:)]) {
            [self.delegate CollectionReusableFooterViewMoreVideoBtnClick:btn];
        }
    }
}

@end
