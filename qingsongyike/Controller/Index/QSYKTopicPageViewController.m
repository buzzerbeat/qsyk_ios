//
//  QSYKTopicPageViewController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKTopicPageViewController.h"
#import "QSYKTopicTableViewCell.h"
#import "QSYKResourceDetailViewController.h"

@interface QSYKTopicPageViewController () <QSYKCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *resourceList;

@end

@implementation QSYKTopicPageViewController

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
        [tableView registerNib:[UINib nibWithNibName:@"QSYKTopicTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_topicCell];
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.isRefresh = YES;
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showRemoteNotiResource:(NSNotification *)noti {
    NSLog(@"noti = %@", noti.userInfo);
    
    QSYKResourceDetailViewController *resourceDetailVC = [[QSYKResourceDetailViewController alloc] init];
    resourceDetailVC.sid = noti.userInfo[@"resourceSid"];
    resourceDetailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:resourceDetailVC animated:YES];
}

- (void)scrollToTopAndRefresh {
    [self.tableView.mj_header beginRefreshing];
}

- (void)loadData {
    NSDictionary *paramaters = nil;
    if (!self.isRefresh) {
        QSYKResourceModel *lastResource = _resourceList.lastObject;
        paramaters = @{
                       @"type" : @1,
                       @"start" : lastResource.start,
                       };
    } else {
        paramaters = @{@"type" : @1};
    }
    
    @weakify(self);
//    [SVProgressHUD show];
    [[QSYKResourceManager sharedManager] getResourceWithParameters:paramaters
                                                           success:^(NSArray<QSYKResourceModel *> *resourceList) {
                                                               @strongify(self);
//                                                               [SVProgressHUD dismiss];
                                                               [self.tableView.mj_header endRefreshing];
                                                               [self.tableView.mj_footer endRefreshing];
                                                               
                                                               if (resourceList.count) {
                                                                   if (self.isRefresh) {
                                                                       self.isRefresh = NO;
                                                                       self.resourceList = [NSMutableArray new];
                                                                   }
                                                                   [self.resourceList addObjectsFromArray:resourceList];
                                                                   [self.tableView reloadData];
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

#pragma mark tableView delegate & dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resourceList.count ?: 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QSYKResourceModel *resource = _resourceList[indexPath.row];
    
    // width = content标签左右边距离屏幕左右边的距离的和（如果是iPad，需要再减去两边的空白区域的宽度）
    CGFloat width = kIsIphone ? SCREEN_WIDTH - 8 * 4 : SCREEN_WIDTH * 2 / 3 - 8 * 4;
    
    CGFloat extraHeight = [QSYKUtility heightForMutilLineLabel:resource.content
                                                          font:16.f
                                                         width:width];
    
    return [QSYKTopicTableViewCell cellBaseHeight] + extraHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QSYKTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_topicCell forIndexPath:indexPath];
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


#pragma mark Cell Delegate

- (void)shareResoureWithSid:(NSString *)sid imgSid:(NSString *)imgSid content:(NSString *)content isTopic:(BOOL)isTopic{
    [[QSYKShareManager sharedManager] showInVC:self resourceSid:sid imgSid:imgSid content:content isTopic:isTopic];
}

- (void)rateResourceWithSid:(NSString *)sid type:(NSInteger)type indexPath:(NSIndexPath *)indexPath {
    [QSYKUtility rateResourceWithSid:sid type:type];
    
    QSYKResourceModel *resource = self.resourceList[indexPath.row];
    if (type == 1) {
        resource.dig++;
    } else {
        resource.bury++;
    }
    [self.resourceList replaceObjectAtIndex:indexPath.row withObject:resource];
}

- (void)commentResourceWithSid:(NSString *)sid {
    
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
