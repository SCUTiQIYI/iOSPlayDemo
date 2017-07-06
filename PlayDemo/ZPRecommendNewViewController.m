//
//  ZPRecommendNewViewController.m
//  PlayDemo
//
//  Created by HZP on 2017/6/16.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ZPRecommendNewViewController.h"
#import "ZPChannelInfo.h"
#import "AFNetworking.h"
#import "ZPVideoInfo.h"
#import "ZPPlayerViewController.h"
#import "ZYBannerView.h"
#import "ZPSearchResultPageViewController.h"
#import "UIImageView+AFNetworking.h"
#import "RecommentCollectionViewCellDataModel.h"
#import "RecommentCollectionViewCell.h"
#import "CollectionReusableHeadView.h"
#import "CollectionReusableBannerHeaderView.h"
#import "CollectionReusableFooterView.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"
#import "PYSearchViewController.h"
#import "PlayViewTransitionAnimator.h"
#import "PlayDemo-Swift.h"
#import "AppDelegate.h"
//#import "PlayDemo-Bridging-Header.h"
//#import "History/HistoryManager.swift"
//#import "History/HistoryTableViewController.swift"

static const CGFloat kSearchBarHeight = 40.0f;
static const CGFloat kTopButtonWidth = 40.0f;
//static const CGFloat kCycleViewHeight = 180.0f;
static const CGFloat kViewMargin = 10.0f;
static const NSTimeInterval kRefetchDataInterval = 3.0f;

/**
 *  频道基本URL
 */
static NSString* const kChannelBaseURL = @"http://iface.qiyi.com/openapi/batch/channel";

/**
 *  首页URL
 */
static NSString* const kRecommendURL = @"http://iface.qiyi.com/openapi/batch/recommend?app_k=f0f6c3ee5709615310c0f053dc9c65f2&app_v=8.4&app_t=0&platform_id=12&dev_os=10.3.1&dev_ua=iPhone9,3&dev_hw=%7B%22cpu%22%3A0%2C%22gpu%22%3A%22%22%2C%22mem%22%3A%2250.4MB%22%7D&net_sts=1&scrn_sts=1&scrn_res=1334*750&scrn_dpi=153600&qyid=87390BD2-DACE-497B-9CD4-2FD14354B2A4&secure_v=1&secure_p=iPhone&core=1&req_sn=1493946331320&req_times=1";

/**
 *  排行榜接口，以此数据作为热搜关键词
 */
static NSString* const kPopChartURL = @"http://iface.qiyi.com/openapi/realtime/recommend?app_k=f0f6c3ee5709615310c0f053dc9c65f2&app_v=8.4&app_t=0&platform_id=12&dev_os=10.3.1&dev_ua=iPhone9,3&dev_hw=%7B%22cpu%22%3A0%2C%22gpu%22%3A%22%22%2C%22mem%22%3A%2250.4MB%22%7D&net_sts=1&scrn_sts=1&scrn_res=1334*750&scrn_dpi=153600&qyid=87390BD2-DACE-497B-9CD4-2FD14354B2A4&secure_v=1&secure_p=iPhone&core=1&req_sn=1493946331320&req_times=1";



@interface ZPRecommendNewViewController () <ZYBannerViewDataSource, ZYBannerViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CollectionReusableFooterViewDelegate, UISearchBarDelegate, PYSearchViewControllerDelegate,UIViewControllerTransitioningDelegate> {
    CGFloat ImforMationCellwidth;
    CGFloat TVCellwidth;
    
}

/**
 *  频道列表
 */
@property (nonatomic, strong) NSArray *channelsInfos;
/**
 *  用于换一批的视频模型数据
 */
@property (nonatomic, strong) NSArray *moiveVideos;
@property (nonatomic, assign) NSUInteger moiveIndex;
@property (nonatomic ,strong) NSArray *televisionVideos;
@property (nonatomic, assign) NSUInteger televisionIndex;
@property (nonatomic, strong) NSArray *newsVideos;
@property (nonatomic, assign) NSUInteger newsIndex;
@property (nonatomic, strong) NSArray *vatietyShowVideos;
@property (nonatomic, assign) NSUInteger vatietyIndex;

/**
 *  上方的搜索框
 */
@property (nonatomic, weak) UISearchBar *searchBar;
/**
 *  上方的轮播图
 */
@property (nonatomic, strong) NSArray *hotSearchs;

@property (nonatomic, weak) ZYBannerView *cycleScrollView;

@property (nonatomic, strong) UICollectionView *collectionView;


/**
 记录动画时初始位置
 */
@property (nonatomic, assign)CGRect destinationFrame;

