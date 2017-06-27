//
//  ZPTools.h
//  PlayDemo
//
//  Created by HZP on 2017/5/26.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ZPTools : NSObject

/**
 *  对UIView进行截图
 */
+(UIImage*)screenShots:(UIView*)view;

/**
 *  对窗口进行截图
 */
+(UIImage*)screenShotsInWindowWithFrame:(CGRect)frame;

/**
 *  对整个屏幕截图
 */
+(UIImage*)screenShots;
/**
 *  对视频流截图
 */
+(UIImage*)screenShotsInStream:(UIView*)view;
+(UIImage*)screenShotsWithStream;

/**
 *  获得格式化的播放时长
 */
+(NSString*)formatTime:(double)time;
@end
