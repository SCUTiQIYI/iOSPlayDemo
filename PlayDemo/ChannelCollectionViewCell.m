//
//  ChannelCollectionViewCell.m
//  PlayDemo
//
//  Created by xiaojie on 2017/7/3.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ChannelCollectionViewCell.h"
#import "ChannelCollectionViewCellDataModel.h"
#import "UIImageView+AFNetworking.h"

static const CGFloat kVipImageViewSize = 15.0;
@interface ChannelCollectionViewCell () {
    CGFloat width;
    CGFloat height;
}

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *text;
@property (nonatomic, strong) UILabel *detailLable;
@property (nonatomic, strong) UIImageView *vipImageView;

@end

@implementation ChannelCollectionViewCell

- (instancetype)init {
    return [[ChannelCollectionViewCell alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imgView = [[UIImageView alloc] init];
        _text = [[UILabel alloc] init];
        _detailLable = [[UILabel alloc] init];
        _vipImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"vip"]];
        [_detailLable setTextColor:UIColor.lightGrayColor];
        [self addSubview:_imgView];
        [self addSubview:_text];
        [self addSubview:_detailLable];
        [self addSubview:_vipImageView];
        _text.font = [UIFont systemFontOfSize:12];
        _detailLable.font = [UIFont systemFontOfSize:10];
    }
    return self;
}

- (void)setDataModel:(ChannelCollectionViewCellDataModel *)dataModel {
    _dataModel = dataModel;
    [_imgView setImageWithURL:[NSURL URLWithString:dataModel.imgUrl]];
    _text.text = dataModel.text;
    _detailLable.text = dataModel.detailText;
    if ([dataModel.isVip isEqualToString:@"1"]) {
        _vipImageView.hidden = NO;
    } else {
        _vipImageView.hidden = YES;
    }
}

- (void)layoutSubviews {
    width = self.bounds.size.width;
    height = self.bounds.size.height;
    _imgView.frame =CGRectMake(0, 0, width, height-35);
    _text.frame = CGRectMake(0, height-35, width, 20);
    _detailLable.frame = CGRectMake(0, height-15, width, 10);
    _vipImageView.frame = CGRectMake(width - kVipImageViewSize, 0, kVipImageViewSize, kVipImageViewSize);
}

@end