@end

@implementation ZPRecommendNewViewController

#pragma mark - Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setWidth];
    [self setupModelIndex];
    [self requestUrl];
    [self setupSubView];
    [self fetchHotSearchsData];
    // Do any additional setup after loading the view.
}

- (void)setWidth {
    ImforMationCellwidth = (self.view.frame.size.width - 30)/2;
    TVCellwidth = (self.view.frame.size.width - 40)/3;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  初始化模型下标
 */
-(void)setupModelIndex {
    _newsIndex = 0;
    _moiveIndex = 0;
    _vatietyIndex = 0;
    _televisionIndex = 0;
}

/**
 *  创建子控件
 */
-(void)setupSubView {
    [self setupHistoryButton];
    [self setupSearchBar];
    [self setupCollectionView];
    [self setupRefreshControl];
}

/**
 *  设置下拉刷新
 */
-(void)setupRefreshControl {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestUrl];
    }];
    [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"正在加载" forState:MJRefreshStateRefreshing];
    [header setTitle:@"松开加载" forState:MJRefreshStatePulling];
    [header setTitle:@"加载失败" forState:MJRefreshStateNoMoreData];
    self.collectionView.mj_header = header;
}


/**
 *  创建历史按钮
 */
-(void)setupHistoryButton {
    UIButton *historyButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [historyButton setTitle:@"历史" forState:UIControlStateNormal];
    [historyButton setBackgroundColor:[UIColor colorWithRed:201.0f/255 green:201.0f/255 blue:206.0f/255 alpha:1.0f]];
    [historyButton setImage:[UIImage imageNamed:@"history"] forState:UIControlStateNormal];
    
    [historyButton addTarget:self action:@selector(historyBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = kTopButtonWidth;
    CGFloat btnH = kSearchBarHeight;
    historyButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
    [self.view addSubview:historyButton];
}

/**
 *  创建搜索框
 */
-(void)setupSearchBar {
    UISearchBar *searchBar = [[UISearchBar alloc]init];
    CGFloat searchBarH = kSearchBarHeight;
    CGFloat searchBarW = self.view.bounds.size.width - kTopButtonWidth;
    CGFloat searchBarX = kTopButtonWidth;
    CGFloat searchBarY = 0;
    searchBar.frame = CGRectMake(searchBarX, searchBarY, searchBarW, searchBarH);
    searchBar.placeholder = @"搜索";
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    self.searchBar = searchBar;
}

/**
 *  创建轮播图
 */
-(void)setupCycleView {
//    ZYBannerView *banner = [[ZYBannerView alloc]init];
//    banner.dataSource = self;
//    banner.delegate = self;
//    //是否需要循环滚动
//    banner.shouldLoop = YES;
//    //是否需要自动滚动
//    banner.autoScroll = YES;
//    banner.scrollInterval = 5.0f;
//    
//    // 设置frame
//    CGFloat bannerX = 0;
//    CGFloat bannerY = CGRectGetMaxY(self.searchBar.frame);
//    CGFloat bannerW = self.view.bounds.size.width;
//    CGFloat bannerH = kCycleViewHeight;
//    banner.frame = CGRectMake(bannerX, bannerY, bannerW, bannerH);
//    
//    [self.view addSubview:banner];
//    self.cycleScrollView = banner;
}

/**
 *  创建collection view
 */
-(void)setupCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    //  flowLayout.itemSize = CGSizeMake(120, 160);
    flowLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 20);
    flowLayout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, 40);
    
    CGFloat colleViewX = kViewMargin;
    CGFloat colleViewY = CGRectGetMaxY(self.searchBar.frame)+kViewMargin;
    CGFloat colleViewW = self.view.frame.size.width - 2 * kViewMargin;
    CGFloat colleViewH = self.view.frame.size.height - colleViewY - 64;
    
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(colleViewX, colleViewY, colleViewW, colleViewH) collectionViewLayout:flowLayout];
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[RecommentCollectionViewCell class] forCellWithReuseIdentifier:@"RecommentCollectionViewCell"];
    [_collectionView registerClass:[CollectionReusableHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeadView"];
    [_collectionView registerClass:[CollectionReusableBannerHeaderView class] forSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier:@"BannerHeaderView"];
    [_collectionView registerClass:[CollectionReusableFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FootView"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
}

#pragma network request

/**
 *  请求热搜词数据
 *  用于缓存搜索的热搜词
 */
-(void)fetchHotSearchsData {
    //1.创建请求
    NSURL *url = [NSURL URLWithString:kPopChartURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //2.创建连接
   // NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *sesson = [NSURLSession sharedSession];
    
    //3.创建任务
    NSURLSessionDataTask *dataTask = [sesson dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (self.hotSearchs != nil) return;
        if (error) {
            //获取数据失败，则5秒后再获取
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRefetchDataInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.hotSearchs == nil) {
                    [self fetchHotSearchsData];
                }
            });
        } else {
            if (data == nil) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRefetchDataInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.hotSearchs == nil) {
                        [self fetchHotSearchsData];
                    }
                });
                return;
            }
            NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSNumber* resultCode = [tmpDic valueForKey:@"code"];
            if (resultCode.integerValue != 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRefetchDataInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.hotSearchs == nil) {
                        [self fetchHotSearchsData];
                    }
                });
                return;
            }
            
            NSMutableArray *hotSearch = [NSMutableArray array];
            NSArray *data = [tmpDic objectForKey:@"data"];
            for (NSDictionary *channelDict in data) {
                 ZPChannelInfo *channel = [ZPChannelInfo channelInfoWithDict:channelDict];
                if (![channel.title isEqualToString:@"电影"] &&
                    ![channel.title isEqualToString:@"电视剧"]) {
                    continue;
                }
                NSArray *videos = channel.video_list;
                for (ZPVideoInfo *video in videos) {
                    [hotSearch addObject:video.title];
                }
            }
            
            self.hotSearchs = hotSearch;
  
            
        }
    }];
    
    //4.执行任务
    [dataTask resume];
}

