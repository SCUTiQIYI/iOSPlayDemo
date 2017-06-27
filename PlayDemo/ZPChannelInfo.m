//
//  ZPChannelInfo.m
//  PlayDemo
//
//  Created by HZP on 2017/6/11.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ZPChannelInfo.h"
#import "ZPVideoInfo.h"
@implementation ZPChannelInfo

-(instancetype)initWithDict:(NSDictionary*)dict {
    if (self = [super init]) {
        _title = dict[@"title"];
        
        NSArray *videoListArr = dict[@"video_list"];
        NSMutableArray *videos = [NSMutableArray array];
        for (NSDictionary *dict in videoListArr) {
            ZPVideoInfo *videoInfo = [ZPVideoInfo videoInfoWithDict:dict];
            [videos addObject:videoInfo];
        }
        _video_list = videos;
        
        _channel_name = dict[@"channel_name"];
        _channel_id = dict[@"channel_id"];
    }
    return self;
}

+(instancetype)channelInfoWithDict:(NSDictionary*)dict {
    return [[self alloc]initWithDict:dict];
}
@end
