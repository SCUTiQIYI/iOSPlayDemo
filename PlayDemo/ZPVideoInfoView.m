//
//  ZPVideoInfoView.m
//  PlayDemo
//
//  Created by HZP on 2017/6/10.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ZPVideoInfoView.h"
#import "ZPVideoInfo.h"
@interface ZPVideoInfoView()
/**显示视频标题*/
@property (nonatomic, weak) UILabel *titleLabel;
/**显示视频子标题*/
@property (nonatomic, weak) UILabel *shortTitleLabel;
/**显示视频封面*/
@property (nonatomic, weak) UIImageView *imageView;
/**显示视频评分*/
@property (nonatomic, weak) UILabel *scoreLabel;
/**显示视频播放数*/
@property (nonatomic, weak) UILabel *playCountLabel;
/**显示视频类型*/
@property (nonatomic, weak) UILabel *videoTypeLabel;
/**显示视频子类型*/
@property (nonatomic, weak) UILabel *videoPropertyTypeLabel;
/**显示视频发布时间*/
@property (nonatomic, weak) UILabel *dateLabel;


@end


@implementation ZPVideoInfoView

#pragma mark - Init Method
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self myInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self myInit];
    }
    return self;
}

-(void)myInit {
    [self createSubView];
}

#pragma mark - Create Subview
-(void)createSubView {
    UILabel *title = [[UILabel alloc]init];
    title.numberOfLines = 0;
//    [title setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle1]];
    [self addSubview:title];
    self.titleLabel = title;
    
    UILabel *shortTitle = [[UILabel alloc]init];
//    [shortTitle setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle2]];
    [self addSubview:shortTitle];
    self.shortTitleLabel = shortTitle;
    
    UIImageView *imageView = [[UIImageView alloc]init];
    [self addSubview:imageView];
    self.imageView = imageView;
    
    UILabel *score = [[UILabel alloc]init];
//    [score setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [self addSubview:score];
    self.scoreLabel = score;
    
    UILabel *playCount = [[UILabel alloc]init];
//    [playCount setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [self addSubview:playCount];
    self.playCountLabel = playCount;
    
    UILabel *vedioType = [[UILabel alloc]init];
//    [vedioType setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [self addSubview: vedioType];
    self.videoTypeLabel = vedioType;
    
    UILabel *videoProperty = [[UILabel alloc]init];
//    [videoProperty setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [self addSubview:videoProperty];
    self.videoPropertyTypeLabel = videoProperty;
    
    UILabel *dataTime = [[UILabel alloc]init];
//    [dataTime setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [self addSubview:dataTime];
    self.dateLabel = dataTime;
}


#pragma mark - Setter
-(void)setInfo:(ZPVideoInfo *)info {
    _info = info;
    self.titleLabel.text = [NSString stringWithFormat:@"标题:%@", info.title];
    self.shortTitleLabel.text = [NSString stringWithFormat:@"副标题:%@", info.shortTitle];
    /**显示视频封面*/
//    @property (nonatomic, weak) UIImageView *imageView;
    self.scoreLabel.text = [NSString stringWithFormat:@"评分:%lf分", info.snsScore];
    self.playCountLabel.text = [NSString stringWithFormat:@"播放数:%@", info.playCountText];
    if (info.type == ZPVideoTypeNormal) {
        self.videoTypeLabel.text = @"正片";
    } else if (info.type == ZPVideoTypeTrailer) {
        self.videoTypeLabel.text = @"预告片";
    }
    if (info.pType == ZPVideoPropertyTypeTelevision) {
        self.videoPropertyTypeLabel.text = @"电视剧";
    } else if (info.pType == ZPVideoPropertyTypeSingleAlbum) {
        self.videoPropertyTypeLabel.text = @"专辑";
    } else if (info.pType == ZPVideoPropertyTypeVarietyShow) {
        self.videoPropertyTypeLabel.text = @"综艺节目";
    }
    self.dateLabel.text = [NSString stringWithFormat:@"发布日期:%@", info.dateFormat];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    [self.titleLabel sizeToFit];
    [self.shortTitleLabel sizeToFit];
    [self.scoreLabel sizeToFit];
    [self.playCountLabel sizeToFit];
    [self.videoTypeLabel sizeToFit];
    [self.videoPropertyTypeLabel sizeToFit];
    [self.dateLabel sizeToFit];
    
    CGRect frame = self.titleLabel.frame;
    self.titleLabel.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    frame = self.shortTitleLabel.frame;
    self.shortTitleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), frame.size.width, frame.size.height);
    
    frame = self.scoreLabel.frame;
    self.scoreLabel.frame = CGRectMake(0, CGRectGetMaxY(self.shortTitleLabel.frame), frame.size.width, frame.size.height);
    
    frame = self.playCountLabel.frame;
    self.playCountLabel.frame = CGRectMake(0, CGRectGetMaxY(self.scoreLabel.frame), frame.size.width, frame.size.height);
    
    
    frame = self.videoTypeLabel.frame;
    self.videoTypeLabel.frame = CGRectMake(0, CGRectGetMaxY(self.playCountLabel.frame), frame.size.width, frame.size.height);
    
    
    frame = self.videoPropertyTypeLabel.frame;
    self.videoPropertyTypeLabel.frame = CGRectMake(0, CGRectGetMaxY(self.videoTypeLabel.frame), frame.size.width, frame.size.height);
    
    
    frame = self.dateLabel.frame;
    self.dateLabel.frame = CGRectMake(0, CGRectGetMaxY(self.videoPropertyTypeLabel.frame), frame.size.width, frame.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
