//
//  ZPChannelInfo.h
//  PlayDemo
//
//  Created by HZP on 2017/6/11.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZPChannelInfo : NSObject
/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;
/**
 *  视频列表
 */
@property (nonatomic, strong) NSArray *video_list;
/**
 *  频道名称
 */
@property (nonatomic, copy) NSString *channel_name;
/**
 *  频道id
 */
@property (nonatomic, copy) NSString *channel_id;

-(instancetype)initWithDict:(NSDictionary*)dict;
+(instancetype)channelInfoWithDict:(NSDictionary*)dict;
@end
