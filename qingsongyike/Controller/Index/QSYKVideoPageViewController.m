//
//  QSYKVideoPageViewController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKVideoPageViewController.h"
#import "QSYKVideoTableViewCell.h"
#import "QSYKResourceDetailViewController.h"
#import "QSYKGodPostView.h"
#import "QSYKRecommendPageViewController.h"
#import "QSYKMyFavoriteTableViewController.h"
@import MediaPlayer;

static int RESOURCE_TYPE = 3;

@interface QSYKVideoPageViewController () <QSYKCellDelegate, QSYKInnerPageDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *resourceList;
@property (nonatomic, assign) int pageCount;    // 资源总页数
@property (nonatomic, assign) int currentPage;  // 当前页码

@end

@implementation QSYKVideoPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [tableView registerNib:[UINib nibWithNibName:@"QSYKVideoTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_videoCell];
        [tableView registerNib:[UINib nibWithNibName:@"QSYKAdTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_adCell];
        
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.isRefresh = YES;
            self.currentPage = 1;
            [self loadData];
        }];
        tableView.mj_footer = [QSYKRefreshFooter footerWithRefreshingBlock:^{
            [self loadData];
        }];
        
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (kIsIphone) {
                make.edges.equalTo(self.view);
            } else {
                make.top.equalTo(self.view);
                make.bottom.equalTo(self.view);
                make.left.equalTo(self.view.mas_left).offset(SCREEN_WIDTH / 6);
                make.right.equalTo(self.view.mas_right).offset(-SCREEN_WIDTH / 6);
            }
        }];
        
        tableView;
    });
    [self.view addGestureRecognizer:self.tableView.panGestureRecognizer];
    self.view.backgroundColor = self.tableView.backgroundColor;
    
    self.currentPage = 1;
    [self.tableView.mj_header beginRefreshing];
    
    // 广告相关
    if (kAdEnable) {
        [self configNativeAd];
    }
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(SCREEN_WIDTH / 6);
        make.right.equalTo(self.view.mas_right).offset(-SCREEN_WIDTH / 6);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    // 监听用户点击推送消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRemoteNotiResource:) name:kLoadFromRemotePushNotification object:nil];
    // 当在首页的时候，再点击一下首页，返回顶部并刷新获取。
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToTopAndRefresh) name:kRefreshIndexPageNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 当页面离开屏幕时关闭视频播放
    NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visibleRows) {
        if ([self.cellTypeArray[indexPath.row] isEqualToString:@"Resource"]) {
            QSYKVideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell resetWithAcitonType:@"o"];
        }
    }
    
    // 当页面消失时注销对消息的监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showRemoteNotiResource:(NSNotification *)noti {
    [super showRemoteNotiResource:noti];
}

- (void)scrollToTopAndRefresh {
    if ([self isVisible]) {
        [self.tableView.mj_header beginRefreshing];
    }
}

// GDT AD 相关
- (void)configNativeAd {
    self.gdtNativeAd        = [[GDTNativeAd alloc] initWithAppkey:kQQAppId placementId:kQQPosId];
    self.gdtNativeAd.controller = self;
    self.gdtNativeAd.delegate   = self;
    
    /*
     * 拉取广告,传入参数为拉取个数。
     * 发起拉取广告请求,在获得广告数据后回调delegate
     */
    [self.gdtNativeAd loadAd:(int)kQQAdNum]; //一次拉取n条原生广告
}

#pragma mark GDTNativeAdDelegate

