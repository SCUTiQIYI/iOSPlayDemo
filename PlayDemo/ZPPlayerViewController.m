//
//  MyPlayerViewController.m
//  PlayDemo
//
//  Created by HZP on 2017/5/25.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "QYPlayerController.h"
#import "ZPPlayerViewController.h"
#import "ZPVideoInfo.h"
#import "ZPVideoProgressBar.h"
#import "DCPathButton.h"
#import "ZPTools.h"
#import "MBProgressHUD.h"
#import "ZPVideoInfoView.h"
#import "AFNetworking.h"
#import "ZPChannelPageViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PlayViewTransitionAnimator.h"
#import "PlayDemo-Swift.h"
#import "AppDelegate.h"
#define KIPhone_AVPlayerRect_mwidth 320
#define KIPhone_AVPlayerRect_mheight 180

/**
 *  请求推荐数据失败重新请求的时间
 */
static const NSTimeInterval kReFetchDataTime = 3.0f;
/**
 *  搜索接口
 *  使用搜索作为推荐
 */
static NSString* const kSearchBaseURL = @"http://iface.qiyi.com/openapi/batch/search";
/**
 *  推荐的条目数量
 */
static const NSUInteger kRelatedRecomendPageSize = 10;

/**不点击画面，隐藏进度条时长*/
static const NSTimeInterval kZPHideSubviewDuration = 5.0f;
/**隐藏进度条动画时长*/
static const NSTimeInterval kZPHideSubviewAnimationDuration = 1.0f;
/**动画时长*/
static const NSTimeInterval kZPScreenTransformAnimationDuration = 0.2f;
/**
 *  按钮大小比例
 *  设置为1/6表示按钮大小为平面宽度的六分之一
 */
static const CGFloat kZPButtonSizeScale = 1.0f / 7;
/**
 *  子控件之间的间隔
 */
static const CGFloat kZPPlayerViewSubViewMargin = 5.0f;
/**进度条高度*/
//static const CGFloat kProgressBarHeight = 5.0f;
/**
 *  状态弹出框的现实时长
 */
static const NSTimeInterval kHUDAppearanceDuration = 1.0f;
/**
 *  展开状态下历史记录的最大条数
 */
static const NSUInteger kMaxHistoryItemsCount = 10;
/**
 *  收起状态下历史记录的最大条数
 */
static const NSUInteger kMinHistoryItemsCount = 2;
@interface ZPPlayerViewController () <QYPlayerControllerDelegate, ZPVideoProgressBarDelegate, DCPathButtonDelegate, UIViewControllerTransitioningDelegate, UITableViewDataSource, UITableViewDelegate,UIViewControllerTransitioningDelegate>
/**
 *  播放器
 */
@property (nonatomic, weak) QYPlayerController *playController;
/**
 *  全屏按钮
 */
@property (nonatomic, weak) UIButton *fullScreenBtn;
/**
 *  还原按钮
 */
@property (nonatomic, weak) UIButton *originalScreenBtn;
/**
 *  播放按钮
 */
@property (nonatomic, weak) UIButton *playBtn;
/**
 *  暂停按钮
 */
@property (nonatomic, weak) UIButton *pauseBtn;
/**
 *  关闭按钮
 */
@property (nonatomic, weak) UIButton *closeBtn;
/**
 *  进度条
 */
@property (nonatomic, weak) ZPVideoProgressBar *progressBar;
/**
 *  悬浮按钮
 */
@property (nonatomic, weak) DCPathButton *suspendBtn;
/**
 *  截图控件
 */
@property (nonatomic, weak) UIView *screenShotView;
/**
 *  显示截图
 */
@property (nonatomic, weak) UIImageView *screenShotImageView;
/**
 *  搜索结果截图
 */
@property (nonatomic, weak) ZPVideoInfoView *videoInfoView;
/**
 *  推荐结果tableView
 */
@property (nonatomic, weak) UITableView *tableView;
/**
 *  历史记录的更多按钮
 */
@property (nonatomic, strong) UIButton *tableViewSectionFootViewBtn;
/**
 *  推荐结果模型
 */
@property (nonatomic, strong) NSMutableArray *recommendVideos;
/**
 *  播放到哪个时间
 */
@property (nonatomic, assign) CGFloat curplaytime;
/*
//保存截图按钮
@property (nonatomic, weak) UIButton *saveImageButton;
//分享截图按钮
@property (nonatomic, weak) UIButton *shareImageButton;
 */
/**
 *  是否正在播放
 */
@property (nonatomic, assign, getter = isPlaying) BOOL playing;
/**
 *  是否全屏播放
 */
@property (nonatomic, assign, getter = isFullScreen) BOOL fullScreen;
/**
 *  是否静音播放
 */
