//
//  MyPlayerViewController.h
//  PlayDemo
//
//  Created by HZP on 2017/5/25.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZPVideoInfo;


/**
 *  播放器页面
 */
@interface ZPPlayerViewController : UIViewController
/**
 *  播放视频模型
 */
@property (nonatomic, strong) ZPVideoInfo *videoInfo;


@end
