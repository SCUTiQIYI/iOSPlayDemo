//
//  ZPChannel.h
//  PlayDemo
//
//  Created by HZP on 2017/6/13.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZPChannel : NSObject
/**
 *  频道id
 */
@property (nonatomic, copy) NSString *channelID;
/**
 *  频道名称
 */
@property (nonatomic, copy) NSString *name;
/**
 *  频道描述
 */
@property (nonatomic, copy) NSString *desc;

/**
 *  designed constructor
 */
-(instancetype)initWithID:(NSString*)channelID name:(NSString*)name desc:(NSString*)desc;
-(instancetype)initWithDict:(NSDictionary*)dict;
+(instancetype)channelWithDict:(NSDictionary*)dict;


@end