/**
 *  获取频道数据
 */
-(void)fetchChannelDataWithChannelName:(NSString*)channelName {
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    int pageSize = 30;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    AFHTTPSessionManager *manager = [app sharedHTTPSession];
    NSDictionary *para = @{ @"type" : @"detail",
                            @"channel_name" : channelName,
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRefetchDataInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self fetchChannelDataWithChannelName:channelName];
            });
            return;
        }
        
        //获取数据成功
        //保存数据
        NSArray *dictArr = dataDict[@"data"][@"video_list"];
        NSMutableArray *modelArr = [NSMutableArray array];
        for (NSDictionary *dict in dictArr) {
            [modelArr addObject:[ZPVideoInfo videoInfoWithDict:dict]];
        }
        
        //根据分类将数据放到相应的位置
        NSString *channelName = dataDict[@"data"][@"channelName"];
        if ([channelName isEqualToString:@"电影"]) {
            self.moiveVideos = modelArr;
        } else if ([channelName isEqualToString:@"电视剧"]) {
            self.televisionVideos = modelArr;
        } else if ([channelName isEqualToString:@"综艺"]) {
            self.vatietyShowVideos = modelArr;
        } else if ([channelName isEqualToString:@"资讯"]) {
            self.newsVideos = modelArr;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //网络请求失败
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRefetchDataInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self fetchChannelDataWithChannelName:channelName];
        });
    }];
}



/**
 *  请求首页推荐数据数据
 */
-(void)requestUrl
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //1.创建请求
    NSURL *url = [NSURL URLWithString:kRecommendURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //2.创建连接
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *sesson = [NSURLSession sessionWithConfiguration:configuration];
    
    //3.创建任务
    NSURLSessionDataTask *dataTask = [sesson dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed];
            });
        } else {
            
            NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *data = [tmpDic objectForKey:@"data"];
            
            NSMutableArray *dataArr = [NSMutableArray array];
            for (NSDictionary *dict in data) {
                ZPChannelInfo *channel = [ZPChannelInfo channelInfoWithDict:dict];
                if (![channel.title isEqualToString:@"轮播图"]) {
                    [self fetchChannelDataWithChannelName:channel.title];
                }
                [dataArr addObject:channel];
            }
            //将咨询行在展示行的最后
            if (dataArr.count >= 2) {
                ZPChannelInfo *channel = dataArr[1];
                [dataArr removeObjectAtIndex:1];
                [dataArr addObject:channel];
            }
            self.channelsInfos = dataArr;
            
            NSNumber* resultCode = [tmpDic valueForKey:@"code"];
            if (resultCode.integerValue == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self showDataMessage:data];
                    [self reloadData];
                });
            }
            [sesson invalidateAndCancel];
        }
      
    }];
    
    //4.执行任务
    [dataTask resume];
}

/**
 *  网络请求失败
 */
- (void)requestFailed {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"网络请求失败");
}

/**
 *  刷新数据
 */
- (void)reloadData {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.collectionView.mj_header endRefreshing];
    [self.cycleScrollView reloadData];
    [self.collectionView reloadData];
}

#pragma mark - User Interaction