@property (nonatomic, assign, getter = isMute) BOOL mute;
/**
 *  用于计时隐藏进度条
 */
@property (nonatomic, strong) NSTimer *timer;


@end

@implementation ZPPlayerViewController

#pragma mark - Controller life cycle method
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createSubView];
    [self initPlayerState];
    [self addSingleTabGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self singleTabAtPlayerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    QYPlayerController *playController = [QYPlayerController sharedInstance];
    if ([playController isPlaying]) {
        [playController stopPlayer];
    }
    [self removeSubView];
    self.playController.view.transform = CGAffineTransformIdentity;
    NSLog(@"player controller dealloc");
}

#pragma mark - Set Player State
-(void)initPlayerState {
    self.playing = YES;
    self.mute = NO;
    self.fullScreen = NO;
}

#pragma mark - Setter
/**
 *  设置视频模型
 */
-(void)setVideoInfo:(ZPVideoInfo *)videoInfo {
    _videoInfo = videoInfo;
    [self fetchDataWithKey:videoInfo.title];
}

/**
 *  设置播放状态
 */
-(void)setPlaying:(BOOL)playing {
    _playing = playing;
    if (playing) {
        if (!self.playController.isPlaying) {
            [self.playController play];
        }
        NSLog(@"play");
    } else {
        if (self.playController.isPlaying) {
            [self.playController pause];
        }
        NSLog(@"pause");
    }
    self.playBtn.hidden = playing;
    self.pauseBtn.hidden = !playing;
}

/**
 *  设置全屏状态
 */
//-(void)setFullScreen:(BOOL)isfullScreen {
//    _fullScreen = isfullScreen;
//    
//    //1. 设置两个按钮状态
//    self.fullScreenBtn.hidden = isfullScreen;
//    self.originalScreenBtn.hidden = !isfullScreen;
//    
//    //2.设置屏幕显示比例
//    /**原始比例*/
//    CGAffineTransform transform = CGAffineTransformIdentity;
//    //全屏
//    if (isfullScreen) {
//        //1.旋转
//        transform = CGAffineTransformRotate(transform, M_PI_2);
//        //2.平移
//        CGPoint playerCenter = self.playController.view.center;
//        CGPoint screenCenter = [[[UIApplication sharedApplication] keyWindow] center];
//        CGFloat tx = screenCenter.y - playerCenter.y;
//        CGFloat ty = screenCenter.x - playerCenter.x;
//        transform = CGAffineTransformTranslate(transform, tx, ty);
//        //3.放大
//        CGSize playerSize = self.playController.view.bounds.size;
//        CGSize screenSize = [[[UIApplication sharedApplication] keyWindow] bounds].size;
//        CGFloat scale = MIN(screenSize.width / playerSize.height, screenSize.height / playerSize.width);
//        transform = CGAffineTransformScale(transform, scale, scale);
//    }
//    [UIView animateWithDuration:kZPAnimationDuration animations:^{
//        self.playController.view.transform = transform;
//    }];
//}
-(void)setFullScreen:(BOOL)isfullScreen {
    _fullScreen = isfullScreen;
    
    //1. 设置两个按钮状态
    self.fullScreenBtn.hidden = isfullScreen;
    self.originalScreenBtn.hidden = !isfullScreen;

    //设置隐藏状态栏
    [self setNeedsStatusBarAppearanceUpdate];
    
    //2.设置屏幕显示比例
    /**原始比例*/
    CGAffineTransform transform = CGAffineTransformIdentity;
    //全屏
    if (isfullScreen) {
        //1.旋转
        transform = CGAffineTransformRotate(transform, M_PI_2);
        //2.平移
        CGPoint playerCenter = self.playController.view.center;
        CGPoint screenCenter = [[[UIApplication sharedApplication] keyWindow] center];
        CGFloat tx = screenCenter.y - playerCenter.y;
        CGFloat ty = screenCenter.x - playerCenter.x;
        transform = CGAffineTransformTranslate(transform, tx, ty);
        //3.放大
        CGSize playerSize = self.playController.view.bounds.size;
        CGSize screenSize = [[[UIApplication sharedApplication] keyWindow] bounds].size;
        CGFloat scale = MIN(screenSize.width / playerSize.height, screenSize.height / playerSize.width);
        transform = CGAffineTransformScale(transform, scale, scale);
    }
    [UIView animateWithDuration:kZPScreenTransformAnimationDuration animations:^{
        self.playController.view.transform = transform;
    }];
}

-(BOOL)prefersStatusBarHidden {
    if (self.isFullScreen) return YES;
    else return NO;
}

//static float volumn = 0;
-(void)setMute:(BOOL)mute {
    _mute = mute;
    [self.playController setMute:mute];
}

