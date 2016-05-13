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

@interface QSYKPicturePageViewController () <QSYKCellDelegate>
//@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *resourceList;

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
                       @"type" : @2,
                       @"start" : lastResource.start,
                       @"dynamic" : @(_isDynamic),
                       };
    } else {
        paramaters = @{
                       @"type" : @2,
                       @"dynamic" : @(_isDynamic),
                       };
    }
    
    @weakify(self);
    [SVProgressHUD show];
    [[QSYKResourceManager sharedManager] getResourceWithParameters:paramaters
                                                           success:^(NSArray<QSYKResourceModel *> *resourceList) {
                                                               @strongify(self);
                                                               [self.tableView.mj_header endRefreshing];
                                                               [self.tableView.mj_footer endRefreshing];
                                                               [SVProgressHUD dismiss];
                                                               
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

#pragma mark tableView delegate & dataSource \

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resourceList ? _resourceList.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QSYKResourceModel *resource = _resourceList[indexPath.row];
    // width = content标签左右边距离屏幕左右边的距离的和
    CGFloat extraHeight = [QSYKUtility heightForMutilLineLabel:resource.content
                                                          font:16.f
                                                         width:SCREEN_WIDTH - 8 * 4];
    
    if (resource.img.height > resource.img.width * 2 && !resource.img.dynamic) {
        extraHeight += (SCREEN_WIDTH - 8 * 4) * 1.5;
    } else {
        extraHeight += (SCREEN_WIDTH - 8 * 4) * resource.img.height / resource.img.width;
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
    resourceDetailVC.type = resource.type;
    resourceDetailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:resourceDetailVC animated:YES];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)shareResoureWithSid:(NSString *)sid content:(NSString *)content {
    [[QSYKShareManager sharedManager] showInVC:self resourceSid:sid content:content];
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
