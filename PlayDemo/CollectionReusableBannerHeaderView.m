//
//  CollectionReusableBannerHeaderView.m
//  PlayDemo
//
//  Created by 李呱呱 on 2017/6/18.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "CollectionReusableBannerHeaderView.h"

@implementation CollectionReusableBannerHeaderView

- (instancetype)init {
    return [[CollectionReusableBannerHeaderView alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _bannerView = [[ZYBannerView alloc]init];
        _bannerView.shouldLoop = YES;
        _bannerView.autoScroll = YES;
        _bannerView.scrollInterval = 5.0f;
        [self addSubview:_bannerView];
        _lable = [[UILabel alloc] init];
        [self addSubview:_lable];
    }
    return self;
}

-(void)layoutSubviews {
    _bannerView.frame = CGRectMake(0, 0, self.bounds.size.width, 160);
    _lable.frame = CGRectMake(0, 162, self.bounds.size.width/2, self.bounds.size.height-160);
    _lable.font = [UIFont systemFontOfSize:14];
}

@end
