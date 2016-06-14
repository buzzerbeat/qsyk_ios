//
//  QSYKMyFavoriteTableViewController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 5/16/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKMyFavoriteTableViewController.h"
#import "QSYKFavoriteResourceModel.h"
#import "QSYKPictureTableViewCell.h"
#import "QSYKTopicTableViewCell.h"
#import "QSYKVideoTableViewCell.h"
#import "QSYKResourceDetailViewController.h"
@import MediaPlayer;

@interface QSYKMyFavoriteTableViewController () <UITableViewDelegate, UITableViewDataSource, QSYKCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, strong) UILabel *noDataIndicatorLabel;

@end

@implementation QSYKMyFavoriteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
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
    
    self.noDataIndicatorLabel = ({
        UILabel *label = [UILabel new];
        label.text = @"空空如也~";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:18.];
        label.hidden = YES;
        [self.view addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.centerY.equalTo(self.view.mas_centerY).offset(-50);
        }];
        
        label;
    });
    
    [self loadResource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 当页面离开屏幕时关闭视频播放
    [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)loadResource {
    
    [SVProgressHUD show];
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
                                             URLString:_URLStr
                                            parameters:@{@"expand":@"godPosts"}
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   [SVProgressHUD dismiss];
                                                   
                                                   QSYKFavoriteResourceList *model = [[QSYKFavoriteResourceList alloc] initWithArray:responseObject];
                                                   if (model.list.count) {
                                                       self.noDataIndicatorLabel.hidden = YES;
                                                       self.models = [NSMutableArray arrayWithArray:model.list];
                                                       [self.tableView reloadData];
                                                   } else {
                                                       self.noDataIndicatorLabel.hidden = NO;
                                                   }
                                                   
                                               } failure:^(NSError *error) {
                                                   self.noDataIndicatorLabel.hidden = YES;
                                                   [SVProgressHUD showErrorWithStatus:@"服务器开小差了~"];
                                                   NSLog(@"error = %@", error);
                                               }];
}


#pragma mark tableView delegate & dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _models.count ?: 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QSYKFavoriteModel *aModel = _models[indexPath.row];
    QSYKResourceModel *resource = aModel.resource;
    NSInteger cellType = resource.type;
    
    // width = content标签左右边距离屏幕左右边的距离的和
    CGFloat extraHeight = [QSYKUtility heightForMutilLineLabel:resource.desc
                                                          font:16.f
                                                         width:SCREEN_WIDTH - 8 * 4];
    
    if (cellType == 1) {
        return [QSYKTopicTableViewCell cellBaseHeight] + extraHeight;
        
    } else if (cellType == 2) {
        // 图片类型的cell的高度根据图片本事的宽高比来计算在不同屏幕宽度下的高度
        if (resource.relImage.height > 2 * resource.relImage.width && !resource.relImage.dynamic) {
            extraHeight += (SCREEN_WIDTH - 8 * 4) * 1.5;
        } else {
            extraHeight += (SCREEN_WIDTH - 8 * 4) * resource.relImage.height / resource.relImage.width;
        }
        
        return [QSYKPictureTableViewCell cellBaseHeight] + extraHeight;
    } else {
        // video类型同图片
        if (resource.relVideo.height > resource.relVideo.width) {
            extraHeight += (SCREEN_WIDTH - 8 * 4);
        } else {
            extraHeight += (SCREEN_WIDTH - 8 * 4) * resource.relVideo.height / resource.relVideo.width;
        }
        
        return [QSYKVideoTableViewCell cellBaseHeight] + extraHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QSYKFavoriteModel *aModel = _models[indexPath.row];
    QSYKResourceModel *resource = aModel.resource;
    NSInteger cellType = resource.type;
    
    switch (cellType) {
        case 1: {
            QSYKTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_topicCell forIndexPath:indexPath];
            cell.resource = resource;
            cell.flag = YES;
            cell.indexPath = indexPath;
            cell.delegate = self;
            
            return cell;
        }
            break;
        case 2: {
            QSYKPictureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_pictureCell forIndexPath:indexPath];
            cell.resource = resource;
            cell.flag = YES;
            cell.indexPath = indexPath;
            cell.delegate = self;
            
            return cell;
        }
            break;
        case 3: {
            QSYKVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_videoCell forIndexPath:indexPath];
            cell.resource = resource;
            cell.flag = YES;
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
    QSYKFavoriteModel *aModel = _models[indexPath.row];
    QSYKResourceModel *resource = aModel.resource;
    
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
        QSYKFavoriteModel *aModel = _models[indexPath.row];
        QSYKResourceModel *resource = aModel.resource;
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
    [[QSYKDataManager sharedManager] rateResourceWithSid:sid type:type];
    
    QSYKFavoriteModel *aModel = _models[indexPath.row];
    QSYKResourceModel *resource = aModel.resource;
    if (type == 1) {
        resource.dig++;
    } else {
        resource.bury++;
    }
    [self.models replaceObjectAtIndex:indexPath.row withObject:resource];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
