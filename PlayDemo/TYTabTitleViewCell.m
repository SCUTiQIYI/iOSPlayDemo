//
//  TYTabTitleViewCell.m
//  TYPagerControllerDemo
//
//  Created by tany on 16/5/4.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "TYTabTitleViewCell.h"

@interface TYTabTitleViewCell ()
@property (nonatomic, weak) UILabel *titleLabel;
@end

@implementation TYTabTitleViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addTabTitleLabel];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self addTabTitleLabel];
    }
    return self;
}

- (void)addTabTitleLabel
{
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = [UIColor darkTextColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:titleLabel];
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.clipsToBounds = YES;
    _titleLabel = titleLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _titleLabel.frame = self.contentView.bounds;
}

@end
