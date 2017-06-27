//
//  CollectionReusableBannerHeaderView.h
//  PlayDemo
//
//  Created by 李呱呱 on 2017/6/18.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYBannerView.h"

@interface CollectionReusableBannerHeaderView : UICollectionReusableView

@property (nonatomic, strong) ZYBannerView *bannerView;

@property (nonatomic, strong)UILabel *lable;

@end
