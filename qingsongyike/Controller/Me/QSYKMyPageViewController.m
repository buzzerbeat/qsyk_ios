//
//  QSYKMyPageViewController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 5/16/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKMyPageViewController.h"
#import "QSYKSettingsTableViewController.h"
#import "QSYKMyFavoriteTableViewController.h"
#import <DKNightVersion/DKNightVersion.h>
#import "QSYKUserInfoModel.h"
#import "QSYKTaskTableViewController.h"

static CGFloat POINTS_LABEL_FONT = 14;
static CGFloat CELL_TEXTLABEL_FONT = 16;

@interface QSYKMyPageViewController ()
@property (nonatomic, strong) NSArray *cellTitles;
@property (nonatomic, strong) NSArray *cellImageViews;
@property (nonatomic, strong) QSYKUserInfoModel *userInfo;

@end

@implementation QSYKMyPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的";
    
    self.tableView.tableFooterView = [UIView new];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 8)];
    headerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.rowHeight = 50.f;
    
    self.cellTitles = @[
                        @"我的收藏",
                        @"我赞过的",
                        @"我的任务",
                        @"我的积分",
                        @"设置",
                        ];
    self.cellImageViews = @[
                            @"ic_fav",
                            @"ic_like",
                            @"ic_task",
                            @"ic_points",
                            @"ic_settings",
                            ];
    
    [self loadUserInfo];
    
    NSLog(@"UUID = %@", UUID);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:kUserInfoChangedNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh:(NSNotification *)noti {
    [self loadUserInfo];
}

- (void)loadUserInfo {
    [SVProgressHUD show];
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
                                             URLString:[NSString stringWithFormat:@"%@/user/info?expand=taskList", kAuthBaseURL]
                                            parameters:nil
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   [SVProgressHUD dismiss];
                                                   
                                                   NSError *error = nil;
                                                   self.userInfo = [[QSYKUserInfoModel alloc] initWithDictionary:responseObject error:&error];
                                                   if (!error) {
                                                       if (_userInfo) {
                                                           [self.tableView reloadData];
                                                       }
                                                   } else {
                                                       NSLog(@"model 生成失败：%@", error);
                                                   }
                                               }
                                               failure:^(NSError *error) {
                                                   [SVProgressHUD dismiss];
                                                   NSLog(@"error = %@", error);
                                               }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = _cellTitles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:_cellImageViews[indexPath.row]];
    cell.textLabel.font = [UIFont systemFontOfSize:CELL_TEXTLABEL_FONT];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
   
    if (indexPath.row == 2) {
        UILabel *taskLabel = [[UILabel alloc] init];
        taskLabel.font = [UIFont systemFontOfSize:POINTS_LABEL_FONT];
        taskLabel.textColor = [UIColor lightGrayColor];
        taskLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:taskLabel];
        
        // 显示当前任务情况
        if (_userInfo.taskList) {
            int finishedTasks = 0, totalTasks = 0;
            for (QSYKTaskModel *aTask in _userInfo.taskList) {
                finishedTasks += aTask.current;
                totalTasks    += aTask.total;
            }
            
            taskLabel.text = [NSString stringWithFormat:@"%d/%d", finishedTasks, totalTasks];
        } else {
            taskLabel.text = @"";
        }
        
        [taskLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView.mas_centerY);
            make.right.equalTo(cell.contentView.mas_right);
        }];
    } else if (indexPath.row == 3) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *pointsLabel = [[UILabel alloc] init];
        pointsLabel.text = _userInfo ? [NSString stringWithFormat:@"%d积分", _userInfo.points] : @"";
        pointsLabel.font = [UIFont systemFontOfSize:POINTS_LABEL_FONT];
        pointsLabel.textColor = [UIColor lightGrayColor];
        pointsLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:pointsLabel];
        [pointsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView.mas_centerY);
            make.right.equalTo(cell.contentView.mas_right);
        }];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
        case 1: {
            QSYKMyFavoriteTableViewController *myFavoritesVC = [[QSYKMyFavoriteTableViewController alloc] init];
            myFavoritesVC.URLStr = indexPath.row == 0 ? @"/favorite" : @"/like";
            myFavoritesVC.title = indexPath.row == 0 ? @"我的收藏" : @"我赞过的";
            myFavoritesVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:myFavoritesVC animated:YES];
        }
            break;
        case 2: {
            QSYKTaskTableViewController *taskListVC = [[QSYKTaskTableViewController alloc] initWithTaskList:_userInfo.taskList];
            taskListVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:taskListVC animated:YES];
        }
            break;
        case 3: {
            
        }
            break;
        case 4: {
            QSYKSettingsTableViewController *settingsVC = [[QSYKSettingsTableViewController alloc] init];
            settingsVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:settingsVC animated:YES];
        }
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