#pragma mark - Create subView
/**
 *  添加点击手势
 */
-(void)addSingleTabGesture {
    UITapGestureRecognizer *singleTabGestureRecognizer = [[UITapGestureRecognizer alloc]init];
    singleTabGestureRecognizer.numberOfTapsRequired = 1;
    [singleTabGestureRecognizer addTarget:self action:@selector(singleTabAtPlayerView)];
    [self.playController.view addGestureRecognizer:singleTabGestureRecognizer];
}

/**
 *  添加子控件
 */
-(void)createSubView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createBasePlayerController];
    [self createFullScreenBtn];
    [self creatOriginalScreenBtn];
    [self createPlayBtn];
    [self createCloseButton];
    [self createPauseBtn];
    [self createSuspendButton];
    [self createScreenShootView];
    
    [self setupTableView];
    [self setupTableViewSectionFooterButton];
    
//    [self createVideoInfoView];
}

-(void)reCreateSubView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createBasePlayerController];
    [self createFullScreenBtn];
    [self creatOriginalScreenBtn];
    [self createPlayBtn];
    [self createCloseButton];
    [self createPauseBtn];
    [self createSuspendButton];
    [self createScreenShootView];
    
    //    [self createVideoInfoView];
}
/**
 *  添加播放器
 */
- (void)createBasePlayerController {
    CGRect playFrame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.width/KIPhone_AVPlayerRect_mwidth*KIPhone_AVPlayerRect_mheight);
    QYPlayerController *playController = [QYPlayerController sharedInstance];
    playController.delegate = self;
    [playController setPlayerFrame:playFrame];
    
    ZPVideoInfo *videoInfo = self.videoInfo;
    [playController openPlayerByAlbumId:videoInfo.aID tvId:videoInfo.tvID isVip:videoInfo.isVip];
    
    [[HistoryManager sharedInstance] addHistoryWithHistory:videoInfo];
    
//    NSString *tvid = videoInfo.tvID;
//    NSInteger integ = [tvid integerValue];
//    integ++;
//    tvid = [NSString stringWithFormat:@"%d", integ];
//    [playController openPlayerByAlbumId:videoInfo.aID tvId:tvid isVip:videoInfo.isVip];
    
    [self.view addSubview:playController.view];
    self.playController = playController;
}

/**
 *  添加全屏按钮
 */
-(void)createFullScreenBtn {
    UIButton *fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGSize playerSize = self.playController.view.bounds.size;
    CGFloat fullScreenBtnW = playerSize.height * kZPButtonSizeScale;
    CGFloat fullScreenBtnH = fullScreenBtnW;
    CGFloat fullScreenBtnX = playerSize.width - fullScreenBtnW;
    CGFloat fullScreenBtnY = playerSize.height - fullScreenBtnH;
    fullScreenBtn.frame = CGRectMake(fullScreenBtnX, fullScreenBtnY, fullScreenBtnW, fullScreenBtnH);
    [fullScreenBtn addTarget:self action:@selector(showFullScreen) forControlEvents:UIControlEventTouchUpInside];
    [fullScreenBtn setImage:[UIImage imageNamed:@"enlarge"] forState:UIControlStateNormal];
    [fullScreenBtn setImage:[UIImage imageNamed:@"enlarge-highlightened"] forState:UIControlStateHighlighted];
//    [fullScreenBtn setTitle:@"全屏" forState:UIControlStateNormal];
//    [fullScreenBtn setBackgroundColor:[UIColor greenColor]];
    [self.playController.view addSubview:fullScreenBtn];
    self.fullScreenBtn = fullScreenBtn;
}
/**
 *  添加取消全屏按钮
 */
-(void)creatOriginalScreenBtn {
    UIButton *originalScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGSize playerSize = self.playController.view.bounds.size;
    CGFloat btnW = playerSize.height * kZPButtonSizeScale;
    CGFloat btnH = btnW;
    CGFloat btnX = playerSize.width - btnW;
    CGFloat btnY = playerSize.height - btnH;
    originalScreenBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    [originalScreenBtn addTarget:self action:@selector(cancelFullScreen) forControlEvents:UIControlEventTouchUpInside];
    [originalScreenBtn setImage:[UIImage imageNamed:@"reduce"] forState:UIControlStateNormal];
    [originalScreenBtn setImage:[UIImage imageNamed:@"reduce-highlightened"] forState:UIControlStateHighlighted];
//    [originalScreenBtn setTitle:@"恢复" forState:UIControlStateNormal];
//    [originalScreenBtn setBackgroundColor:[UIColor redColor]];
    originalScreenBtn.hidden = YES;
    [self.playController.view addSubview:originalScreenBtn];
    self.originalScreenBtn = originalScreenBtn;
}
/**
 *  添加播放按钮
 */
