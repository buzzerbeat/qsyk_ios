//
//  QSYKRecommendPageViewController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKRecommendPageViewController.h"
#import "QSYKPictureTableViewCell.h"
#import "QSYKTopicTableViewCell.h"
#import "QSYKVideoTableViewCell.h"
#import "QSYKResourceDetailViewController.h"
#import "QSYKFavoriteResourceModel.h"
@import MediaPlayer;

@interface QSYKRecommendPageViewController () <QSYKCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *resourceList;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation QSYKRecommendPageViewController

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
        [tableView registerNib:[UINib nibWithNibName:@"QSYKTopicTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_topicCell];
        [tableView registerNib:[UINib nibWithNibName:@"QSYKVideoTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_videoCell];
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
    
    self.resourceList = [NSMutableArray new];
    [self.tableView.mj_header beginRefreshing];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (!(kIsIphone)) {
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(SCREEN_WIDTH / 6);
            make.right.equalTo(self.view.mas_right).offset(-SCREEN_WIDTH / 6);
        }];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (!(kIsIphone)) {
        NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *anIndexPath in visibleRows) {
            QSYKResourceModel *aModel = _resourceList[anIndexPath.row];
            // 旋转设备时需要刷新类型为“段子”的cell（段子类型的cell约束有点问题导致cell 的 frame不能自适应，原因未找到）
            if (aModel.type == 1) {
                [self.tableView reloadRowsAtIndexPaths:@[anIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

- (void)viewWillLayoutSubviews {
    NSString *resourceSid = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:kRemotePushedResourceSid];
    //    [[[UIAlertView alloc] initWithTitle:nil message:resourceSid delegate:nil cancelButtonTitle:@"111" otherButtonTitles:nil] show];
    if (resourceSid && resourceSid.length) {
        QSYKResourceDetailViewController *resourceDetailVC = [[QSYKResourceDetailViewController alloc] init];
        resourceDetailVC.sid = resourceSid;
        resourceDetailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:resourceDetailVC animated:YES];
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRemotePushedResourceSid];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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
    // 找到屏幕中类型为 video 的 cell
    NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visibleRows) {
        QSYKResourceModel *aResource = _resourceList[indexPath.row];
        if (aResource.type == 3) {
            QSYKVideoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell reset];
        }
    }
    
    // 当页面消失时注销对消息的监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollToTopAndRefresh {
    [self.tableView.mj_header beginRefreshing];
}

- (void)showRemoteNotiResource:(NSNotification *)noti {
    NSLog(@"noti = %@", noti.userInfo);
    
    QSYKResourceDetailViewController *resourceDetailVC = [[QSYKResourceDetailViewController alloc] init];
    resourceDetailVC.sid = noti.userInfo[@"resourceSid"];
    resourceDetailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:resourceDetailVC animated:YES];
}

- (void)loadData {
    NSDictionary *parameters = nil;
    NSString *URLString = nil;
    if (_isBeautyTag) {
        URLString = @"resource/tagListJson/";
        if (!self.isRefresh) {
            QSYKResourceModel *lastResource = _resourceList.lastObject;
            parameters = @{
                           @"tag" : @"uMwg4g0Mwg0",
                           @"start" : lastResource.start,
                           };
        } else {
            parameters = @{@"tag" : @"uMwg4g0Mwg0"};
            
        }
    } else {
        URLString = @"resource/listJson/";
        if (!self.isRefresh) {
            QSYKResourceModel *lastResource = _resourceList.lastObject;
            parameters = @{
                           @"type" : @0,
                           @"start" : lastResource.start,
                           };
        } else {
            parameters = @{@"type" : @0};
        }
    }
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
//    [SVProgressHUD show];
    
    @weakify(self);
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
                                             URLString:URLString
                                            parameters:parameters
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   
                                                   QSYKResourceList *resourceList = [[QSYKResourceList alloc]
                                                                                     initWithArray:responseObject];
                                                   @strongify(self);
                                                   [self.tableView.mj_header endRefreshing];
                                                   [self.tableView.mj_footer endRefreshing];
//                                                   [SVProgressHUD dismiss];
                                                   
                                                   if (resourceList.list.count) {
                                                       if (self.isRefresh) {
                                                           self.isRefresh = NO;
                                                           self.resourceList = [NSMutableArray new];
                                                       }
                                                       [self.resourceList addObjectsFromArray:resourceList.list];
                                                       [self.tableView reloadData];
                                                   } else {
                                                       [self.tableView.mj_footer endRefreshingWithNoMoreData];
                                                   }
                                               }
                                               failure:^(NSError *error) {
                                                   [self.tableView.mj_header endRefreshing];
                                                   [self.tableView.mj_footer endRefreshing];
//                                                   [SVProgressHUD dismiss];
                                                   [SVProgressHUD showErrorWithStatus:@"加载失败"];
                                                   [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                                                   NSLog(@"error = %@", error);
                                               }];
}

#pragma mark tableView delegate & dataSource \

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resourceList.count ?: 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QSYKResourceModel *resource = _resourceList[indexPath.row];
    NSInteger cellType = resource.type;
    
    // width = content标签左右边距离屏幕左右边的距离的和（如果是iPad，需要再减去两边的空白区域的宽度）
    CGFloat width = kIsIphone ? SCREEN_WIDTH - 8 * 4 : SCREEN_WIDTH * 2 / 3 - 8 * 4;
    
    CGFloat extraHeight = [QSYKUtility heightForMutilLineLabel:resource.content
                                                          font:16.f
                                                         width:width];
    
    if (cellType == 1) {
        return [QSYKTopicTableViewCell cellBaseHeight] + extraHeight;
        
    } else if (cellType == 2) {
        // 图片类型的cell的高度根据图片本事的宽高比来计算在不同屏幕宽度下的高度
        if (resource.img.height > 2 * resource.img.width && !resource.img.dynamic) {
            extraHeight += width * 1.5;
        } else {
            extraHeight += width * resource.img.height / resource.img.width;
        }
        
        return [QSYKPictureTableViewCell cellBaseHeight] + extraHeight;
    } else {
        // video类型同图片
        if (resource.video.height > resource.video.width) {
            extraHeight += width;
        } else {
            extraHeight += width * resource.video.height / resource.video.width;
        }
        
        return [QSYKVideoTableViewCell cellBaseHeight] + extraHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cellType = ((QSYKResourceModel *)_resourceList[indexPath.row]).type;
    
    switch (cellType) {
        case 1: {
            QSYKTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_topicCell forIndexPath:indexPath];
            cell.resource = _resourceList[indexPath.row];
            cell.indexPath = indexPath;
            cell.delegate = self;
            
//            cell.contentView.dk_backgroundColorPicker = DKColorPickerWithKey(BG);
//            for (UIView *subView in cell.contentView.subviews) {
//                subView.dk_backgroundColorPicker = DKColorPickerWithKey(BG);
//            }
            return cell;
        }
            break;
        case 2: {
            QSYKPictureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_pictureCell forIndexPath:indexPath];
            cell.resource = _resourceList[indexPath.row];
            cell.indexPath = indexPath;
            cell.delegate = self;
            
            return cell;
        }
            break;
        case 3: {
            QSYKVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_videoCell forIndexPath:indexPath];
            cell.resource = _resourceList[indexPath.row];
            cell.indexPath = indexPath;
            cell.delegate = self;
            
            return cell;
        }
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QSYKResourceModel *resource = _resourceList[indexPath.row];
    
    QSYKResourceDetailViewController *resourceDetailVC = [[QSYKResourceDetailViewController alloc] init];
    resourceDetailVC.sid = resource.sid;
    resourceDetailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:resourceDetailVC animated:YES];
    
    if (resource.type == 3) {
        QSYKVideoTableViewCell *curCell = [tableView cellForRowAtIndexPath:indexPath];
        [curCell reset];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
    {
        // This indeed is an indexPath no longer visible
        // Do something to this non-visible cell...
        QSYKResourceModel *resource = _resourceList[indexPath.row];
        if (resource.type == 3) {
            QSYKVideoTableViewCell *curCell = (QSYKVideoTableViewCell *)cell;
            [curCell reset];
        }
    }
}


#pragma mark CellDelegate

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
