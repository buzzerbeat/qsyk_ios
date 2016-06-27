//
//  QZProfileViewController.m
//  quiz
//
//  Created by subo on 15/12/29.
//  Copyright © 2015年 subo. All rights reserved.
//

#import "QZProfileViewController.h"
#import "ProfileTableViewCell.h"
#import "UserHeaderView.h"
#import "CustomPickerView.h"
#import "MyHeadImageViewController.h"
#import "QSYKUserModel.h"
#import "QZEditProfileViewController.h"
#import "QZBindMobileViewController.h"
#import "QZLoginViewController.h"
#import <UMSocial.h>
#import "QSYKEditSignViewController.h"

@interface QZProfileViewController () <UITableViewDataSource, UITableViewDelegate, CustomPickerViewDelegate, MyHeadImageDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *cellTitlesArray;
@property (strong, nonatomic) UserHeaderView *headerView;
@property (strong, nonatomic) MyHeadImageViewController *setHeadImageVC;
@property (strong, nonatomic) QSYKUserModel *user;
@property (strong, nonatomic) MyHeadImageViewController *setAvatarImageVC;

@end

@implementation QZProfileViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"个人信息";
    self.tableView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.f];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.user = [QSYKUserManager sharedManager].user;
    
    if (kThirdLoginEnable) {
        self.cellTitlesArray = [NSMutableArray arrayWithArray:@[@[@"昵称", @"个性签名", @"性别"], @[@"手机", @"微信", @"QQ", @"微博"], @[@"退出登录"]]];
    } else {
        self.cellTitlesArray = [NSMutableArray arrayWithArray:@[@[@"昵称", @"个性签名", @"性别"], @[@"手机"], @[@"退出登录"]]];
    }
    
    [self layoutTableHeaderView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCell:) name:kEditProfileNotification object:nil];;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kEditProfileNotification object:nil];
}

- (void)layoutTableHeaderView {
    
    self.headerView = [UserHeaderView loadFromXib];
    self.headerView.width = SCREEN_WIDTH;
    self.headerView.separatorViewHeightCons.constant = 1 / [UIScreen mainScreen].scale;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetAvatar:)];
    [self.headerView addGestureRecognizer:tapGesture];
    [self.headerView.avatarImageView setAvatar:[QSYKUtility imgUrl:_user.userAvatar width:300 height:300 extension:@"png"]];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 90)];
    [view addSubview:self.headerView];
    self.tableView.tableHeaderView = view;
}

#pragma mark refresh userName cell or userBrief cell or ...

