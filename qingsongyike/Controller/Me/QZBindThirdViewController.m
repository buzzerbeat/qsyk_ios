//
//  QZBindThirdViewController.m
//  quiz
//
//  Created by 苗慧宇 on 16/1/6.
//  Copyright © 2016年 subo. All rights reserved.
//

#import "QZBindThirdViewController.h"
#import "QZBindThirdCell.h"
#import <UMSocial.h>

@interface QZBindThirdViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) QSYKUserModel *user;
@property (nonatomic, strong) NSArray *thirdTypes;

@end

@implementation QZBindThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绑定";
    
    _user = [QSYKUserManager shardManager].user;
    self.thirdTypes = @[@"微信帐户", @"QQ账户", @"微博账户"];
    
    _tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.estimatedRowHeight = 100;
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _thirdTypes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QZBindThirdCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_BindThird];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"QZBindThirdCell" owner:nil options:nil][0];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row == 0) {
        
        if (_user.isBindWeixin) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
        }
        
        cell.thirdTypeNameLabel.text = _thirdTypes[indexPath.row];
        cell.bindStateLabel.text = _user.isBindWeixin ? @"已绑定" : @"未绑定";
        cell.thirdTypeImageView.image = [UIImage imageNamed:@"ic_weixin_login_normal"];
    } else if (indexPath.row == 1) {
        
        if (_user.isBindQq) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
        }
        
        cell.thirdTypeNameLabel.text = _thirdTypes[indexPath.row];
        cell.bindStateLabel.text = _user.isBindQq ? @"已绑定" : @"未绑定";
        cell.thirdTypeImageView.image = [UIImage imageNamed:@"ic_qq_login_normal"];
    } else {
        
        if (_user.isBindWeibo) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
        }
        
        cell.thirdTypeNameLabel.text = _thirdTypes[indexPath.row];
        cell.bindStateLabel.text = _user.isBindWeibo ? @"已绑定" : @"未绑定";
        cell.thirdTypeImageView.image = [UIImage imageNamed:@"ic_weibo_login_normal"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *platformName = nil;
    NSString *thirdTypeName = nil;
    if (indexPath.row == 0) {
        platformName = UMShareToWechatSession;
        thirdTypeName = @"weixin";
    } else if (indexPath.row == 1) {
        platformName = UMShareToQQ;
        thirdTypeName = @"qq";
    } else if (indexPath.row == 2) {
        platformName = UMShareToSina;
        thirdTypeName = @"sina";
    }
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:platformName];
    
    snsPlatform.loginClickHandler(self, [UMSocialControllerService defaultControllerService], YES, ^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:platformName];
            
            NSLog(@"userName is %@, unionId is %@, token is %@, url is %@", snsAccount.userName, snsAccount.unionId, snsAccount.accessToken, snsAccount.iconURL);
            
            NSDictionary *parameters = [NSDictionary new];
            if ([thirdTypeName isEqualToString:@"weixin"]) {
                parameters = @{
                               @"oid": snsAccount.unionId,
                               @"type": thirdTypeName
                               };
            } else {
                parameters = @{
                               @"oid": snsAccount.usid,
                               @"type": thirdTypeName
                               };
            }
        
            [SVProgressHUD show];
            @weakify(self);
            [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                   URLString:@"/v2/user/third-valid"
                                                  parameters:parameters
                                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                                         @strongify(self);
                                                         
                                                         QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                         if (result) {
                                                             if (result.status == 0) {
                                                                 
                                                                 if ([thirdTypeName isEqualToString:@"weixin"]) {
                                                                     _user.isBindWeixin = YES;
                                                                     
                                                                 } else if ([thirdTypeName isEqualToString:@"qq"]) {
                                                                     _user.isBindQq = YES;
                                                                     
                                                                 } else if ([thirdTypeName isEqualToString:@"sina"]) {
                                                                     _user.isBindWeibo = YES;
                                                                 }
                                                                 [QSYKUserManager shardManager].user = _user;
                                                                 
                                                                 [self.tableView reloadData];
                                                                 
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kEditProfileNotification
                                                                                                                     object:@{
                                                                                                                              @"key": @"thirdType"
                                                                                                                              }];
                                                                 
                                                                 [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
                                                                 
                                                             } else if (result.status == 1) {
                                                                 [SVProgressHUD showErrorWithStatus:@"该账号已被绑定"];
                                                             }
                                                             
                                                         } else {
                                                             [SVProgressHUD showErrorWithStatus:@"绑定失败"];
                                                         }
                                                         
                                                     } failure:^(NSError *error) {
                                                         [SVProgressHUD showErrorWithStatus:@"绑定失败"];
                                                     }];
        } else {
            [SVProgressHUD showErrorWithStatus:@"绑定失败"];
        }
    });
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
