//
//  ZPVideoInfo.h
//  PlayDemo
//
//  Created by HZP on 2017/5/25.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - ENUM

/**
 *  视频类型
 */
typedef NS_ENUM(NSUInteger, ZPVideoType) {
    /**普通类型*/
    ZPVideoTypeNormal,
    /**预告*/
    ZPVideoTypeTrailer
};

/**
 *  视频属性类型
 */
typedef NS_ENUM(NSUInteger, ZPVideoPropertyType) {
    /**单视频专辑*/
    ZPVideoPropertyTypeSingleAlbum,
    /**电视剧*/
    ZPVideoPropertyTypeTelevision,
    /**综艺节目*/
    ZPVideoPropertyTypeVarietyShow
};


#pragma mark - ZPViderInfo
/**
 *   播放器信息模型
 */
@interface ZPVideoInfo : NSObject

#pragma mark - Property
/**
 *  id
 */
@property (nonatomic, copy) NSString *ID;
/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;
/**
 *  视频短标题
 */
@property (nonatomic, copy) NSString *shortTitle;
/**
 *  图片链接
 */
@property (nonatomic, copy) NSString *img;
/**
 *  视频评分
 */
@property (nonatomic, assign) float snsScore;
/**
 *  播放次数
 */
@property (nonatomic, copy) NSString *playCount;
/**
 *  格式化后的播放次数
 */
@property (nonatomic, copy) NSString *playCountText;
/**
 *  album_id, 专辑 id
 */
@property (nonatomic, copy) NSString *aID;
/**
 *  tvid
 */
@property (nonatomic, copy) NSString *tvID;
/**
 *  是否vip
 */
@property (nonatomic, copy) NSString *isVip;
/**
 *  视频类型
 */
@property (nonatomic, assign) ZPVideoType type;
/**
 *  视频属性类型
 */
@property (nonatomic, assign) ZPVideoPropertyType pType;
/**
 *  视频发布时间的时间戳
 */
@property (nonatomic, copy) NSString *dateTimeStamp;
/**
 *  格式化之后的视频发布时间,精确到哪天
 */
@property (nonatomic, copy) NSString *dateFormat;
/**
 *  此视频所属专辑一共有多少个视频
 */
@property (nonatomic, assign) NSUInteger totalNum;
/**
 *  此视频所属专辑更新到了第几个视频
 */
@property (nonatomic, assign) NSUInteger updateNum;
/**
 *  该参数只对剧集列表接口有效 (video?type=album_video_list)] 
 *  表示当前视频是所属剧集的第几集,如 100 集, episode=100
 */
@property (nonatomic, assign) NSUInteger episode;

#pragma mark - method
-(instancetype)initWithDict:(NSDictionary*)dict;
+(instancetype)videoInfoWithDict:(NSDictionary*)dict;
@end
