//
//  QSYKPicturePageViewController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKPicturePageViewController.h"
#import "QSYKPictureTableViewCell.h"
#import "QSYKResourceDetailViewController.h"
#import "QSYKGodPostView.h"
#import "QSYKMyFavoriteTableViewController.h"

@interface QSYKPicturePageViewController () <QSYKCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *resourceList;
@property (nonatomic, assign) int pageCount;    // 资源总页数
@property (nonatomic, assign) int currentPage;  // 当前页码
@property (nonatomic, assign) int type;         // 资源类型

@end

@implementation QSYKPicturePageViewController

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
        [tableView registerNib:[UINib nibWithNibName:@"QSYKPictureTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_pictureCell];
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
    
}

- (void)viewWillAppear:(BOOL)animated {
    // 监听用户点击推送消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRemoteNotiResource:) name:kLoadFromRemotePushNotification object:nil];
    // 当在首页的时候，再点击一下首页，返回顶部并刷新获取。
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToTopAndRefresh) name:kRefreshIndexPageNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 当页面消失时注销对消息的监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(SCREEN_WIDTH / 6);
        make.right.equalTo(self.view.mas_right).offset(-SCREEN_WIDTH / 6);
    }];
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

- (void)loadData {
    NSMutableDictionary *paramaters = [NSMutableDictionary new];
    self.type = _isDynamic ? 5 : 2;
    
    [paramaters setValue:@(_type) forKey:@"type"];
    [paramaters setValue:@"expand=hotPosts,posts,godPosts" forKey:@"expand"];
    
    if (!self.isRefresh) {
        [paramaters setValue:@(++self.currentPage) forKey:@"page"];
    }
    
    @weakify(self);
//    [SVProgressHUD show];
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
//                                                               [SVProgressHUD dismiss];
                                           
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
//                                                               [SVProgressHUD dismiss];
                                           [SVProgressHUD showErrorWithStatus:@"加载失败"];
                                           [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                                           NSLog(@"error = %@", error);
                                       }];
}

// 去重处理
- (void)removeRedundantResource:(NSArray *)resources {
    NSArray *finalResources = [QSYKUtility removeRedundantData:resources];
    
    // 发送去重日志
    NSString *urlStr = [NSString stringWithFormat:@"%@/logdomain/listCombine/t/%d/p/%d/a/%lu", kLogBaseURL, _type, _currentPage, resources.count - finalResources.count];
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
    return _resourceList ? _resourceList.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QSYKResourceModel *resource = _resourceList[indexPath.row];
    
    // width = content标签左右边距离屏幕左右边的距离的和（如果是iPad，需要再减去两边的空白区域的宽度）
    CGFloat width = kIsIphone ? SCREEN_WIDTH - TWO_SIDE_SPACES : SCREEN_WIDTH * 2 / 3 - TWO_SIDE_SPACES;
    
    CGFloat extraHeight = [QSYKUtility heightForMutilLineLabel:resource.desc
                                                          font:TEXT_FONT
                                                         width:width];
    
    if (resource.relImage.height > resource.relImage.width * 2 && !resource.relImage.dynamic) {
        extraHeight += width * 1.5;
    } else {
        extraHeight += width * resource.relImage.height / resource.relImage.width;
    }
    
    // 神评论
    NSUInteger postCount = resource.godPosts.count;
    if (postCount) {
        CGFloat postHeight = [QSYKGodPostView baseHeight] * postCount;
        for (int i = 0; i < postCount; i++) {
            QSYKPostModel *post = resource.godPosts[i];
            postHeight += [QSYKUtility heightForMutilLineLabel:post.content font:TEXT_FONT width:[QSYKGodPostView contentWidth]];
        }
        extraHeight += postHeight;
    }
    
    return [QSYKPictureTableViewCell cellBaseHeight] + extraHeight;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    QSYKPictureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_pictureCell forIndexPath:indexPath];
    cell.resource = _resourceList[indexPath.row];
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QSYKResourceModel *resource = _resourceList[indexPath.row];
    QSYKResourceDetailViewController *resourceDetailVC = [[QSYKResourceDetailViewController alloc] init];
    resourceDetailVC.sid = resource.sid;
    resourceDetailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:resourceDetailVC animated:YES];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
    {
        // 在非快速滑动的情况下cell滑出手机界面，进行记录
//        if (!tableView.isDecelerating) {
//            NSLog(@"***********");
//        }
        QSYKResourceModel *resource = _resourceList[indexPath.row];
        
        [QSYKUtility saveResourceSidIntoDBWithSid:resource.sid];
    }
}


