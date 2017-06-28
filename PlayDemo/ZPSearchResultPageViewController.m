//
//  ZPSearchPageViewController.m
//  PlayDemo
//
//  Created by HZP on 2017/6/16.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ZPSearchResultPageViewController.h"
#import "ZPVideoInfo.h"
#import "ZPPlayerViewController.h"
#import "ZPChannelPageViewCell.h"
#import "AFHTTPSessionManager.h"
#import "MJRefresh.h"
#import "MBProgressHUD.h"



static NSString* const kSearchBaseURL = @"http://iface.qiyi.com/openapi/batch/search";
static const NSUInteger kSearchPageSize = 30;

static const CGFloat kHeaderViewHeight = 50;
static const CGFloat kCloseButtonWidth = 50;

@interface ZPSearchResultPageViewController () <UISearchBarDelegate>

/**
 *  搜索结果模型
 */
@property (nonatomic, strong) NSMutableArray *searchResults;

/**
 *  headerView，放上方的搜索框和关闭按钮
 */
@property (nonatomic, weak) UIView *headerView;
/**
 *  搜索栏
 */
@property (nonatomic, weak) UISearchBar *searchBar;
/**
 *  关闭按钮
 */
@property (nonatomic, weak) UIButton *closeBtn;
@end

@implementation ZPSearchResultPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubView];
    [self fetchDataWithKey:self.searchKey];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup Subview
/**
 *  设置子控件
 */
- (void)setupSubView {
    [self setupTableView];
//    [self setupHeaderView];
    [self setupRefreshControl];
}

/**
 *  设置上拉加载更多控件
 */
-(void)setupRefreshControl {
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self fetchMoreData];
    }];
    [footer setTitle:@"上拉加载更多" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在加载" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"松开加载更多" forState:MJRefreshStatePulling];
    [footer setTitle:@"加载失败" forState:MJRefreshStateNoMoreData];
    self.tableView.mj_footer = footer;
}

/**
 *  设置tableview
 */
-(void)setupTableView {
    UIEdgeInsets insect = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableView.contentInset = insect;
    self.tableView.rowHeight = kCellMargin + kCellImageHeight + kCellMargin;
}

-(void)setupHeaderView {
    UIView *headerView = [[UIView alloc]init];
    
    CGFloat headerViewX = 0;
    CGFloat headerViewY = 50;
    CGFloat headerViewW = self.view.bounds.size.width;
    CGFloat headerViewH = kHeaderViewHeight;
    headerView.frame = CGRectMake(headerViewX, headerViewY, headerViewW, headerViewH);
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
    
    [self setupSearchBar];
    [self setupCloseButton];
}

/**
 *  设置搜索栏
 */
- (void)setupSearchBar {
    UISearchBar *searchBar = [[UISearchBar alloc]init];
    searchBar.placeholder = @"请输入搜索关键字";
    CGFloat searchBarX = 0;
    CGFloat searchBarY = 0;
    CGFloat searchBarW = self.headerView.bounds.size.width - kCloseButtonWidth;
    CGFloat searchBarH = self.headerView.bounds.size.height;
    searchBar.frame = CGRectMake(searchBarX, searchBarY, searchBarW, searchBarH);
    searchBar.delegate = self;
    [self.headerView addSubview:searchBar];
    self.searchBar = searchBar;
}

/**
 *  设置关闭按钮
 */
