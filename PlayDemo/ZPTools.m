//
//  ZPTools.m
//  PlayDemo
//
//  Created by HZP on 2017/5/26.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ZPTools.h"
#import <AVFoundation/AVFoundation.h>

@implementation ZPTools
+(UIImage*)screenShots:(UIView*)view {
    UIImage *resImage = nil;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0f);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    resImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resImage;
}

+(UIImage*)screenShotsInWindowWithFrame:(CGRect)frame {
    UIImage *image = nil;
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIApplication sharedApplication].delegate.window.layer renderInContext:context];
//    [[UIApplication sharedApplication].keyWindow.layer renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
+(UIImage*)screenShots {
    UIImage *image = nil;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIGraphicsBeginImageContext(window.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [window.layer  renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
+(UIImage*)screenShotsInStream:(UIView*)view {
    UIImage *resImage = nil;
    UIGraphicsBeginImageContext(view.bounds.size);
    [view drawViewHierarchyInRect:view.frame afterScreenUpdates:YES];
//    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0f);
//    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    resImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resImage;
}

+(UIImage*)screenShotsWithStream {
    return nil;
}

static const int SecondPerMinute = 60;
static const int SecondsPerHour = 60 * SecondPerMinute;
+(NSString*)formatTime:(double)t {
    int time = (int)t;
    int hour = time / SecondsPerHour;
    time %= SecondsPerHour;
    NSString *hourStr = (hour < 10) ? [NSString stringWithFormat:@"0%d", hour] : [NSString stringWithFormat:@"%d", hour];
    
    int minutes = time / SecondPerMinute;
    time %= SecondPerMinute;
    NSString *minutesStr = (minutes < 10) ? [NSString stringWithFormat:@"0%d", minutes] : [NSString stringWithFormat:@"%d", minutes];
    
    int seconds = time;
    NSString *secondsStr = (seconds < 10) ? [NSString stringWithFormat:@"0%d", seconds] : [NSString stringWithFormat:@"%d", seconds];
    
    NSString *timeStr = [NSString stringWithFormat:@"%@:%@:%@", hourStr, minutesStr, secondsStr];
    return timeStr;
}

@end