-(void)createPlayBtn {
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGSize playerSize = self.playController.view.bounds.size;
    CGFloat btnW = playerSize.height * kZPButtonSizeScale;
    CGFloat btnH = btnW;
    CGFloat btnX = 0;
    CGFloat btnY = playerSize.height - btnH;
    playBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    [playBtn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [playBtn setImage:[UIImage imageNamed:@"play-highlightened"] forState:UIControlStateHighlighted];
//    [playBtn setTitle:@"播放" forState:UIControlStateNormal];
//    [playBtn setBackgroundColor:[UIColor greenColor]];
    [self.playController.view addSubview:playBtn];
    self.playBtn = playBtn;
}
/**
 *  添加暂停按钮
 */
-(void)createPauseBtn {
    UIButton *pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGSize playerSize = self.playController.view.bounds.size;
    CGFloat btnW = playerSize.height * kZPButtonSizeScale;
    CGFloat btnH = btnW;
    CGFloat btnX = 0;
    CGFloat btnY = playerSize.height - btnH;
    pauseBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    [pauseBtn addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
//    [pauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
    [pauseBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [pauseBtn setImage:[UIImage imageNamed:@"pause-highlightened"] forState:UIControlStateHighlighted];
//    [pauseBtn setBackgroundColor:[UIColor redColor]];
    [self.playController.view addSubview:pauseBtn];
    self.pauseBtn = pauseBtn;
}

-(void) createCloseButton {
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGSize playerSize = self.playController.view.bounds.size;
    CGFloat btnW = playerSize.height * kZPButtonSizeScale;
    CGFloat btnH = btnW;
    CGFloat btnX = playerSize.width - btnW;
    CGFloat btnY = 0;
    closeBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    [closeBtn addTarget:self action:@selector(closePlayerView) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"close-highlightened"] forState:UIControlStateHighlighted];
//    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    //    [pauseBtn setBackgroundColor:[UIColor redColor]];
    [self.playController.view addSubview:closeBtn];
    self.closeBtn = closeBtn;

}
/**
 *  添加进度条
 */
-(void)createProgressBar {
    ZPVideoProgressBar *progressBar = [ZPVideoProgressBar videoProgressWithMaxValue:[self.playController duration] minValue:0.0f progressColor:[UIColor brownColor] bufferColor:[UIColor grayColor] backgoundColor:[UIColor whiteColor] sliderButtonColor:[UIColor greenColor]];
//    progressBar.backgroundColor = [UIColor redColor];
    CGSize playerSize = self.playController.view.bounds.size;
    CGFloat progressBarW = playerSize.width - 2 * (self.playBtn.bounds.size.width + kZPPlayerViewSubViewMargin);
    CGFloat progressBarH = self.playBtn.bounds.size.height;
    CGFloat progressBarX = self.playBtn.bounds.size.width + kZPPlayerViewSubViewMargin;
    CGFloat progressBarY = playerSize.height - progressBarH;
    progressBar.frame = CGRectMake(progressBarX, progressBarY, progressBarW, progressBarH);
    progressBar.delegate = self;

    [self.playController.view addSubview:progressBar];
    progressBar.layer.zPosition = 1;
    [self.playController.view bringSubviewToFront:progressBar];
    self.progressBar = progressBar;
}

/**
 *  添加悬浮按钮
 *  图标后期还要替换掉
 */
-(void) createSuspendButton
{
    //1.主悬浮按钮
    DCPathButton *suspendBtn = [[DCPathButton alloc]initWithCenterImage:[UIImage imageNamed:@"add"] highlightedImage:[UIImage imageNamed:@"add-highlighted"]];
    
    
    //设置位置
    CGSize playerSize = self.playController.view.bounds.size;
//    CGFloat btnW = playerSize.width * kZPButtonSizeScale;
//    CGFloat btnH = btnW;
    
//    suspendBtn.frame = CGRectMake(0, 0, btnW, btnH);
    CGPoint suspendBtnCenter = CGPointMake(playerSize.width - suspendBtn.bounds.size.width / 2, playerSize.height / 2);
    suspendBtn.dcButtonCenter = suspendBtnCenter;
    
    suspendBtn.bloomDirection = kDCPathButtonBloomDirectionLeft;
    suspendBtn.delegate = self;
//    suspendBtn.allowSounds = NO;
    suspendBtn.bloomRadius = 60.0f;
    suspendBtn.allowCenterButtonRotation = YES;
    suspendBtn.allowSubItemRotation = YES;
    [self.playController.view addSubview:suspendBtn];
    self.suspendBtn = suspendBtn;
    
    //2.设置子按钮
    //2.1.截屏
    DCPathItemButton *screenShootBtn = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"camera"] highlightedImage:[UIImage imageNamed:@"camera-highlightened"] backgroundImage:nil backgroundHighlightedImage:nil];
    
    DCPathItemButton *muteBtn2 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"mute"] highlightedImage:[UIImage imageNamed:@"mute-highlightened"] backgroundImage:nil backgroundHighlightedImage:nil];
    
    DCPathItemButton *shareBtn3 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"share"]  highlightedImage:[UIImage imageNamed:@"share≥-highlightened"] backgroundImage:nil backgroundHighlightedImage:nil];
    
    DCPathItemButton *likeBtn4 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"like"] highlightedImage:[UIImage imageNamed:@"like-highlightened"] backgroundImage:nil backgroundHighlightedImage:nil];
    
    DCPathItemButton *settingBtn5 = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"setting"] highlightedImage:[UIImage imageNamed:@"setting-highlightened"] backgroundImage:nil backgroundHighlightedImage:nil];
    [suspendBtn addPathItems:@[screenShootBtn, muteBtn2, shareBtn3, likeBtn4, settingBtn5]];
}


