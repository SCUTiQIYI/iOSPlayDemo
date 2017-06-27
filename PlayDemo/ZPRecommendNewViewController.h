//
//  ZPRecommendNewViewController.h
//  PlayDemo
//
//  Created by HZP on 2017/6/16.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZPRecommendNewViewControllerDelegate <NSObject>
@optional
-(void)moreVideoButtonDidClick:(NSString*)channelTitle;

@end

/**
 *   推荐页面
 */
@interface ZPRecommendNewViewController : UIViewController

/**
 *  代理，用于传递那个按钮被点击的消息
 */
@property (nonatomic, weak) id<ZPRecommendNewViewControllerDelegate> delegate;
@end
