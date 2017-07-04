//
//  ChannelCollectionViewCellDataModel.h
//  PlayDemo
//
//  Created by xiaojie on 2017/7/3.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZPVideoInfo;
@interface ChannelCollectionViewCellDataModel : NSObject
@property (nonatomic, copy)NSString *imgUrl;
@property (nonatomic, copy)NSString *text;
@property (nonatomic, copy)NSString *detailText;
@property (nonatomic, copy)NSString *isVip;
- (instancetype) initWithDict:(ZPVideoInfo *)info;

@end