-(void) historyBtnDidClick {
    
    
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchVC];
//    nav.transitioningDelegate = self;
//    [self presentViewController:nav  animated:YES completion:nil];
    
    
    HistoryTableViewController *history = [[HistoryTableViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:history];
    nav.transitioningDelegate = self;
    [self presentViewController:nav  animated:YES completion:nil];
}


#pragma mark - ZYBannerViewDataSource
/**
 *  返回Banner需要显示Item(View)的个数
 */
- (NSInteger)numberOfItemsInBanner:(ZYBannerView *)banner
{
    ZPChannelInfo *channelCycle = [self.channelsInfos firstObject];
    if ([channelCycle.title isEqualToString:@"轮播图"]) {
        return channelCycle.video_list.count;
    }
    return 0;
}

// 返回Banner在不同的index所要显示的View
- (UIView *)banner:(ZYBannerView *)banner viewForItemAtIndex:(NSInteger)index
{
    ZPChannelInfo *cycleChannel = [self.channelsInfos firstObject];
    ZPVideoInfo *video = cycleChannel.video_list[index];
    
    UIImageView *imageView = [[UIImageView alloc]init];
    [imageView setImageWithURL:[NSURL URLWithString:video.img]placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    
    return imageView;
}

-(void)banner:(ZYBannerView *)banner didSelectItemAtIndex:(NSInteger)index {
    ZPChannelInfo *cycleChannel = [self.channelsInfos firstObject];
    ZPVideoInfo *video = cycleChannel.video_list[index];
    ZPPlayerViewController *playVC = [[ZPPlayerViewController alloc]init];
    playVC.videoInfo = video;
    playVC.transitioningDelegate = self;
    [self presentViewController:playVC animated:YES completion:nil];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _channelsInfos.count-1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RecommentCollectionViewCell" forIndexPath:indexPath];
    ZPChannelInfo *channelInfo = _channelsInfos[indexPath.section+1];
    ZPVideoInfo *videoInfo = channelInfo.video_list[indexPath.row];
    RecommentCollectionViewCellDataModel *model = [[RecommentCollectionViewCellDataModel alloc] initWithDict:videoInfo];
    if (indexPath.section > 1) {
        model.isShowDetailLable = YES;
    }
    cell.dataModel = model;
    return cell;
    
}

#pragma mark - UICollectionView Delegate
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 2:
            return CGSizeMake(TVCellwidth,TVCellwidth*4/3+20+15);
            break;
        case 3:
            return CGSizeMake(ImforMationCellwidth, ImforMationCellwidth*7/10+20+15);
            break;
        default:
            return CGSizeMake(TVCellwidth,TVCellwidth*4/3+20);
            break;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return CGSizeMake(self.view.frame.size.width, 185);
            break;
        default:
            return CGSizeMake(self.view.frame.size.width, 20);
            break;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header;
        
        ZPChannelInfo *info = _channelsInfos[indexPath.section + 1];
        switch (indexPath.section) {
            case 0:
                
                header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"BannerHeaderView" forIndexPath:indexPath];
                _cycleScrollView = ((CollectionReusableBannerHeaderView*)header).bannerView;
                ((CollectionReusableBannerHeaderView*)header).bannerView.delegate = self;
                ((CollectionReusableBannerHeaderView*)header).bannerView.dataSource = self;
                ((CollectionReusableBannerHeaderView*)header).lable.text = info.title;
                break;
                
            default:
                header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeadView" forIndexPath:indexPath];
                ((CollectionReusableHeadView*)header).lable.text = info.title;
                break;
        }
        return header;
        
    }
    if([kind isEqualToString:UICollectionElementKindSectionFooter]){
        CollectionReusableFooterView *foot= [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"FootView" forIndexPath:indexPath];
        foot.delegate = self;
        
        ZPChannelInfo *channel = self.channelsInfos[indexPath.section + 1];
        NSString *footerBtnTitle = [NSString stringWithFormat:@"  更多%@", channel.title];
        [foot.moreVideoBtn setTitle:footerBtnTitle forState:UIControlStateNormal];

        foot.moreVideoBtn.tag = indexPath.section;
        foot.changeVideoBtn.tag = indexPath.section;
        return foot;
        
    }
    return nil;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ZPChannelInfo *cycleChannel = self.channelsInfos[indexPath.section + 1];
    ZPVideoInfo *video = cycleChannel.video_list[indexPath.row];
    ZPPlayerViewController *playVC = [[ZPPlayerViewController alloc]init];
    playVC.videoInfo = video;
    playVC.transitioningDelegate = self;
    
    UITableViewCell *cell = (UITableViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    _destinationFrame = [cell convertRect:cell.bounds toView:window];
    [self presentViewController:playVC animated:YES completion:nil];
}

