//
//  RecommentCollectionViewCell.m
//  PlayDemo
//
//  Created by 肖杰 on 2017/6/16.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "RecommentCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface RecommentCollectionViewCell (){
    CGFloat width;
    CGFloat height;
}

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *text;
@property (nonatomic, strong) UILabel *detailLable;

@end

@implementation RecommentCollectionViewCell

- (instancetype)init {
    return [[RecommentCollectionViewCell alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imgView = [[UIImageView alloc] init];
        _text = [[UILabel alloc] init];
        _detailLable = [[UILabel alloc] init];
        [_detailLable setTextColor:UIColor.lightGrayColor];
        [self addSubview:_imgView];
        [self addSubview:_text];
        [self addSubview:_detailLable];
        _text.font = [UIFont systemFontOfSize:12];
        _detailLable.font = [UIFont systemFontOfSize:10];
        _text.backgroundColor = [UIColor whiteColor];
        _text.layer.masksToBounds = YES;
        _detailLable.backgroundColor = [UIColor whiteColor];
        _detailLable.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setDataModel:(RecommentCollectionViewCellDataModel *)dataModel {
    _dataModel = dataModel;
    [_imgView setImageWithURL:[NSURL URLWithString:dataModel.imgUrl]];
    _text.text = dataModel.text;
    if (_dataModel.isShowDetailLable) {
          _detailLable.text = dataModel.detailText;
    }
  
}

- (void)layoutSubviews {
    width = self.bounds.size.width;
    height = self.bounds.size.height;
    if (_dataModel.isShowDetailLable) {
        _imgView.frame =CGRectMake(0, 0, width, height-35);
        _text.frame = CGRectMake(0, height-35, width, 20);
        _detailLable.frame = CGRectMake(0, height-15, width, 10);
        _detailLable.hidden = false;
    } else {
        _imgView.frame =CGRectMake(0, 0, width, height-20);
        _text.frame = CGRectMake(0, height-20, width, 20);
        _detailLable.hidden = true;
    }
}


@end
