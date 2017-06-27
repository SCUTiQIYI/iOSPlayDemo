//
//  HomePageViewController.m
//  PlayDemo
//
//  Created by HZP on 2017/6/13.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ZPHomePageViewController.h"
#import "ActivityIndicatorView.h"
#import "TYTabButtonPagerController.h"
#import "ZPRecommendPageViewController.h"
#import "ZPChannelPageController.h"
#import "ZPChannel.h"
#import "ZPRecommendNewViewController.h"

#define kChannelListURL @"http://iface.qiyi.com/openapi/batch/channel?type=list&version=7.5&app_k=f0f6c3ee5709615310c0f053dc9c65f2&app_v=8.4&app_t=0&platform_id=12&dev_os=10.3.1&dev_ua=iPhone9,3&dev_hw=%7B%22cpu%22%3A0%2C%22gpu%22%3A%22%22%2C%22mem%22%3A%2250.4MB%22%7D&net_sts=1&scrn_sts=1&scrn_res=1334*750&scrn_dpi=153600&qyid=87390BD2-DACE-497B-9CD4-2FD14354B2A4&secure_v=1&secure_p=iPhone&core=1&req_sn=1493946331320&req_times=1"

@interface ZPHomePageViewController () <TYPagerControllerDataSource, TYPagerControllerDelegate, ZPRecommendNewViewControllerDelegate>

/**
 *  顶部导航栏控制器
 */
@property (nonatomic, strong) TYTabButtonPagerController *pagerController;
@property (nonatomic, strong) NSArray *channelList;

/**
 *  小菊花
 */
@property(nonatomic,strong) ActivityIndicatorView *activityWheel;

@end

@implementation ZPHomePageViewController

#pragma mark - Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addPagerController];
    [self requestUrl];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Add Sub Controller
/**
 *  添加导航控制器
 */
- (void)addPagerController
{
    TYTabButtonPagerController *pagerController = [[TYTabButtonPagerController alloc]init];
    pagerController.dataSource = self;
    pagerController.adjustStatusBarHeight = YES;
    //TYTabButtonPagerController set barstyle will reset (TYTabPagerController not reset)cell propertys
    pagerController.barStyle = TYPagerBarStyleProgressView;
    
    
//    pagerController.barStyle = _variable ? (_showNavBar? TYPagerBarStyleProgressBounceView : TYPagerBarStyleProgressElasticView) : TYPagerBarStyleProgressView;
    // after set barstyle,you need set cell propertys that you want
    pagerController.cellWidth = 78;
    pagerController.cellSpacing = 8;
    
//    pagerController
    
    pagerController.view.frame = self.view.bounds;
    [self addChildViewController:pagerController];
    [self.view addSubview:pagerController.view];
    _pagerController = pagerController;
}

#pragma mark - ActivityWheel Method
-(void)showLoadingView
{
    self.tabBarController.view.hidden = YES;
    if(self.activityWheel==nil)
    {
        ActivityIndicatorView *wheel = [[ActivityIndicatorView alloc] initWithFrame: CGRectMake(0, 0, 15, 15)];
        wheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.activityWheel = wheel;
        self.activityWheel.center = self.view.center;
    }
    [self.activityWheel startAnimating];
    [self.view addSubview:self.activityWheel];
}
-(void)removeLoadingView
{
    self.tabBarController.view.hidden = NO;
    [self.activityWheel stopAnimating];
    if (self.activityWheel.superview) {
        [self.activityWheel removeFromSuperview];
    }
    self.activityWheel = nil;
}


#pragma mark - NetWorking Request
/**
 *  请求网络数据
 */
-(void)requestUrl
{
    [self showLoadingView];
    
    //1.创建请求
    NSURL *url = [NSURL URLWithString:kChannelListURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //2.创建连接
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *sesson = [NSURLSession sessionWithConfiguration:configuration];
    
    //3.创建任务
    NSURLSessionDataTask *dataTask = [sesson dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            //网络连接错误
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed];
            });
        } else {
            NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //1.检查是否成功获取数据
            NSNumber* resultCode = tmpDic[@"code"];
            if ([resultCode integerValue] != 100000) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self requestUrl];
                    });
//                    [self requestDataFailed];
                });
                return;
            }
            
            //2.保存数据
            NSArray *data = [tmpDic objectForKey:@"data"];
            NSMutableArray *dataArr = [NSMutableArray array];
            [dataArr addObject:[[ZPChannel alloc]initWithID:@"-1" name:@"推荐" desc:@"推荐"]];
            for (NSDictionary *dict in data) {
                [dataArr addObject:[ZPChannel channelWithDict:dict]];
            }
            self.channelList = dataArr;
            
            //3.更新界面
            dispatch_async(dispatch_get_main_queue(), ^{
                [self removeLoadingView];
                [self.pagerController reloadData];
            });
        }
    }];
    
    //4.执行任务
    [dataTask resume];
}

-(void)requestFailed {
    [self removeLoadingView];
    self.tabBarController.view.hidden = YES;
    UILabel *copyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    [copyLabel setText:@"网络请求失败"];
    [copyLabel setTextColor:[UIColor lightGrayColor]];
    copyLabel.center = self.view.center;
    copyLabel.font = [UIFont systemFontOfSize:14];
    copyLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:copyLabel];
}

-(void)requestDataFailed {
    [self removeLoadingView];
    self.tabBarController.view.hidden = YES;
    UILabel *copyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    [copyLabel setText:@"获取频道列表数据失败"];
    [copyLabel setTextColor:[UIColor lightGrayColor]];
    copyLabel.center = self.view.center;
    copyLabel.font = [UIFont systemFontOfSize:14];
    copyLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:copyLabel];
}

-(void)showMessageData:(NSArray*)data {
}

#pragma mark - TYPagerControllerDataSource

- (NSInteger)numberOfControllersInPagerController
{
    //第一页是推荐数据，第二页才开始是频道数据
    return self.channelList.count;
}



- (NSString *)pagerController:(TYPagerController *)pagerController titleForIndex:(NSInteger)index
{
    ZPChannel *channel = self.channelList[index];
    return channel.name;
}

- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index
{
    UIViewController *VC;
    ZPRecommendNewViewController *recomendVC;
    switch (index) {
        case 0:
//            VC = [[ZPRecommendPageViewController alloc]init];
            recomendVC = [[ZPRecommendNewViewController alloc]init];
            recomendVC.delegate = self;
            VC = recomendVC;
            break;
//        case 1:
//            VC = [[UIViewController alloc]init];
//            break;
//        case 2:
//            VC = [[UIViewController alloc]init];
//            break;
//        case 3:
//            VC = [[UIViewController alloc]init];
//            break;
//        case 4:
//            VC = [[UIViewController alloc]init];
//            break;
        default:
            VC = [[ZPChannelPageController alloc]init];
            ((ZPChannelPageController*)VC).channel = self.channelList[index];
            break;
    }
    
    ZPChannel *channel = self.channelList[index];
    VC.title = channel.name;
    return VC;
}


#pragma mark - ZPRecommendNewViewControllerDelegate

-(void)moreVideoButtonDidClick:(NSString *)channelTitle {
    for (int i = 0; i < self.channelList.count; i++) {
        ZPChannel *channel = self.channelList[i];
        if ([channel.name isEqualToString:channelTitle]) {
            [self.pagerController moveToControllerAtIndex:i animated:YES];
            break;
        }
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
