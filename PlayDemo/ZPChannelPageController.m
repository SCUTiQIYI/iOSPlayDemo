//
//  ChannelPageController.m
//  PlayDemo
//
//  Created by HZP on 2017/6/13.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ZPChannelPageController.h"
#import "ZPChannel.h"
#import "ZPVideoInfo.h"
#import "AFHTTPSessionManager.h"
#import "ZPPlayerViewController.h"
#import "ChannelCollectionViewCell.h"
#import "ChannelCollectionViewCellDataModel.h"
#import "MJRefresh.h"
#import "MBProgressHUD.h"
#import "PlayViewTransitionAnimator.h"

static NSString* const kChannelBaseURL = @"http://iface.qiyi.com/openapi/batch/channel";
static const NSUInteger kChannelPageSize = 30;

@interface ZPChannelPageController () <UIViewControllerTransitioningDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
/**
 *  视频列表
 */
@property (nonatomic, strong) NSMutableArray *videoList;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation ZPChannelPageController

#pragma mark - Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat TVCellwidth = (self.view.frame.size.width - 40)/3;
    layout.itemSize = CGSizeMake(TVCellwidth,TVCellwidth*4/3+20+15);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20,self.view.frame.size.height ) collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[ChannelCollectionViewCell class] forCellWithReuseIdentifier:@"collectionCell"
     ];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self setupRefreshControl];
}

/**
 *  设置下拉刷新和上拉加载更多
 */
-(void)setupRefreshControl {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchData];
    }];
    [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"正在加载" forState:MJRefreshStateRefreshing];
    [header setTitle:@"松开加载" forState:MJRefreshStatePulling];
    [header setTitle:@"加载失败" forState:MJRefreshStateNoMoreData];
    
    self.collectionView.mj_header = header;
    
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self fetchMoreData];
    }];
    [footer setTitle:@"上拉加载更多" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在加载" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"松开加载更多" forState:MJRefreshStatePulling];
    [footer setTitle:@"加载失败" forState:MJRefreshStateNoMoreData];
    self.collectionView.mj_footer = footer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setter
-(void)setChannel:(ZPChannel *)channel {
    _channel = channel;
    [self fetchData];
}

#pragma mark - NetWork Method
/**
 *  获取网络数据
 */
-(void)fetchData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    int pageSize = 0;
    if (self.videoList.count == 0) {
        pageSize = kChannelPageSize;
    } else {
        pageSize = self.videoList.count;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *para = @{ @"type" : @"detail",
                    @"channel_name" : self.channel.name,
                            @"mode" : @"11",
//                     @"is_purchase" : @"2",
                       @"page_size" : [NSString stringWithFormat:@"%d", pageSize],
                         @"version" : @"7.5",
                           @"app_k" : @"f0f6c3ee5709615310c0f053dc9c65f2",
                           @"app_v" : @"8.4",
                           @"app_t" : @"0",
                     @"platform_id" : @"12",
                          @"dev_os" : @"10.3.1",
                          @"dev_ua" : @"iPhone9,3",
                            
                    @"dev_hw" : @"%7B%22cpu%22%3A0%2C%22gpu%22%3A%22%22%2C%22mem%22%3A%2250.4MB%22%7D",
                            
                         @"net_sts" : @"1",
                        @"scrn_sts" : @"1",
                        @"scrn_res" : @"1334*750",
                        @"scrn_dpi" : @"153600",
                            @"qyid" : @"87390BD2-DACE- 497B-9CD4- 2FD14354B2A4",
                        @"secure_v" : @"1",
                        @"secure_p" : @"iPhone",
                            @"core" : @"1",
                          @"req_sn" : @"1493946331320",
                       @"req_times" : @"1"};
    
    [manager GET:kChannelBaseURL parameters:para progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"channel page request success");

        NSDictionary *dataDict = responseObject;
        NSNumber *code = dataDict[@"code"];
        if ([code integerValue] != 100000) {
            //获取数据失败
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fetchDataFailed];
            });
            return;
        }
        
        //获取数据成功
        NSArray *dictArr = dataDict[@"data"][@"video_list"];
        NSMutableArray *modelArr = [NSMutableArray array];
        for (NSDictionary *dict in dictArr) {
            [modelArr addObject:[ZPVideoInfo videoInfoWithDict:dict]];
        }
        self.videoList = modelArr;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //网络请求失败
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestFailed];
        });
    }];
}

/**
 *  获取更多网络数据
 */
