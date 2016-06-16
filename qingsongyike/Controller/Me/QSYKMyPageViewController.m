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
#import "QSYKTaskTableViewController.h"
#import "QSYKWebViewController.h"
#import "QSYKBaseNavigationController.h"
#import "QZLoginViewController.h"
#import "QZRegisterViewController.h"
#import "QZProfileViewController.h"
#import "QSYKUserBriefInfoCell.h"

static CGFloat POINTS_LABEL_FONT = 14;
static CGFloat CELL_TEXTLABEL_FONT = 16;

@interface QSYKMyPageViewController ()
@property (nonatomic, strong) NSArray *cellTitles;
@property (nonatomic, strong) NSArray *cellImageViews;
@property (nonatomic, strong) QSYKUserModel *user;

@end

@implementation QSYKMyPageViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的";
    
    self.user = [QSYKUserManager sharedManager].user;
    [self loadUserInfo];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"QSYKUserBriefInfoCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_userBrief];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:kUserInfoChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLotteryPage) name:@"test" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout:) name:kLogoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:kLoginSuccessNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadLotteryPage {
    if ([self isVisible]) {
        QSYKWebViewController *aPage = [[QSYKWebViewController alloc] init];
        aPage.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:aPage animated:YES];
    }
}

- (void)updateCellTitlesAndImages {
    if (_user && _user.isLogin) {
        self.cellTitles = @[
                            @[@"me"],
                            @[@"我的收藏", @"我赞过的",],// @"我最近浏览的"],
                            @[@"我的积分", @"我的任务"],
                            @[@"设置"]//@[@"夜间模式", @"设置", @"意见反馈"],
                            ];
        
        self.cellImageViews = @[
                                @[@"ic_fav"],
                                @[@"ic_fav", @"ic_like",],// @"ic_like"],
                                @[@"ic_points", @"ic_task"],
                                @[@"ic_settings"]//@[@"ic_fav", @"ic_settings", @"ic_settings"],
                                ];
    } else {
        self.cellTitles = @[
                            @[@"me"],
                            @[@"我的收藏", @"我赞过的",],// @"我最近浏览的"],
                            @[@"设置"]//@[@"夜间模式", @"设置", @"意见反馈"],
                            ];
        
        self.cellImageViews = @[
                                @[@"ic_fav"],
                                @[@"ic_fav", @"ic_like",],// @"ic_like"],
                                @[@"ic_settings"]//@[@"ic_fav", @"ic_settings", @"ic_settings"],
                                ];
    }
}

- (void)refresh:(NSNotification *)noti {
    _user = [QSYKUserManager sharedManager].user;
    [self.tableView reloadData];
}

- (void)loginSuccess:(NSNotification *)noti {
    _user = [QSYKUserManager sharedManager].user;
    [self loadUserInfo];
    
    [self updateCellTitlesAndImages];
    [self.tableView reloadData];
}

- (void)logout:(NSNotification *)noti {
    _user = nil;
    [QSYKUserManager sharedManager].user = nil;
    
    [self updateCellTitlesAndImages];
    [self.tableView reloadData];
}