- (void)refreshCell:(NSNotification *)notification
{
    _user = [QSYKUserManager sharedManager].user;
    NSString *notificationKey = notification.object[@"key"];
    
    if ([notificationKey isEqualToString:@"name"]) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if([notificationKey isEqualToString:@"sign"]) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if ([notificationKey isEqualToString:@"mobile"]) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

// 重设头像
- (void)resetAvatar:(UITapGestureRecognizer *)gesture
{
    self.setHeadImageVC = [[MyHeadImageViewController alloc] initWithTarget:self];
    [self presentViewController:self.setHeadImageVC.actionSheet animated:YES completion:^{}];
}


#pragma mark MyHeadImageDelegate Methods

- (void)presentVC:(UIViewController *)viewController animated:(BOOL)animated
{
    [self presentViewController:viewController animated:YES completion:^{}];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//上传并设置头像
- (void)upLoadAvatarWithFilePath:(NSString *)filePath
{
    NSLog(@"%@", filePath);
    NSData *avatarData = [NSData dataWithContentsOfFile:filePath];
    
//    [self deleteLocalAvatar:filePath];
    
    [SVProgressHUD show];
    
    @weakify(self);
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                           URLString:@"/v2/user/edit"
                                          uploadData:avatarData
                                          parameters:nil
                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                 @strongify(self);
                                                 QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                 
                                                 if (result && !result.status) {
                                                     [SVProgressHUD showSuccessWithStatus:@"上传成功"];
                                                     
//                                                     _user.userAvatar = result.user[@"avatarSid"];
//                                                     [QSYKUserManager shardManager].user = _user;
                                                     
                                                     // 刷新当前页的头像
                                                     self.headerView.avatarImageView.image = [[UIImage imageWithData:avatarData] roundImage];
//                                                     [self.headerView.avatarImageView setAvatar:[QSYKUtility imgUrl:_user.userAvatar width:300 height:300 extension:@"png"]];
                                                     [self.tableView reloadData];
                                                     
                                                     // 通知myPageViewController 刷新的头像
                                                     [[NSNotificationCenter defaultCenter] postNotificationName:kAvatarDidChangedNotification
                                                                                                         object:@{@"avatar": @"avatar"}];
                                                 } else {
                                                     [SVProgressHUD showErrorWithStatus:result.message];
                                                 }
                                             } failure:^(NSError *error) {
                                                 NSLog(@"error = %@", error);
                                                 [SVProgressHUD showErrorWithStatus:@"上传失败"];
                                             }];
    
//    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
//                                             URLString:@"/v2/user/edit"
//                                            parameters:@{@"avatarFile": avatarData}
//                                               success:^(NSURLSessionDataTask *operation, id responseObject) {
//                                                   
//                                                   @strongify(self);
//                                                   QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
//                                                   
//                                                   if (result && !result.status) {
//                                                       [SVProgressHUD showSuccessWithStatus:@"上传成功"];
//                                                       
//                                                       _user.userAvatar = result.user[@"avatarSid"];
//                                                       [QSYKUserManager shardManager].user = _user;
//                                                       
//                                                       // 刷新当前页的头像
//                                                       [self.headerView.avatarImageView setAvatar:[QSYKUtility imgUrl:_user.userAvatar width:120 height:120 extension:@"png"]];
//                                                       [self.tableView reloadData];
//                                                       
//                                                       // 通知myPageViewController 刷新的头像
//                                                       [[NSNotificationCenter defaultCenter] postNotificationName:kAvatarDidChangedNotification
//                                                                                                           object:@{@"avatar": _user.userAvatar}];
//                                                   } else {
//                                                       [SVProgressHUD showErrorWithStatus:result.message];
//                                                   }
//                                               } failure:^(NSError *error) {
//                                                   NSLog(@"error = %@", error);
//                                                   [SVProgressHUD showErrorWithStatus:@"上传失败"];
//                                               }];
}


#pragma mark delete local avatar file

