//
//  ZPChannelPageTableViewCell.h
//  PlayDemo
//
//  Created by HZP on 2017/6/13.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import <UIKit/UIKit.h>


extern const CGFloat kCellImageHeight;
extern const CGFloat kCellTitleLabelHeight;
extern const CGFloat kCellMargin;

@class ZPVideoInfo;



@interface ZPChannelPageViewCell : UITableViewCell

@property (nonatomic, strong) ZPVideoInfo *videoInfo;

/**
 *  快速构造方法
 */
+(instancetype) cellWithTableView:(UITableView*) tableView;

@end