-(void)fetchMoreData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    int pageSize = 0;
    
    if (self.videoList.count == 0) {
        pageSize = kChannelPageSize;
    } else {
        pageSize = self.videoList.count;
    }
    int pageIndex = self.videoList.count / kChannelPageSize + 1;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *para = @{ @"type" : @"detail",
                            @"channel_name" : self.channel.name,
                            @"mode" : @"11",
//                            @"is_purchase" : @"2",
                            @"page_size" : [NSString stringWithFormat:@"%d", pageSize],
                            @"page_num" : [NSString stringWithFormat:@"%d", pageIndex],
                            @"version" : @"7.5",
                            @"app_k" : @"f0f6c3ee5709615310c0f053dc9c65f2",
                            @"app_v" : @"8.4",
                            @"app_t" : @"0",
                            @"platform_id" : @"12",
                            @"dev_os" : @"10.3.1",
                            @"dev_ua" : @"iPhone9,3",
                            
                            @"dev_hw" : @"%7B%22cpu%22%3A0%2C%22gpu%22%3A%22%22%2C%22mem%22%3A%2250.4MB%22%7D",
                            
                            @"net_sts" : @"1",
                            @"scrn_sts" : @"1",
                            @"scrn_res" : @"1334*750",
                            @"scrn_dpi" : @"153600",
                            @"qyid" : @"87390BD2-DACE- 497B-9CD4- 2FD14354B2A4",
                            @"secure_v" : @"1",
                            @"secure_p" : @"iPhone",
                            @"core" : @"1",
                            @"req_sn" : @"1493946331320",
                            @"req_times" : @"1"};
    
    [manager GET:kChannelBaseURL parameters:para progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"channel page request success");
        
        NSDictionary *dataDict = responseObject;
        NSNumber *code = dataDict[@"code"];
        if ([code integerValue] != 100000) {
            //获取数据失败
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fetchDataFailed];
            });
            return;
        }
        
        //获取数据成功
        NSArray *dictArr = dataDict[@"data"][@"video_list"];
        for (NSDictionary *dict in dictArr) {
            [self.videoList addObject:[ZPVideoInfo videoInfoWithDict:dict]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //网络请求失败
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestFailed];
        });
    }];
}

-(void)showHudWithMessage:(NSString*)msg duration:(NSTimeInterval)duration{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = msg;
    [hud hideAnimated:YES afterDelay:duration];
}

/**
 *  网络请求失败
 */
-(void)requestFailed {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSString *msg = @"网络请求失败, 请刷新";
    NSLog(@"%@", msg);
    [self showHudWithMessage:msg duration:2.0f];
    [self cancelRefreshing];
}

/**
 *  获取数据失败
 */
-(void)fetchDataFailed {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSString *msg = @"获取数据失败, 请刷新";
    NSLog(@"%@", msg);
    [self showHudWithMessage:msg duration:2.0f];
    [self cancelRefreshing];
}

/**
 *  重新显示数据
 */
-(void)reloadData {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.collectionView reloadData];
    [self cancelRefreshing];
}


/**
 *  停止上拉下拉转着的菊花
 */
-(void)cancelRefreshing {
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZPVideoInfo *info = self.videoList[indexPath.row];
    ChannelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    ChannelCollectionViewCellDataModel *model = [[ChannelCollectionViewCellDataModel alloc] initWithDict:info];
    cell.dataModel = model;
    return cell;
}

#pragma mark -Collection View Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ZPVideoInfo *videoInfo = self.videoList[indexPath.row];
    ZPPlayerViewController *playerVC = [[ZPPlayerViewController alloc]init];
    playerVC.videoInfo = videoInfo;
    playerVC.transitioningDelegate = self;
    [self presentViewController:playerVC animated:YES completion:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZPVideoInfo *videoInfo = self.videoList[indexPath.row];
    ZPPlayerViewController *playerVC = [[ZPPlayerViewController alloc]init];
    playerVC.videoInfo = videoInfo;
    playerVC.transitioningDelegate = self;
    [self presentViewController:playerVC animated:YES completion:nil];
}


#pragma mark - UIViewControllerAnimatedTransitioning
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    PlayViewTransitionAnimator *animator = [[PlayViewTransitionAnimator alloc] init];
    return animator;
}


//| ----------------------------------------------------------------------------
//  The system calls this method on the presented view controller's
//  transitioningDelegate to retrieve the animator object used for animating
//  the dismissal of the presented view controller.  Your implementation is
//  expected to return an object that conforms to the
//  UIViewControllerAnimatedTransitioning protocol, or nil if the default
//  dismissal animation should be used.
//
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    PlayViewTransitionAnimator *animator = [[PlayViewTransitionAnimator alloc] init];
    
    return animator;
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