static const CGFloat ScreenShootViewBtnWidth = 50.0f;
static const CGFloat ScreenShootViewScale = 0.2f;
-(void) createScreenShootView {
    CGSize playerViewSize = self.playController.view.bounds.size;
    
    //1.外部view
    CGFloat screenShotViewW = playerViewSize.width * ScreenShootViewScale + ScreenShootViewBtnWidth;
    CGFloat screenShotViewH = playerViewSize.height * ScreenShootViewScale;
    CGFloat screenShotViewX = 0.0;
    CGFloat screenShotViewY = 0.0;
    CGRect screenShotViewFrame = CGRectMake(screenShotViewX, screenShotViewY, screenShotViewW, screenShotViewH);
    UIView *screenShotView = [[UIView alloc]initWithFrame:screenShotViewFrame];
    screenShotView.hidden = YES;
//    screenShotView.backgroundColor = [UIColor redColor];
    [self.playController.view addSubview:screenShotView];
    self.screenShotView = screenShotView;
    
    //2.显示的imageview
    CGFloat imageViewW = playerViewSize.width * ScreenShootViewScale;
    CGFloat imageViewH = playerViewSize.height * ScreenShootViewScale;
    CGFloat imageViewX = 0.0;
    CGFloat imageViewY = 0.0;
    CGRect imageViewFrame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
    UIImageView *screenShotImageView = [[UIImageView alloc]initWithFrame:imageViewFrame];
    [screenShotView addSubview:screenShotImageView];
    self.screenShotImageView = screenShotImageView;
    
    CGFloat btnW = ScreenShootViewBtnWidth;
    CGFloat btnH = screenShotViewH / 2;
    CGFloat btnX = imageViewW;
    CGFloat saveImageBtnY = 0;
    CGFloat shareImageBtnY = imageViewH / 2;
    
    //3.保存截图按钮
    UIButton *saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveImageBtn.frame = CGRectMake(btnX, saveImageBtnY, btnW, btnH);
    [saveImageBtn setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
    [saveImageBtn setImage:[UIImage imageNamed:@"save-highlightened"] forState:UIControlStateHighlighted];
//    [saveImageBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveImageBtn addTarget:self action:@selector(saveScreenShotPhoto) forControlEvents:UIControlEventTouchUpInside];
    [screenShotView addSubview:saveImageBtn];
//    saveImageBtn.backgroundColor = [UIColor blueColor];
    
    //4.分享截图按钮
    UIButton *shareImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareImageBtn.frame = CGRectMake(btnX, shareImageBtnY, btnW, btnH);
    [shareImageBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareImageBtn setImage:[UIImage imageNamed:@"share-highlightened"] forState:UIControlStateHighlighted];
//    [shareImageBtn setTitle:@"分享" forState:UIControlStateNormal];
//    [shareImageBtn addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [screenShotView addSubview:shareImageBtn];
//    shareImageBtn.backgroundColor = [UIColor greenColor];
}


-(void)setupTableView {
    CGSize windowSize = [UIApplication sharedApplication].keyWindow.bounds.size;
    CGFloat tableViewW = windowSize.width;
    CGFloat tableViewH = windowSize.height - self.playController.view.bounds.size.height;
    CGFloat tableViewX = 0;
    CGFloat tableViewY = self.playController.view.bounds.size.height + StatuesBarHeight;
    CGRect tableFrame = CGRectMake(tableViewX, tableViewY, tableViewW, tableViewH);
    UITableView *tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStyleGrouped];
    tableView.tableHeaderView = [self createVideoInfoView];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = kCellMargin + kCellImageHeight + kCellMargin;
    [self.view addSubview:tableView];
    [self.view sendSubviewToBack:tableView];
    self.tableView = tableView;
    

}

