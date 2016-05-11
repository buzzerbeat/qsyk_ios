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
//@property (nonatomic, strong) UITableView *tableView;
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
            make.edges.equalTo(self.view);
        }];
        
        tableView;
    });
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [SVProgressHUD show];
    [[QSYKResourceManager sharedManager] getResourceWithParameters:paramaters
                                                           success:^(NSArray<QSYKResourceModel *> *resourceList) {
                                                               @strongify(self);
                                                               [SVProgressHUD dismiss];
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
                                                               [SVProgressHUD dismiss];
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
    // width = content标签左右边距离屏幕左右边的距离的和
    CGFloat extraHeight = [QSYKUtility heightForMutilLineLabel:resource.content
                                                          font:16.f
                                                         width:SCREEN_WIDTH - 8 * 4 - 7];
        
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
    resourceDetailVC.type = resource.type;
    resourceDetailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:resourceDetailVC animated:YES];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark Cell Delegate

- (void)shareResoureWithSid:(NSString *)sid content:(NSString *)content {
    [[QSYKShareManager sharedManager] showInVC:self resourceSid:sid content:content];
}

- (void)rateResourceWithSid:(NSString *)sid type:(NSInteger)type indexPath:(NSIndexPath *)indexPath {
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
                                                       
//                                                       [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                                   } else {
                                                       [SVProgressHUD showErrorWithStatus:@"评价失败"];
                                                   }
                                                   
                                               } failure:^(NSError *error) {
                                                   [SVProgressHUD showErrorWithStatus:@"评价失败"];
                                                   NSLog(@"error = %@", error);
                                               }];
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
