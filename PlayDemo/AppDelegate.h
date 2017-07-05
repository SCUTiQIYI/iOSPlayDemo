//
//  AppDelegate.h
//  PlayDemo
//
//  Copyright (c) 2017-present, IQIYI, Inc. All rights reserved.
//



#import <UIKit/UIKit.h>
@class AFHTTPSessionManager;
@class AFURLSessionManager ;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (AFHTTPSessionManager *)sharedHTTPSession;
- (AFURLSessionManager *)sharedURLSession;
@end