#pragma mark - CollectionReusableFooterViewDelegate

-(void)CollectionReusableFooterViewMoreVideoBtnClick:(UIButton *)btn {
    ZPChannelInfo *channel = self.channelsInfos[btn.tag + 1];
    if ([self.delegate respondsToSelector:@selector(moreVideoButtonDidClick:)]) {
        [self.delegate performSelector:@selector(moreVideoButtonDidClick:) withObject:channel.title];
    }
}

-(void)CollectionReusableFooterViewChangeVideoBtnClick:(UIButton *)btn {
    ZPChannelInfo *channel = self.channelsInfos[btn.tag + 1];
//    NSLog(@"%d", btn.tag);
    NSString *channelName = channel.title;
    if ([channelName isEqualToString:@"电影"]) {
        if (self.moiveVideos.count == 0) return;
        NSMutableArray *newArr = [NSMutableArray array];
        for (int i = 0; i < 6; i++) {
            [newArr addObject:self.moiveVideos[self.moiveIndex + i]];
        }
        self.moiveIndex += 6;
        self.moiveIndex %= 30;
        ZPChannelInfo *channel = self.channelsInfos[btn.tag + 1];
        channel.video_list = newArr;
    } else if ([channelName isEqualToString:@"电视剧"]) {
        if (self.televisionVideos.count == 0) return;
        NSMutableArray *newArr = [NSMutableArray array];
        for (int i = 0; i < 6; i++) {
            [newArr addObject:self.televisionVideos[self.televisionIndex + i]];
        }
        self.televisionIndex += 6;
        self.televisionIndex %= 30;
        ZPChannelInfo *channel = self.channelsInfos[btn.tag + 1];
        channel.video_list = newArr;
    } else if ([channelName isEqualToString:@"综艺"]) {
        if (self.vatietyShowVideos.count == 0) return;
        NSMutableArray *newArr = [NSMutableArray array];
        for (int i = 0; i < 6; i++) {
            [newArr addObject:self.vatietyShowVideos[self.vatietyIndex + i]];
        }
        self.vatietyIndex += 6;
        self.vatietyIndex %= 30;
        ZPChannelInfo *channel = self.channelsInfos[btn.tag + 1];
        channel.video_list = newArr;
    } else if ([channelName isEqualToString:@"资讯"]) {
        if (self.newsVideos.count == 0) return;
        NSMutableArray *newArr = [NSMutableArray array];
        for (int i = 0; i < 6; i++) {
            [newArr addObject:self.newsVideos[self.newsIndex + i]];
        }
        self.newsIndex += 6;
        self.newsIndex %= 30;
        ZPChannelInfo *channel = self.channelsInfos[btn.tag + 1];
        channel.video_list = newArr;
    }
    [self.collectionView reloadData];
}

#pragma mark - UISearchBarDelegate

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    ZPSearchResultPageViewController *vc = [[ZPSearchResultPageViewController alloc]init];
//    [self presentViewController:vc animated:YES completion:nil];
    
    //1. 创建搜索控制器
    PYSearchViewController *searchVC = [PYSearchViewController searchViewControllerWithHotSearches:self.hotSearchs searchBarPlaceholder:@"请输入搜索内容" didSearchBlock:^(PYSearchViewController *searchViewController, UISearchBar *searchBar, NSString *searchText) {
        //2.设置搜索行为block
        ZPSearchResultPageViewController *searchResultVC = [[ZPSearchResultPageViewController alloc]init];
        searchResultVC.searchKey = searchText;
        searchResultVC.title = searchText;
        [searchViewController.navigationController pushViewController:searchResultVC animated:YES];
        
    }];
    
    //3.设置搜索样式
    searchVC.hotSearchStyle = PYHotSearchStyleARCBorderTag;
    searchVC.searchHistoryTags = PYSearchHistoryStyleDefault;
    
    //4.设置代理
    searchVC.delegate = self;

    //5.弹出搜索控制器
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    nav.transitioningDelegate = self;
    [self presentViewController:nav  animated:YES completion:nil];
//    [self presentViewController:searchVC animated:YES completion:nil];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
//| ----------------------------------------------------------------------------
//  The system calls this method on the presented view controller's
//  transitioningDelegate to retrieve the animator object used for animating
//  the presentation of the incoming view controller.  Your implementation is
//  expected to return an object that conforms to the
//  UIViewControllerAnimatedTransitioning protocol, or nil if the default
//  presentation animation should be used.
//

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

@end

