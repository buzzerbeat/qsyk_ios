//
//  QSYKTaskTableViewController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 5/20/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKTaskTableViewController.h"
#import "QSYKUserInfoModel.h"

static CGFloat CELL_TEXTLABEL_FONT = 16;
static CGFloat POINTS_LABEL_FONT = 14;

@interface QSYKTaskTableViewController ()
@property (nonatomic, assign) int finishedTaskCount;
@property (nonatomic, assign) int totalTasksCount;

@end

@implementation QSYKTaskTableViewController

- (instancetype)initWithTaskList:(NSArray *)taskList {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.taskList = taskList;
        for (QSYKTaskModel *aTask in taskList) {
            _finishedTaskCount += aTask.current;
            _totalTasksCount   += aTask.total;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"任务";
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.allowsSelection = NO;
    self.tableView.tableFooterView = [UIView new];
    
//    [self loadData];
}

/*
- (void)loadData {
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
*/


#pragma mark UITableView Delegate and DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _taskList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    
    UILabel *taskDescLabel = [[UILabel alloc] init];
    taskDescLabel.text = [NSString stringWithFormat:@"每日任务[%d/%d]", _finishedTaskCount, _totalTasksCount];
    taskDescLabel.textColor = [UIColor lightGrayColor];
    taskDescLabel.font = [UIFont systemFontOfSize:POINTS_LABEL_FONT];
    [headerView addSubview:taskDescLabel];
    [taskDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView.mas_centerY);
        make.left.equalTo(headerView.mas_left).offset(15);
    }];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    QSYKTaskModel *task = _taskList[indexPath.row];
    
    cell.textLabel.font = [UIFont systemFontOfSize:CELL_TEXTLABEL_FONT];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ [%d/%d]", task.desc, task.current, task.total];
    
    UILabel *pointsLabel = [[UILabel alloc] init];
    pointsLabel.text = @"+5积分";
    pointsLabel.font = [UIFont systemFontOfSize:POINTS_LABEL_FONT];
    pointsLabel.textColor = [UIColor lightGrayColor];
    pointsLabel.textAlignment = NSTextAlignmentRight;
    [cell.contentView addSubview:pointsLabel];
    [pointsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell.contentView.mas_centerY);
        make.right.equalTo(cell.contentView.mas_right).offset(-20);
    }];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