#pragma mark Cell Delegate

- (void)shareResoureWithSid:(NSString *)sid imgSid:(NSString *)imgSid content:(NSString *)content isTopic:(BOOL)isTopic{
    [[QSYKShareManager sharedManager] showInVC:self resourceSid:sid imgSid:imgSid content:content isTopic:isTopic];
}

- (void)rateResourceWithSid:(NSString *)sid type:(NSInteger)type indexPath:(NSIndexPath *)indexPath {
    [[QSYKDataManager sharedManager] rateResourceWithSid:sid type:type];
    
    QSYKResourceModel *resource = self.resourceList[indexPath.row];
    if (type == 1) {
        resource.dig++;
        resource.hasDigged = YES;
    } else {
        resource.bury++;
        resource.hasBuried = YES;
    }
    [self.resourceList replaceObjectAtIndex:indexPath.row withObject:resource];
}

// 神评论点赞
- (void)ratePostWithSid:(NSString *)sid indexPath:(NSIndexPath *)indexPath {
    [[QSYKDataManager sharedManager] ratePostWithSid:sid];
    
    // 这里的indexPath，section代表神评论所属的资源，row代表第几个评论
    QSYKResourceModel *resource = self.resourceList[indexPath.section];
    QSYKPostModel *post = resource.godPosts[indexPath.row];
    post.dig++;
    post.hasDigged = YES;
    [resource.hotPosts replaceObjectAtIndex:indexPath.row withObject:post];
}

// 查看某个标签类型资源
- (void)tagTappedWithInfo:(QSYKTagModel *)tag {
    QSYKMyFavoriteTableViewController *myFavoritesVC = [[QSYKMyFavoriteTableViewController alloc] init];
    myFavoritesVC.URLStr = [NSString stringWithFormat:@"resource-tags?tag=%@", tag.sid];
    myFavoritesVC.tag = tag;
    myFavoritesVC.title = tag.name;
    myFavoritesVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myFavoritesVC animated:YES];
}

// 删除某个资源
- (void)deleteResourceAtIndexPath:(NSIndexPath *)indexPath {
    QSYKResourceModel *resource = _resourceList[indexPath.row];
    self.deletingResourceSid = resource.sid;
    self.deletingResourceIndexPath = indexPath;
    [QSYKUtility showDeleteResourceReasonsWithSid:resource.sid delegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAndReloadAtIndexPath) name:@"deleteComplete" object:nil];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 1看不懂, 2不喜欢, 3太污了, 4重口味, 0其他
    
    NSInteger index = buttonIndex != 4 ? buttonIndex + 1 : 0;
    [[QSYKDataManager sharedManager] deleteResourceWithSid:self.deletingResourceSid type:index];
    
}

- (void) deleteAndReloadAtIndexPath {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteComplete" object:nil];
    
    [_resourceList removeObjectAtIndex:self.deletingResourceIndexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[self.deletingResourceIndexPath] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView reloadData];
}

// 通过点击评论图标进入资源内页，定位到评论位置
- (void)locatePostAtIndexPath:(NSIndexPath *)indexPath {
    QSYKResourceModel *resource = _resourceList[indexPath.row];
    
    QSYKResourceDetailViewController *resourceDetailVC = [[QSYKResourceDetailViewController alloc] init];
    resourceDetailVC.sid = resource.sid;
    resourceDetailVC.needScrollToPost = YES;
    resourceDetailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:resourceDetailVC animated:YES];
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