- (void)loadUserInfo {
    [SVProgressHUD show];
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
                                             URLString:@"user/info?expand=taskList"
                                            parameters:@{@"client": CLIENT_ID}
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   [SVProgressHUD dismiss];
                                                   
                                                   NSError *error = nil;
                                                   QSYKUserModel *user = [[QSYKUserModel alloc] initWithDictionary:responseObject error:&error];
                                                   if (!error) {
                                                       if (_user.isLogin) {
                                                           [QSYKUserManager sharedManager].user = user;
                                                           self.user = [QSYKUserManager sharedManager].user;
                                                       }
                                                       
                                                       [self updateCellTitlesAndImages];
                                                       [self.tableView reloadData];
                                                       
                                                   } else {
                                                       NSLog(@"model 生成失败：%@", error);
                                                   }
                                               }
                                               failure:^(NSError *error) {
                                                   [SVProgressHUD showErrorWithStatus:@"服务器开小差了"];
                                                   NSLog(@"error = %@", error);
                                               }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cellTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_cellTitles[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 80;
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        QSYKUserBriefInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_userBrief forIndexPath:indexPath];
        
        cell.user = _user;
        [cell.loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    } else {
        static NSString *cellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.textLabel.text = _cellTitles[indexPath.section][indexPath.row];
        cell.imageView.image = [UIImage imageNamed:_cellImageViews[indexPath.section][indexPath.row]];
        cell.textLabel.font = [UIFont systemFontOfSize:CELL_TEXTLABEL_FONT];
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        if (_user.isLogin) {
            if (indexPath.section == 2) {
                if (indexPath.row == 0) {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    UILabel *pointsLabel = [[UILabel alloc] init];
                    pointsLabel.text = _user ? [NSString stringWithFormat:@"%d积分", _user.points] : @"";
                    pointsLabel.font = [UIFont systemFontOfSize:POINTS_LABEL_FONT];
                    pointsLabel.textColor = [UIColor lightGrayColor];
                    pointsLabel.textAlignment = NSTextAlignmentRight;
                    [cell.contentView addSubview:pointsLabel];
                    [pointsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerY.equalTo(cell.contentView.mas_centerY);
                        make.right.equalTo(cell.contentView.mas_right);
                    }];
                } else if (indexPath.row == 1) {
                    UILabel *taskLabel = [[UILabel alloc] init];
                    taskLabel.font = [UIFont systemFontOfSize:POINTS_LABEL_FONT];
                    taskLabel.textColor = [UIColor lightGrayColor];
                    taskLabel.textAlignment = NSTextAlignmentRight;
                    [cell.contentView addSubview:taskLabel];
                    
                    // 显示当前任务情况
                    if (_user.taskList) {
                        int finishedTasks = 0, totalTasks = 0;
                        for (QSYKTaskModel *aTask in _user.taskList) {
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
                }
            }
        } else {
            
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (_user) {
            QZProfileViewController *profilePage = [[QZProfileViewController alloc] initWithNibName:@"QZProfileViewController" bundle:nil];
            profilePage.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:profilePage animated:YES];
        }
    } else if (indexPath.section == 1) {
        NSString *urlStr = nil;
        NSString *title = nil;
        
        if (indexPath.row == 0) {
            urlStr = @"/favorite";
            title = @"我的收藏";
        } else if (indexPath.row == 1) {
            urlStr = @"/like";
            title = @"我的收藏";
        } else {
            title = @"最近浏览";
            urlStr = @"/resources?sid=";
            
        }
        
        QSYKMyFavoriteTableViewController *myFavoritesVC = [[QSYKMyFavoriteTableViewController alloc] init];
        myFavoritesVC.URLStr = urlStr;
        myFavoritesVC.title = title;
        myFavoritesVC.isReadHistory = (indexPath.row == 2);
        myFavoritesVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:myFavoritesVC animated:YES];
        
    } else {
        if (_user.isLogin) {
            if (indexPath.section == 2) {
                if (indexPath.row == 0) {
                    
                } else if (indexPath.row == 1) {
                    QSYKTaskTableViewController *taskListVC = [[QSYKTaskTableViewController alloc] initWithTaskList:_user.taskList];
                    taskListVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:taskListVC animated:YES];
                }
            } else if (indexPath.section == 3){
                if (indexPath.row == 0) {
                    QSYKSettingsTableViewController *settingsVC = [[QSYKSettingsTableViewController alloc] init];
                    settingsVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:settingsVC animated:YES];
                }
            }
        } else {
            if (indexPath.section == 2){
                if (indexPath.row == 0) {
                    QSYKSettingsTableViewController *settingsVC = [[QSYKSettingsTableViewController alloc] init];
                    settingsVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:settingsVC animated:YES];
                }
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark  loginAction

- (void)loginAction {
    QZRegisterViewController *registerView = [[QZRegisterViewController alloc] initWithNibName:@"QZRegisterViewController" bundle:nil];
    QSYKBaseNavigationController *nav = [[QSYKBaseNavigationController alloc] initWithRootViewController:registerView];
    
    [self presentViewController:nav animated:YES completion:nil];
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
