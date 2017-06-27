//
//  ZPChannel.m
//  PlayDemo
//
//  Created by HZP on 2017/6/13.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ZPChannel.h"

@implementation ZPChannel

-(instancetype)initWithID:(NSString*)channelID name:(NSString*)name desc:(NSString*)desc {
    if (self = [super init]) {
        _channelID = channelID;
        _name = name;
        _desc = desc;
    }
    return self;
}

-(instancetype)init {
    return nil;
}

-(instancetype)initWithDict:(NSDictionary*)dict {
    return [self initWithID:dict[@"id"] name:dict[@"name"] desc:dict[@"desc"]];
}
+(instancetype)channelWithDict:(NSDictionary*)dict {
    return [[self alloc]initWithDict:dict];
}
@end