-(void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray
{
    NSLog(@"%s",__FUNCTION__);
    /*广告数据拉取成功，存储并展示*/
    
    // 每次刷新广告数据
    self.adData = [NSMutableArray arrayWithArray:nativeAdDataArray];
    
    NSLog(@"%lu",(unsigned long)nativeAdDataArray.count);
}

-(void)nativeAdFailToLoad:(NSError *)error
{
    NSLog(@"%s",__FUNCTION__);
    /*广告数据拉取失败*/
}

- (void)loadData {
    NSMutableDictionary *paramaters = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(RESOURCE_TYPE), @"type", nil];
    if (!self.isRefresh) {
        [paramaters setValue:@(++self.currentPage) forKey:@"page"];
    }
    
    @weakify(self);
    [[QSYKResourceManager sharedManager] getResourceWithParameters:paramaters
                                       success:^(NSArray<QSYKResourceModel *> *resourceList, NSURLSessionDataTask *task) {
                                   
                                               // 首次加载（或刷新）时记录资源总页数
                                               if (self.isRefresh) {
                                                   NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                                                   NSLog(@"pageCount = %@", [response allHeaderFields][@"X-Pagination-Page-Count"]);
                                                   self.pageCount = [[response allHeaderFields][@"X-Pagination-Page-Count"] intValue];
                                               }
                                               
                                               @strongify(self);
                                               [self.tableView.mj_header endRefreshing];
                                               [self.tableView.mj_footer endRefreshing];
                                           
                                               if (resourceList.count && self.currentPage <= self.pageCount) {
                                                   if (self.isRefresh) {
                                                       self.isRefresh = NO;
                                                       self.resourceList = [NSMutableArray new];
                                                   }
                                                   [self removeRedundantResource:resourceList];
                                                   
                                               } else {
                                                   [self.tableView.mj_footer endRefreshingWithNoMoreData];
                                               }
                                               
                                           } failure:^(NSError *error) {
                                               [self.tableView.mj_header endRefreshing];
                                               [self.tableView.mj_footer endRefreshing];
                                               [SVProgressHUD showErrorWithStatus:@"加载失败"];
                                               NSLog(@"error = %@", error);
                                           }];
}

// 去重处理
- (void)removeRedundantResource:(NSArray *)resources {
    NSArray *finalResources = [QSYKUtility removeRedundantData:resources];
    
    // 发送去重日志
    NSString *urlStr = [NSString stringWithFormat:@"%@/listCombine/t/%d/p/%d/a/%lu", kLogBaseURL, RESOURCE_TYPE, _currentPage, resources.count - finalResources.count];
    NSLog(@"log URL = %@", urlStr);
    [[QSYKDataManager sharedManager] sendLogWithURLString:urlStr];
    
    
    // 判断本次请求到的资源去重之后是否还有剩余
    // 如果都重复则重新请求一次
    if (finalResources.count) {
        [self.resourceList addObjectsFromArray:finalResources];
        [self.tableView reloadData];
        
    } else {
        _currentPage++;
        [self loadData];
    }
}