-(void)setupCloseButton {
//    UIButtonTypeCustom
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    closeBtn.backgroundColor = [UIColor redColor];
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
//    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [closeBtn setBackgroundColor:[UIColor grayColor]];
    [closeBtn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    CGFloat btnW = kCloseButtonWidth;
    CGFloat btnH = self.headerView.bounds.size.height;
    CGFloat btnX = self.view.bounds.size.width - btnW;
    CGFloat btnY = 0;
    closeBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    [self.headerView addSubview:closeBtn];
    self.closeBtn = closeBtn;
}
#pragma mark - User Interation
-(void)closeView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NetWork Method
/**
 *  获取网络数据
 */
-(void)fetchDataWithKey:(NSString*)key {
    if (key == nil) return;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //1.确定搜索结果条数
    int pageSize = 0;
    if (self.searchResults.count == 0) {
        pageSize = kSearchPageSize;
    } else {
        pageSize = self.searchResults.count;
    }
    self.searchKey = key;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [self searchDataFailed];
            });
            return;
        }
        
        //获取数据成功
        NSArray *dictArr = dataDict[@"data"];
        NSMutableArray *modelArr = [NSMutableArray array];
        for (NSDictionary *dict in dictArr) {
            [modelArr addObject:[ZPVideoInfo videoInfoWithDict:dict]];
        }
        self.searchResults = modelArr;
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
    //1.确定搜索结果条数
    int pageSize = 0;
    if (self.searchResults.count == 0) {
        pageSize = kSearchPageSize;
    } else {
        pageSize = self.searchResults.count;
    }
    
    int pageIndex = self.searchResults.count / kSearchPageSize + 1;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSDictionary *para = @{ @"key" : self.searchKey,
                            @"from" : @"mobile_list",
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
    
    [manager GET:kSearchBaseURL parameters:para progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"search request success");
        
        NSDictionary *dataDict = responseObject;
        NSNumber *code = dataDict[@"code"];
        if ([code integerValue] != 100000) {
            //获取数据失败
            dispatch_async(dispatch_get_main_queue(), ^{
                [self searchDataFailed];
            });
            return;
        }
        
        //获取数据成功
        NSArray *dictArr = dataDict[@"data"];
        for (NSDictionary *dict in dictArr) {
            [self.searchResults addObject:[ZPVideoInfo videoInfoWithDict:dict]];
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


/**
 *  网络请求失败
 */
-(void)requestFailed {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSString *msg = @"网络请求失败";
    NSLog(@"%@", msg);
//    [self showHudWithMessage:msg duration:2.0f];
    [self cancelRefreshing];
}



/**
 *  获取搜索数据失败
 */
-(void)searchDataFailed {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSString *msg = @"获取搜索数据失败";
    NSLog(@"%@", msg);
//    [self showHudWithMessage:msg duration:2.0f];
    [self cancelRefreshing];
}


-(void)reloadData {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.tableView reloadData];
    [self cancelRefreshing];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

//-(void)test {
//    if (self.table.style == UITableViewStylePlain) {
//        UIEdgeInsets contentInset = _table.contentInset;
//        contentInset.top = 25;
//        [_table setContentInset:contentInset];
//    } //创建search
//    _searchcontroller = [[UISearchController alloc] initWithSearchResultsController:nil]; _searchcontroller.searchResultsUpdater = self;
//    _searchcontroller.dimsBackgroundDuringPresentation = NO;
//    _searchcontroller.hidesNavigationBarDuringPresentation = NO;
//    _searchcontroller.searchBar.frame = CGRectMake(self.searchcontroller.searchBar.frame.origin.x, self.searchcontroller.searchBar.frame.origin.y, self.searchcontroller.searchBar.frame.size.width, 44.0);
//    self.searchcontroller.searchBar.delegate = self;
//    self.searchcontroller.searchBar.keyboardType = UIKeyboardTypeDefault;
//    CGRect r= self.table.tableHeaderView.bounds; r.origin.y=-10;
//    self.table.tableHeaderView.bounds=r;
//    self.table.tableHeaderView = self.searchcontroller.searchBar; }
//}

/**
 *  停止上拉下拉转着的菊花
 */
-(void)cancelRefreshing {
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}

#pragma mark - Table view Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZPVideoInfo *info = self.searchResults[indexPath.row];
    ZPChannelPageViewCell *cell = [ZPChannelPageViewCell cellWithTableView:tableView];
    cell.videoInfo = info;
    return cell;
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
    ZPVideoInfo *videoInfo = self.searchResults[indexPath.row];
    ZPPlayerViewController *playerVC = [[ZPPlayerViewController alloc]init];
    playerVC.videoInfo = videoInfo;
    [self presentViewController:playerVC animated:YES completion:nil];
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