static const CGFloat StatuesBarHeight = 20.0f;
-(ZPVideoInfoView*)createVideoInfoView {
    ZPVideoInfoView *infoView = [[ZPVideoInfoView alloc]init];
    infoView.info = self.videoInfo;
//    infoView.backgroundColor = [UIColor blueColor];
    CGSize windowSize = [UIApplication sharedApplication].keyWindow.bounds.size;
    CGFloat infoViewW = windowSize.width;
    CGFloat infoViewH = 60;
    CGFloat infoViewX = 0;
    CGFloat infoViewY = self.playController.view.bounds.size.height + StatuesBarHeight;
    infoView.frame = CGRectMake(infoViewX, infoViewY, infoViewW, infoViewH);
    self.videoInfoView = infoView;
    return infoView;
}

-(void)setupTableViewSectionFooterButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"点击查看更多" forState:UIControlStateNormal];
    [btn setTitle:@"点击收起" forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(footBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.clipsToBounds = YES;
    [btn.titleLabel setBackgroundColor:[UIColor whiteColor]];
    self.tableViewSectionFootViewBtn = btn;
}

//-(void)createVideoInfoView {
//    ZPVideoInfoView *infoView = [[ZPVideoInfoView alloc]init];
//    infoView.info = self.videoInfo;
////    infoView.backgroundColor = [UIColor blueColor];
//    CGSize windowSize = [UIApplication sharedApplication].keyWindow.bounds.size;
//    CGFloat infoViewW = windowSize.width;
//    CGFloat infoViewH = windowSize.height - self.playController.view.bounds.size.height;
//    CGFloat infoViewX = 0;
//    CGFloat infoViewY = self.playController.view.bounds.size.height + StatuesBarHeight;
//    infoView.frame = CGRectMake(infoViewX, infoViewY, infoViewW, infoViewH);
//    [self.view addSubview:infoView];
//    [self.view sendSubviewToBack:infoView];
//}

-(void)removeSubView {
    [self.fullScreenBtn removeFromSuperview];
    [self.originalScreenBtn removeFromSuperview];
    [self.playBtn removeFromSuperview];
    [self.pauseBtn removeFromSuperview];
    [self.progressBar removeFromSuperview];
    [self.suspendBtn removeFromSuperview];
    [self.screenShotView removeFromSuperview];
    [self.screenShotImageView removeFromSuperview];
//    self.tableView.tableHeaderView = nil;
}

/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - NetWork Method
/**
 *  获取网络数据
 */
-(void)fetchDataWithKey:(NSString*)key {
    if (key == nil) return;
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //1.确定搜索结果条数
    int pageSize = 0;
    if (self.recommendVideos.count == 0) {
        pageSize = kRelatedRecomendPageSize;
    } else {
        pageSize = self.recommendVideos.count;
    }
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    AFHTTPSessionManager *manager = [app sharedHTTPSession];
    NSDictionary *para = @{ @"key" : key,
                            @"from" : @"mobile_list",
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
    
    [manager GET:kSearchBaseURL parameters:para progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"search request success");
        
        NSDictionary *dataDict = responseObject;
        NSNumber *code = dataDict[@"code"];
        if ([code integerValue] != 100000) {
            //获取数据失败
            [self refetchDataWithKey:key AfterDelay:kReFetchDataTime];
            return;
        }
        
        //获取数据成功
        NSArray *dictArr = dataDict[@"data"];
        NSMutableArray *modelArr = [NSMutableArray array];
        for (NSDictionary *dict in dictArr) {
            [modelArr addObject:[ZPVideoInfo videoInfoWithDict:dict]];
        }
        self.recommendVideos = modelArr;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //网络请求失败
        [self refetchDataWithKey:key AfterDelay:kReFetchDataTime];
    }];
}

-(void)refetchDataWithKey:(NSString*)key AfterDelay:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fetchDataWithKey:key];
    });
    
}

-(void)reloadData {
    [self.tableView reloadData];
}

#pragma mark - User interative

-(void)singleTabAtPlayerView {
    NSLog(@"tab at player view");
    [self showAllSubview];
    [self.timer invalidate];
    __weak __typeof(&*self)weakSelf =self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kZPHideSubviewDuration repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakSelf hideAllSubViewWithAnimation];
    }];
}

/**
 *  关闭弹出的这个播放器
 */