#pragma mark tableView delegate & dataSource \

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger resourceCount = _resourceList.count;
    if (resourceCount) {
        // 把广告cell（如果显示）考虑在内
        NSInteger numberOfRows = resourceCount + (kAdEnable ? resourceCount / kAdInterval : 0);
        
        self.cellTypeArray = [NSMutableArray arrayWithCapacity:numberOfRows];
        for (int i = 0; i < numberOfRows; i++) {
            self.cellTypeArray[i] = @"Resource";
        }
        
        if (kAdEnable) {
            for (int j = 1; j <= resourceCount / kAdInterval; j++) {
                self.cellTypeArray[j * (kAdInterval + 1) - 1] = @"AD";
            }
        }
        
        return numberOfRows;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cellTypeArray[indexPath.row] isEqualToString:@"Resource"]) {
        NSInteger curResourceIndex = indexPath.row - (kAdEnable ? indexPath.row / (kAdInterval + 1) : 0);
        QSYKResourceModel *resource = _resourceList[curResourceIndex];
        
        // width = content标签左右边距离屏幕左右边的距离的和（如果是iPad，需要再减去两边的空白区域的宽度）
        CGFloat width = kIsIphone ? SCREEN_WIDTH - TWO_SIDE_SPACES : SCREEN_WIDTH * 2 / 3 - TWO_SIDE_SPACES;
        
        // 1.文本高度
        CGFloat extraHeight = [QSYKUtility heightForMutilLineLabel:resource.desc
                                                              font:TEXT_FONT
                                                             width:width];
        
        // 神评论
        NSUInteger postCount = resource.godPosts.count;
        if (postCount) {
            CGFloat postHeight = [QSYKGodPostView baseHeight] * postCount;
            for (int i = 0; i < postCount; i++) {
                QSYKPostModel *post = resource.godPosts[i];
                postHeight += [QSYKUtility heightForMutilLineLabel:post.content font:TEXT_FONT width:[QSYKGodPostView contentWidth]];
            }
            
            // 2.神评论高度
            extraHeight += postHeight;
        }
        
        // 3.视频缩略图高度
        if (resource.relVideo.height > resource.relVideo.width) {
            extraHeight += width;
        } else {
            extraHeight += width * resource.relVideo.height / resource.relVideo.width;
        }
        
        return [QSYKVideoTableViewCell cellBaseHeight] + extraHeight;
    } else {
        if (!kAdEnable) {
            return 0;
            
        } else {
            // width = content标签左右边距离屏幕左右边的距离(广告左右距离是15)的和
            //（如果是iPad，需要再减去两边的空白区域的宽度）
            CGFloat width = kIsIphone ? SCREEN_WIDTH - AD_TWO_SIDE_SPACES
            : SCREEN_WIDTH * 2 / 3 - AD_TWO_SIDE_SPACES;
            
            GDTNativeAdData *anAD = self.adData[indexPath.row / (kAdInterval + 1) % kQQAdNum];
            
            CGFloat extraHeight = [QSYKUtility heightForMutilLineLabel:anAD.properties[@"desc"]
                                                                  font:TEXT_FONT
                                                                 width:width];
            
            return [QSYKAdTableViewCell cellBaseHeight] + extraHeight;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cellTypeArray[indexPath.row] isEqualToString:@"Resource"]) {
        QSYKVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_videoCell forIndexPath:indexPath];
        
        NSInteger curResourceIndex = indexPath.row - (kAdEnable ? indexPath.row / (kAdInterval + 1) : 0);
        cell.resource = _resourceList[curResourceIndex];
        cell.indexPath = indexPath;
        cell.delegate = self;
        
        return cell;
    } else {
        QSYKAdTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_adCell forIndexPath:indexPath];
        
        GDTNativeAdData *anAD = self.adData[indexPath.row / (kAdInterval + 1) % kQQAdNum];
        [cell setupWithGDTAd:anAD];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cellTypeArray[indexPath.row] isEqualToString:@"AD"]) {
        /*
         * 广告数据渲染完毕，即将展示时需调用AttachAd方法。(用于统计)
         */
        NSInteger adIndex = (indexPath.row / (kAdInterval + 1)) % kQQAdNum;
        [self.gdtNativeAd attachAd:self.adData[adIndex] toView:cell];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
    {
        // This indeed is an indexPath no longer visible
        // Do something to this non-visible cell...
        
        NSInteger curResourceIndex = indexPath.row - (kAdEnable ? indexPath.row / (kAdInterval + 1) : 0);
        QSYKResourceModel *resource = _resourceList[curResourceIndex];
        if ([self.cellTypeArray[indexPath.row] isEqualToString:@"Resource"] && resource.type == 3) {
            QSYKVideoTableViewCell *curCell = (QSYKVideoTableViewCell *)cell;
            [curCell resetWithAcitonType:@"d"];
        }
        
        [QSYKUtility saveResourceSidIntoDBWithSid:resource.sid];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cellTypeArray[indexPath.row] isEqualToString:@"Resource"]) {
        
        [self pushToInnerPageWithIndexPath:indexPath needScroll:NO];
        
        QSYKVideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell resetWithAcitonType:@"o"];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        // 点击广告
        NSInteger adDataIndex = (indexPath.row / (kAdInterval + 1)) % kQQAdNum;
        
        [self.gdtNativeAd clickAd:self.adData[adDataIndex]];
    }
}

#pragma mark CellDelegate

- (void)shareResoureWithSid:(NSString *)sid imgSid:(NSString *)imgSid content:(NSString *)content isTopic:(BOOL)isTopic{
    [[QSYKShareManager sharedManager] showInVC:self resourceSid:sid imgSid:imgSid content:content isTopic:isTopic];
}

- (void)rateResourceWithSid:(NSString *)sid type:(NSInteger)type indexPath:(NSIndexPath *)indexPath {
    [[QSYKDataManager sharedManager] rateResourceWithSid:sid type:type];
    
    NSInteger curResourceIndex = indexPath.row - (kAdEnable ? indexPath.row / (kAdInterval + 1) : 0);
    QSYKResourceModel *resource = self.resourceList[curResourceIndex];
    if (type == 1) {
        resource.dig++;
        resource.hasDigged = YES;
    } else {
        resource.bury++;
        resource.hasBuried = YES;
    }
    [self.resourceList replaceObjectAtIndex:indexPath.row withObject:resource];
    
    /*
     [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
     URLString:@"resource/rate"
     parameters:@{
     @"type" : @(type),
     @"sid" : sid,
     }
     success:^(NSURLSessionDataTask *task, id responseObject) {
     QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
     if (result && result.success) {
     [SVProgressHUD showSuccessWithStatus:@"评价成功"];
     
     } else {
     [SVProgressHUD showErrorWithStatus:@"评价失败"];
     }
     
     } failure:^(NSError *error) {
     [SVProgressHUD showErrorWithStatus:@"评价失败"];
     NSLog(@"error = %@", error);
     }];
     */
}