- (void)deleteLocalAvatar:(NSString *)filePath {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL success = [fileManager fileExistsAtPath:filePath];
    if(success) {
        success = [fileManager removeItemAtPath:filePath error:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellTitlesArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.cellTitlesArray objectAtIndex:section] count];
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    if (section != 3) {
//        UIView *sectionFooterView = [[UIView alloc] init];
//        sectionFooterView.backgroundColor = [UIColor clearColor];
//        return sectionFooterView;
//    } else {
//        return nil;
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return 0;
    } else {
        return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    ProfileTableViewCell *cell = (ProfileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"ProfileTableViewCell" owner:nil options:nil][0];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.titleLabel.text = [[self.cellTitlesArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if (indexPath.section == 0) {
        cell.infoLabel.hidden = YES;
        
        if (indexPath.row == 0) {   //昵称
            cell.valueLabel.text = _user.userName;
            
        }
        if (indexPath.row == 1) {   //简介
            
            if (_user.userBrief.length == 0) {
                cell.valueLabel.text = @"未填写";
            } else {
                cell.valueLabel.text = _user.userBrief;
            }
        }
        if (indexPath.row == 2) {   //性别
            switch (_user.userSex) {
                case 0:
                    cell.valueLabel.text = @"保密";
                    break;
                case 1:
                    cell.valueLabel.text = @"男";
                    break;
                case 2:
                    cell.valueLabel.text = @"女";
                    break;
                default:
                    break;
            }
        }
    } else if (indexPath.section == 1) {
        cell.infoLabel.hidden = NO;
        
        cell.infoLabel.text = @"未绑定";
        cell.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        switch (indexPath.row) {
            case 0:
                if (_user.userMobile.length > 0) {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.userInteractionEnabled = NO;
                    
                    NSString *secureMobileNumber = [_user.userMobile stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                    cell.infoLabel.text = secureMobileNumber;
                } else {
                    cell.infoLabel.hidden = YES;
                    
                    cell.valueLabel.text = @"未绑定";
                    cell.userInteractionEnabled = YES;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                break;
                
            case 1:
                if (_user.isBindWeixin) {
                    cell.infoLabel.text = @"已绑定";
                }
                break;
                
            case 2:
                if (_user.isBindQq) {
                    cell.infoLabel.text = @"已绑定";
                }
                break;
                
            case 3:
                if (_user.isBindWeibo) {
                    cell.infoLabel.text = @"已绑定";
                }
                break;
                
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        
        cell.titleLabel.hidden = YES;
        cell.logoutLabel.hidden = NO;
        cell.logoutLabel.text = self.cellTitlesArray[indexPath.section][indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {    //修改昵称（或简介）
        
        if (indexPath.row == 0) {
            QZEditProfileViewController *editProfileViewController = [[QZEditProfileViewController alloc] initWithNibName:@"QZEditProfileViewController" bundle:nil];
            
            editProfileViewController.propertyOldValue = _user.userName;
            
            [self.navigationController pushViewController:editProfileViewController animated:YES];
            
        } else if (indexPath.row == 1) {
            QSYKEditSignViewController *editSignVC = [[QSYKEditSignViewController alloc] initWithNibName:@"QSYKEditSignViewController" bundle:nil];
            
            editSignVC.propertyOldValue = _user.userBrief;
            
            [self.navigationController pushViewController:editSignVC animated:YES];
            
        } else if (indexPath.row == 2) {    //修改性别
            
            NSArray *genderTypesArray = @[@"保密", @"男", @"女"];
            CustomPickerView *customPickerView = [[CustomPickerView alloc] initWithTitileName:@"" dataArray:genderTypesArray delegate:self];
            [customPickerView.myPickerView selectRow:_user.userSex inComponent:0 animated:NO];
            
            [customPickerView showInView:self.view.superview];
            
        }
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {   //绑定手机
            
            QZBindMobileViewController *bindMobileViewController = [[QZBindMobileViewController alloc] initWithNibName:@"QZBindMobileViewController" bundle:nil];
            [self.navigationController pushViewController:bindMobileViewController animated:YES];
        } else {
            // 绑定第三方平台
            [self bindThird:indexPath.row];
        }
        
    } else if (indexPath.section == 2) {   //退出登录
        
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertView addAction:cancleAction];
        
        UIAlertAction *quitAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutNotification object:nil];
            [self.navigationController popViewControllerAnimated:NO];
        }];
        [alertView addAction:quitAction];
        
        [self presentViewController:alertView animated:YES completion:nil];
    }
}


#pragma mark request editProfile

- (void)updateProfileWithKey:(NSString *)key value:(NSString *)value {
    
    NSLog(@"key=%@, value=%@", key, value);
    
    [SVProgressHUD show];
    @weakify(self);
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                             URLString:@"/v2/user/edit"
                                            parameters:@{key: value}
                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                 
                                                 @strongify(self);
                                                 
                                                 QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                 if (result && !result.status) {
                                                         _user.userSex = [value intValue];
                                                         
                                                     // tableView reload the specific cell
                                                     [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                                                     
                                                     [QSYKUserManager sharedManager].user = _user;
                                                     
                                                     [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                                                 } else {
                                                     [SVProgressHUD showErrorWithStatus:result.message];
                                                 }
                                                 
                                             } failure:^(NSError *error) {
                                                 NSLog(@"error = %@", error);
                                                 [SVProgressHUD showErrorWithStatus:@"修改失败"];
                                             }];
}

#pragma mark - BindThird

- (void)bindThird:(NSInteger)index {
    NSString *platformName = nil;
    NSString *thirdTypeName = nil;
    if (index == 1) {
        platformName = UMShareToWechatSession;
        thirdTypeName = @"weixin";
    } else if (index == 2) {
        platformName = UMShareToQQ;
        thirdTypeName = @"qq";
    } else if (index == 3) {
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
                                                                   [QSYKUserManager sharedManager].user = _user;
                                                                   
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
}

#pragma mark - CustomPickerView Delegate and DataSource

- (void)pickerDidSelected:(NSInteger)index customPickerView:(CustomPickerView *)customPickerView
{
    [self updateProfileWithKey:@"sex" value:[NSString stringWithFormat:@"%ld", (long)index]];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    UIViewController *destinationVC = segue.destinationViewController;
//    destinationVC setValue:<#(nullable id)#> forKey:<#(nonnull NSString *)#>
//}

@end