-(void)closePlayerView {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
 *  截屏
 */
-(void)screenShoot {
    //debug
    //查看QYPlayerController里面有什么属性
    /*
    unsigned int count = 0;
    Ivar *members = class_copyIvarList([self.playController class], &count);
    for (int i = 0 ; i < count; i++) {
        Ivar var = members[i];
        const char *memberName = ivar_getName(var);
        const char *memberType = ivar_getTypeEncoding(var);
        //依次打印属性名称和属性类型
        NSLog(@"%s----%s", memberName, memberType);
    }
     */
    //debug
    //隐藏按钮图标等子控件
    [self hideAllSubview];
    //截图
    UIImage *screenShotImage = nil;
    screenShotImage = [ZPTools screenShotsInStream:self.playController.view];
    //恢复按钮图标等子控件
    [self 	showAllSubview];
    //保存到相册库
    //[self saveImageToPhotosAlbum:screenShotImage];
    
    self.screenShotImageView.image = screenShotImage;
    self.screenShotView.hidden = NO;
    self.screenShotView.alpha = 1.0f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1.0f animations:^{
            self.screenShotView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.screenShotView.hidden = YES;
        }];
    });
    
}

-(void)shareImage:(UIImage*)image{
    
}

-(void)saveScreenShotPhoto {
    UIImage *screenShotImage = self.screenShotImageView.image;
    [self saveImageToPhotosAlbum:screenShotImage];
}

/**
 *  将照片存到相册
 */
-(void)saveImageToPhotosAlbum:(UIImage*)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
/**
 *   相册保存回调函数
 */
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *savingResultText = nil;
    if (error) {
        savingResultText = @"保存失败";
    } else {
        savingResultText = @"保存成功";
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.playController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = savingResultText;
    [hud hideAnimated:YES afterDelay:kHUDAppearanceDuration];
//    NSLog(@"%@", savingResultText);
}

/**
 *  全屏显示
 */
-(void)showFullScreen {
    NSLog(@"full screen button did click");
    if (self.isFullScreen) return;
    self.fullScreen = YES;
}

/**
 *  取消全屏显示
 */
-(void)cancelFullScreen {
    NSLog(@"cancel full screen button did click");
    if (!self.isFullScreen) return;
    self.fullScreen = NO;
}
/**
 *  播放
 */
-(void)play {
    NSLog(@"play button did click");
    if (self.isPlaying) return;
    self.playing = YES;
}
/**
 *  暂停
 */
-(void)pause {
    NSLog(@"pause button did click");
    if (!self.isPlaying) return;
    self.playing = NO;
}

/**
 *  静音
 */
-(void)muteSound {
    NSLog(@"mute button did click");
    if (self.isMute) return;
    self.mute = YES;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.playController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"静音";
    [hud hideAnimated:YES afterDelay:kHUDAppearanceDuration];
}
/**
 *  取消静音
 */
-(void)cancelMute {
    NSLog(@"cancel mute button did click");
    if (!self.isMute) return;
    self.mute = NO;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.playController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"取消静音";
    [hud hideAnimated:YES afterDelay:kHUDAppearanceDuration];

}

/**
 *  展开和收起历史记录
 */
-(void)footBtnDidClick {
    UIButton *btn = self.tableViewSectionFootViewBtn;
    if (btn.isSelected) {
        btn.selected = NO;
    } else {
        btn.selected = YES;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void) clickMuteButton {
    if (self.isMute) {
        [self cancelMute];
    } else {
        [self muteSound];
    }
}

-(void) resetPlayingVideo:(ZPVideoInfo*)videoInfo {
    self.videoInfo = videoInfo;
    [self.playController stopPlayer];
    [self removeSubView];
    [self reCreateSubView];
    
    self.videoInfoView.info = videoInfo;
    [self.videoInfoView setNeedsLayout];
    
    [self.playController openPlayerByAlbumId:videoInfo.aID tvId:videoInfo.tvID isVip:videoInfo.isVip];
    [[HistoryManager sharedInstance] addHistoryWithHistory:videoInfo];
    
    
    
    [self.playController play];
//    [self createSubView];
    [self initPlayerState];
    [self fetchDataWithKey:videoInfo.title];
//    [self addSingleTabGesture];

}

#pragma mark - Other method
static bool kIsFullScreen;

/**
 *  动画方式渐隐子控件
 */
-(void)hideAllSubViewWithAnimation {
    [UIView animateWithDuration:kZPHideSubviewAnimationDuration animations:^{
//        kIsFullScreen = self.fullScreenBtn.isHidden;
        self.fullScreenBtn.alpha = 0.0f;
        self.originalScreenBtn.alpha = 0.0f;
        self.playBtn.alpha = 0.0f;
        self.pauseBtn.alpha = 0.0f;
        self.progressBar.alpha = 0.0f;
        self.suspendBtn.alpha = 0.0f;
        self.closeBtn.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self hideAllSubview];
        self.fullScreenBtn.alpha = 1.0f;
        self.originalScreenBtn.alpha = 1.0f;
        self.playBtn.alpha = 1.0f;
        self.pauseBtn.alpha = 1.0f;
        self.progressBar.alpha = 1.0f;
        self.suspendBtn.alpha = 1.0f;
        self.closeBtn.alpha = 1.0f;
    }];
}