// 神评论点赞
- (void)ratePostWithSid:(NSString *)sid indexPath:(NSIndexPath *)indexPath {
    [[QSYKDataManager sharedManager] ratePostWithSid:sid];
    
    // 这里的indexPath，section代表神评论所属的资源，row代表第几个评论
    NSInteger curResourceIndex = indexPath.section - (kAdEnable ? indexPath.section / (kAdInterval + 1) : 0);
    QSYKResourceModel *resource = self.resourceList[curResourceIndex];
    QSYKPostModel *post = resource.godPosts[indexPath.row];
    post.dig++;
    post.hasDigged = YES;
    [resource.hotPosts replaceObjectAtIndex:indexPath.row withObject:post];
    
}

// 查看某个标签类型资源
- (void)tagTappedWithInfo:(QSYKTagModel *)tag {
    QSYKMyFavoriteTableViewController *myFavoritesVC = [[QSYKMyFavoriteTableViewController alloc] init];
    myFavoritesVC.URLStr = [NSString stringWithFormat:@"resource-tag?tag=%@", tag.sid];
    myFavoritesVC.tag = tag;
    myFavoritesVC.title = tag.name;
    myFavoritesVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myFavoritesVC animated:YES];
}

// 删除某个资源
- (void)deleteResourceAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger curResourceIndex = indexPath.row - (kAdEnable ? indexPath.row / (kAdInterval + 1) : 0);
    QSYKResourceModel *resource = _resourceList[curResourceIndex];
    self.deletingResourceSid = resource.sid;
    self.deletingResourceIndexPath = indexPath;
    
    [QSYKUtility showDeleteResourceReasonsWithSid:resource.sid delegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAndReload) name:@"deleteComplete" object:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 1看不懂, 5没意思, 2不喜欢, 3太污了, 4重口味, 0其他
    
    NSInteger index = 0;
    if (buttonIndex == 0) {
        index = 1;
    } else if (buttonIndex == 1) {
        index = 5;
    } else if (buttonIndex == 5) {
        index = 0;
    } else {
        index = buttonIndex;
    }
    
    [[QSYKDataManager sharedManager] deleteResourceWithSid:self.deletingResourceSid type:index];
    
}

- (void) deleteAndReload {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteComplete" object:nil];
    
    if ([self.cellTypeArray[self.deletingResourceIndexPath.row] isEqualToString:@"Resource"]) {
        QSYKVideoTableViewCell *curCell = [self.tableView cellForRowAtIndexPath:self.deletingResourceIndexPath];
        [curCell resetWithAcitonType:@"o"];
    }
    
    [_resourceList removeObjectAtIndex:self.deletingResourceIndexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[self.deletingResourceIndexPath] withRowAnimation:UITableViewRowAnimationRight];
//    [self.tableView reloadData];
    
}

// 通过点击评论图标进入资源内页，定位到评论位置
- (void)locatePostAtIndexPath:(NSIndexPath *)indexPath {
    
    [self pushToInnerPageWithIndexPath:indexPath needScroll:YES];
    
    if ([self.cellTypeArray[indexPath.row] isEqualToString:@"Resource"]) {
        QSYKVideoTableViewCell *curCell = [self.tableView cellForRowAtIndexPath:indexPath];
        [curCell resetWithAcitonType:@"o"];
    }
}

- (void)pushToInnerPageWithIndexPath:(NSIndexPath *)indexPath needScroll:(BOOL)needScroll {
    QSYKResourceInnerPageViewController *innerPage = [[QSYKResourceInnerPageViewController alloc] init];
    innerPage.delegate = self;
    innerPage.resources = _resourceList;
    innerPage.ads = self.adData;
    innerPage.curIndex = indexPath.row;
    innerPage.needScrollToPost = needScroll;
    innerPage.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:innerPage animated:YES];
}

// 从详情页返回主页时将内页最后浏览的资源滑动到屏幕中间
- (void)tableViewScrollToIndex:(NSInteger)index {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
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
