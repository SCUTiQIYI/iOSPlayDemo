//
//  AppDelegate.m
//  PlayDemo
//
//  Copyright (c) 2017-present, IQIYI, Inc. All rights reserved.
//


#import "AppDelegate.h"
#import "ZPHomePageViewController.h"
#import "ViewController.h"
#import "ZPSearchPageViewController.h"
#import "QYPlayerController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //必须调用
    [[QYPlayerController sharedInstance] initPlayer];
    
    UIWindow *windows = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *vc = [[ZPHomePageViewController alloc] init];
//    UIViewController *vc = [[ZPSearchPageViewController alloc] init];
//    UIViewController *vc = [[ViewController alloc] init];
//    ZPChannelPageController *vc = [[ZPChannelPageController alloc] init];
//    vc.view.backgroundColor = [UIColor redColor];
    self.window = windows;
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    return YES;
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
   }

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    //[[QYAudioSessionManager shareInstance] applicationWillEnterForeground];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
