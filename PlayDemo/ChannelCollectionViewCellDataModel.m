//
//  ChannelCollectionViewCellDataModel.m
//  PlayDemo
//
//  Created by xiaojie on 2017/7/3.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ChannelCollectionViewCellDataModel.h"
#import "ZPVideoInfo.h"

@implementation ChannelCollectionViewCellDataModel
- (instancetype) initWithDict:(ZPVideoInfo *)info {
    if (self = [super init]) {
        _imgUrl = info.img;
        _text = info.title;
        if ([info.title isEqualToString:info.shortTitle]) {
            _detailText = [NSString stringWithFormat:@"%@",info.dateFormat];
        } else {
            _detailText = info.shortTitle;
        }
    }
    return self;
}
@end
