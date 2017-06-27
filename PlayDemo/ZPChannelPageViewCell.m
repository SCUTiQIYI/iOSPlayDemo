//
//  ZPChannelPageTableViewCell.m
//  PlayDemo
//
//  Created by HZP on 2017/6/13.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ZPChannelPageViewCell.h"
#import "ZPVideoInfo.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"




const CGFloat kCellImageHeight = 100;
const CGFloat kCellTitleLabelHeight = 20;
const CGFloat kCellMargin = 5;
static const CGFloat kVipViewSize = 12;

@interface ZPChannelPageViewCell ()

/**
 *  视频封面
 */
@property (nonatomic, weak) UIImageView *coverView;
/**
 *  视频标题
 */
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *detailLabel;
@property (nonatomic, weak) UIImageView *isVipView;
@end

@implementation ZPChannelPageViewCell

#pragma mark - Init Method
/**
 *  快速构造方法
 */
+(instancetype)cellWithTableView:(UITableView*) tableView {
    static NSString *cellID = @"ChannelPageCellID";
    ZPChannelPageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[ZPChannelPageViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    return cell;
}

/**
 *  指定构造方法
 */
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        [self removeOriginalSubView];
        [self createSubView];
    }
    return self;
}
-(void) removeOriginalSubView {
//    self.coverView removeFromSuperview
    [self.coverView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - Create Subview
-(void)createSubView {
//    self.contentView.backgroundColor = [UIColor yellowColor];
    UIImageView *coverView = [[UIImageView alloc]init];
    
//    coverView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:coverView];
    self.coverView = coverView;
    
    UILabel *titleLabel = [[UILabel alloc]init];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *detailLabel = [[UILabel alloc]init];
    [detailLabel setTextAlignment:NSTextAlignmentLeft];
    [detailLabel setTextColor:UIColor.lightGrayColor];
    [detailLabel setFont:[UIFont systemFontOfSize:UIFontWeightLight]];
    [detailLabel setNumberOfLines:0];
    [self.contentView addSubview:detailLabel];
    self.detailLabel = detailLabel;
    
    UIImageView *isVipView = [[UIImageView alloc]init];
    isVipView.image = [UIImage imageNamed:@"vip"];
    [self.contentView addSubview:isVipView];
    self.isVipView = isVipView;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self setCellFrame];
}

#pragma mark - Setter

-(void)setVideoInfo:(ZPVideoInfo *)videoInfo {
    _videoInfo = videoInfo;
    [self setCellData:videoInfo];
    [self setCellFrame];
}

/**
 *  设置cell显示数据
 */
-(void)setCellData:(ZPVideoInfo*)info {
    
    self.titleLabel.text = info.shortTitle;
    self.detailLabel.text = [[NSString alloc] initWithFormat:@"评分: %.1f\t\t播放量: %@\n\n发布时间: %@",info.snsScore,info.playCountText,info.dateFormat];
    [self.coverView sd_setImageWithURL:[NSURL URLWithString:info.img] placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if(error != nil){
            [self.coverView setImage:[UIImage imageNamed:@"failLoading"]];
        }
    }];
    //[self.coverView setImageWithURL:];
    if ([info.isVip isEqualToString:@"1"]) {
        self.isVipView.hidden = NO;
    } else {
        self.isVipView.hidden = YES;
    }
}

/**
 *  设置cell布局
 */
-(void)setCellFrame {
    [self.contentView setBounds:self.bounds];
    CGSize contentViewSize = self.contentView.bounds.size;
    
    
    CGFloat coverX = kCellMargin;
    CGFloat coverY = kCellMargin;
    CGFloat coverH = kCellImageHeight;
    CGFloat coverW = 75;
    self.coverView.frame = CGRectMake(coverX, coverY, coverW, coverH);
    NSLog(@"%f",coverW);
    
    CGFloat vipW = kVipViewSize;
    CGFloat vipH = kVipViewSize;
    CGFloat vipX = CGRectGetMaxX(self.coverView.frame) + kCellMargin;
    CGFloat vipY = kCellMargin;
    self.isVipView.frame = CGRectMake(vipX, vipY, vipW, vipH);
    
    
    CGFloat titleLabelH = kCellTitleLabelHeight;
    CGFloat titleLabelW = contentViewSize.width - coverW - vipW - 3 * kCellMargin;
    CGFloat titleLabelX = CGRectGetMaxX(self.isVipView.frame) + kCellMargin;
    CGFloat titleLabelY = 0+kCellMargin;
    
    self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    
    CGFloat detailLabelH = CGRectGetMaxY(self.coverView.frame)-CGRectGetMaxY(self.titleLabel.frame)-kCellMargin;
    CGFloat detailLabelW = CGRectGetWidth(self.titleLabel.frame);
    CGFloat detailLabelX = CGRectGetMinX(self.titleLabel.frame);
    CGFloat detailLabelY = CGRectGetMaxY(self.titleLabel.frame)+kCellMargin;
    self.detailLabel.frame = CGRectMake(detailLabelX, detailLabelY, detailLabelW, detailLabelH);
}

@end
