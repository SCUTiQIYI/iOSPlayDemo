//
//  CollectionReusableFooterView.h
//  PlayDemo
//
//  Created by 肖杰 on 2017/6/17.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CollectionReusableFooterViewDelegate <NSObject>
/**
 *  获取更多视频的按钮被点击
 */
- (void)CollectionReusableFooterViewMoreVideoBtnClick:(UIButton *)btn;
/**
 *  换一批视频的按钮被点击
 */
- (void)CollectionReusableFooterViewChangeVideoBtnClick:(UIButton *)btn;
@end

@interface CollectionReusableFooterView : UICollectionReusableView
/**
 *  换一批
 */
@property (nonatomic, weak) UIButton *changeVideoBtn;
/**
 *  点击加载更多
 */
@property (nonatomic, weak)UIButton *moreVideoBtn;
@property (nonatomic, weak)id<CollectionReusableFooterViewDelegate> delegate;
@end
