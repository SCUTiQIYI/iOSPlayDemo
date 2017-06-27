//
//  ZPVideoInfo.m
//  PlayDemo
//
//  Created by HZP on 2017/5/25.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ZPVideoInfo.h"

@implementation ZPVideoInfo


-(instancetype)initWithDict:(NSDictionary*)dict {
    if (self = [super init]) {
        _ID = dict[@"id"];
        _title = dict[@"title"];
        _shortTitle = dict[@"short_title"];
        _img = dict[@"img"];
        _snsScore = [dict[@"sns_score"] floatValue];
    
        _playCount = dict[@"play_count"];
        _playCountText = dict[@"play_count_text"];
        _aID = dict[@"a_id"];
        _tvID = dict[@"tv_id"];
        _isVip = dict[@"is_vip"];
        
        NSString *typeStr = dict[@"type"];
        if ([typeStr isEqualToString:@"normal"]) {
            _type = ZPVideoTypeNormal;
        } else if ([typeStr isEqualToString:@"trailer"]) {
            _type = ZPVideoTypeTrailer;
        }
        
        int pTypeIntVal = [dict[@"p_type"] intValue];
        switch (pTypeIntVal) {
            case 1:
                _pType = ZPVideoPropertyTypeSingleAlbum;
                break;
            case 2:
                _pType = ZPVideoPropertyTypeTelevision;
                break;
            case 3:
                _pType = ZPVideoPropertyTypeVarietyShow;
        }
        
        _dateTimeStamp = dict[@"date_timestamp"];
        _dateFormat = dict[@"date_format"];
        _totalNum = [dict[@"total_num"] integerValue];
        _updateNum = [dict[@"update_num"] integerValue];
        _episode = [dict[@"episode"] integerValue];
    }
    return self;
}
+(instancetype)videoInfoWithDict:(NSDictionary*)dict {
    return [[self alloc]initWithDict:dict];
}

@end