/**
 *  隐藏所有子控件
 */
-(void)hideAllSubview {
    kIsFullScreen = self.fullScreenBtn.isHidden;
    self.fullScreenBtn.hidden = YES;
    self.originalScreenBtn.hidden = YES;
    self.playBtn.hidden = YES;
    self.pauseBtn.hidden = YES;
    self.progressBar.hidden = YES;
    self.suspendBtn.hidden = YES;
    self.closeBtn.hidden = YES;
}
/**
 *  显示所有子控件
 */
-(void)showAllSubview {
    if (kIsFullScreen) {
        self.fullScreenBtn.hidden = YES;
        self.originalScreenBtn.hidden = NO;
    } else {
        self.fullScreenBtn.hidden = NO;
        self.originalScreenBtn.hidden = YES;
    }
    //根据播放器播放状态显示播放
    if (self.isPlaying) {
        self.playBtn.hidden = YES;
        self.pauseBtn.hidden = NO;
    } else {
        self.playBtn.hidden = NO;
        self.pauseBtn.hidden = YES;
    }
    self.progressBar.hidden = NO;
    self.suspendBtn.hidden = NO;
    self.closeBtn.hidden = NO;
}

#pragma mark - QYPlayerControllerDelegate

-(void)onContentStartPlay:(QYPlayerController *)player {
    [self createProgressBar];
}

-(void)playbackTimeChanged:(QYPlayerController *)player {
    NSLog(@"buffval = %f, curVal = %f", player.playableDuration, player.currentPlaybackTime);
    [self.progressBar setBufferValue:player.playableDuration];
    if (!self.progressBar.isDraging) {
        [self.progressBar setProgressValue:player.currentPlaybackTime];
    }
    //[self.progressBar setBufferrValue:player.playableDuration];
}

#pragma mark - ZPVideoProgressBarDelegate
-(void)videoProgressEndSlidingWithValue:(id)value {
    [self.playController seekToTime:[value doubleValue]];
}


#pragma mark - DCPathButtomDelegate
- (void)pathButton:(DCPathButton *)dcPathButton clickItemButtonAtIndex:(NSUInteger)itemButtonIndex {
    switch (itemButtonIndex) {
        case 0:
            NSLog(@"screen shoot button did click");
            [self screenShoot];
            break;
        case 1:
            NSLog(@"set mute button did click");
            [self clickMuteButton];
            break;
    }
}

#pragma mark - Table view Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        NSInteger historyCount = [[HistoryManager sharedInstance] getHistoryList].count;
        if (self.tableViewSectionFootViewBtn.isSelected) {
            //展开状态
            return historyCount <= kMaxHistoryItemsCount ? historyCount : kMaxHistoryItemsCount;
        }
        return historyCount <= kMinHistoryItemsCount ? historyCount : kMinHistoryItemsCount;
    }
    return self.recommendVideos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZPVideoInfo *info;
    if (indexPath.section == 0) {
        NSArray *historyList = [[HistoryManager sharedInstance] getHistoryList];
        NSString *historyID = historyList[historyList.count - 1 - indexPath.row];
        info = [[HistoryManager sharedInstance] getHistoryWithId:historyID];
    } else {
        info = self.recommendVideos[indexPath.row];
    }
//    ZPVideoInfo *info = self.recommendVideos[indexPath.row];
    ZPChannelPageViewCell *cell = [ZPChannelPageViewCell cellWithTableView:tableView];
    cell.videoInfo = info;
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    if (section == 0) {
        title = @"历史播放";
    } else {
        title = @"猜你喜欢";
    }
    return title;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return self.tableViewSectionFootViewBtn;
    }
    return nil;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZPVideoInfo *videoInfo;
    if (indexPath.section == 0) {
        NSString *historyID = [[HistoryManager sharedInstance] getHistoryList][indexPath.row];
        videoInfo = [[HistoryManager sharedInstance] getHistoryWithId:historyID];
    } else {
        videoInfo = self.recommendVideos[indexPath.row];
    }
//    ZPVideoInfo *videoInfo = self.recommendVideos[indexPath.row];
    [self resetPlayingVideo:videoInfo];
}



#pragma mark - UIViewControllerAnimatedTransitioning

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


//-(void)pathButton:(DCPathButton*)dcPathButton clickItemButtonAtIndex:(NSUInteger)itemButtonIndex {

//}
