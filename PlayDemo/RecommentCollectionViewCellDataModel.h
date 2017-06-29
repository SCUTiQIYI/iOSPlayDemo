//
//  RecommentCollectionViewCellDataModel.h
//  PlayDemo
//
//  Created by 肖杰 on 2017/6/16.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPVideoInfo.h"
@interface RecommentCollectionViewCellDataModel : NSObject

@property (nonatomic, copy)NSString *imgUrl;
@property (nonatomic, copy)NSString *text;
@property (nonatomic, copy)NSString *detailText;
@property (nonatomic, assign)BOOL isShowDetailLable;

- (instancetype) initWithDict:(ZPVideoInfo *)info;

@end
