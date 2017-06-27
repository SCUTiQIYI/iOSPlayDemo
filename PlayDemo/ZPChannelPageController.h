//
//  ChannelPageController.h
//  PlayDemo
//
//  Created by HZP on 2017/6/13.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZPChannel;

/**
 *  频道列表界面
 */
@interface ZPChannelPageController : UITableViewController
@property (nonatomic, strong) ZPChannel *channel;
@end
