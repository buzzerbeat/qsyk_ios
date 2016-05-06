//
//  QZRegisterViewController.m
//  quiz
//
//  Created by subo on 15/12/25.
//  Copyright © 2015年 subo. All rights reserved.
//

#import "QZRegisterViewController.h"
#import "RSKImageCropper.h"
#import "MyHeadImageViewController.h"
#import "QZRootTabViewController.h"
#import "QZGetVerifyCodeViewController.h"
#import <UMSocial.h>
#import "QZCompleteUserInfoViewController.h"
#import "QZGuidView.h"
#import "WebViewController.h"

#define SELF_VIEW_Y self.view.y

@interface QZRegisterViewController () <UITextFieldDelegate>
{
    BOOL _isSecureTextEntry;
}

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileNumTextField;
@property (weak, nonatomic) IBOutlet UIImageView *pwdVisibiltyImageView;
@property (weak, nonatomic) IBOutlet UIButton *completeBtn;
@property (weak, nonatomic) IBOutlet UILabel *agreementLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelBottomCon;

@property (strong, nonatomic) IBOutletCollection(id) NSArray *thirdTypeViews;


@property (strong, nonatomic) NSString *pno;
@property (strong, nonatomic) NSData *avatarData;
@property (copy, nonatomic) NSString *imageFilePath;
@property (assign, nonatomic) BOOL flag;    //标识当前本地存储的头像是否可用，默认不可用

@property (copy, nonatomic) NSString *thirdTypeUserName;
@property (copy, nonatomic) NSString *thirdTypeAvatarURL;
@property (copy, nonatomic) NSString *thirdTypeOid;
@property (copy, nonatomic) NSString *thirdType;
@property (nonatomic, assign) BOOL thirdLoginEnable;

@property (assign, nonatomic) BOOL isEditing;
@property (assign, nonatomic) BOOL isEndEditing;

@property (strong, nonatomic) MyHeadImageViewController *setHeadImageVC;

@end


@implementation QZRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册";
    
    _backView.layer.cornerRadius    = 5.f;
    _backView.layer.borderWidth     = 1.f;
    _backView.layer.borderColor     = kSeparatorLightGrayColor.CGColor;
    _completeBtn.layer.cornerRadius = 5.f;
    
    if (_mobileNum.length) {
        _mobileNumTextField.text = _mobileNum;
    }
    [_mobileNumTextField addTarget:self action:@selector(limitMobileNumLength:) forControlEvents:UIControlEventEditingChanged];
    
    _mobileNumTextField.delegate = self;
    _passwordTextField.delegate = self;
    _nickNameTextField.delegate = self;
    
    _agreementLabel.userInteractionEnabled = YES;
    [_agreementLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoUserAgreementPage:)]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    if (_isLoadFromGuidView) {
        self.navigationItem.leftBarButtonItem =
            [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"login_clear"] style:UIBarButtonItemStylePlain target:self action:@selector(exitAction)];
    }
    
    if (kScreenHeight == 480) {
        self.titleLabelBottomCon.constant = 15.f;
    } else {
        self.titleLabelBottomCon.constant = 50.f;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.thirdLoginEnable = [[[NSUserDefaults standardUserDefaults] valueForKey:@"thirdLoginEnable"] boolValue];
    if (!_thirdLoginEnable) {
        for (UIView *subView in self.thirdTypeViews) {
            subView.hidden = YES;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.view endEditing:YES];
}

- (void)keyboardDidShow:(NSNotification *)noti {
    if (!(kScreenHeight == 480)) {
        if (!_flag) {
            [UIView animateKeyframesWithDuration:0.3f delay:0.f options:0 animations:^{
                if (kScreenHeight == 480) {
                    self.view.y -= 80;
                } else {
                    self.view.y -= 130;
                }
            } completion:nil];
        }
        _flag = YES;
    }
}

- (void)keyboardWillHide:(NSNotification *)noti {
    if (!(kScreenHeight == 480)) {
        if (_flag) {
            [UIView animateKeyframesWithDuration:0.3f delay:0.f options:0 animations:^{
                if (kScreenHeight == 480) {
                    self.view.y += 80;
                } else {
                    self.view.y += 130;
                }
            } completion:nil];
        }
        _flag = NO;
    } else {
        self.view.y = 64;
        self.flag = NO;
    }
    
}

- (void)limitMobileNumLength:(id)sender {
    UITextField *textField = (UITextField *)sender;
    if ([textField isEqual:_mobileNumTextField]) {
        NSString *text = _mobileNumTextField.text;
        if (text.length > 11) {
            _mobileNumTextField.text = [text substringToIndex:11];
        }
    }
}

#pragma mark textfield delgate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (kScreenHeight == 480) {
        [UIView animateKeyframesWithDuration:0.3f delay:0.f options:0 animations:^{
            if (!_flag) {
                if ([textField isEqual:_mobileNumTextField]) {
                    self.view.y = 0;
                } else if ([textField isEqual:_passwordTextField]) {
                    self.view.y = -20;
                } else if ([textField isEqual:_nickNameTextField]) {
                    self.view.y = -50;
                }
            }
            
        } completion:nil];
        
    }
    
    return YES;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self nextStepAction:nil];
    return YES;
}

- (void)gotoUserAgreementPage:(id)sender {
    WebViewController *webViewContrller = [[WebViewController alloc] initWithTitle:@"猜球用户协议" url:kServiceUrl];
    webViewContrller.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:webViewContrller animated:YES];
}

- (void)changePwdVisibility:(id)sender {
    
    _isSecureTextEntry = !self.passwordTextField.secureTextEntry;
    [self.passwordTextField setSecureTextEntry:_isSecureTextEntry];
//    [self.passwordTextField becomeFirstResponder];
    
    if (_isSecureTextEntry) {
        self.pwdVisibiltyImageView.image = [UIImage imageNamed:@"login_visibility_on"];
    } else {
        self.pwdVisibiltyImageView.image = [UIImage imageNamed:@"login_visibility_off"];
    }
}

- (void)exitAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

// 判断当前昵称是否可用
//- (void)checkUserNameExist:(NSString *)userName
//{
//    [[UserManager shardManager] checkUserNameExistenceWithUserName:userName
//                                                           success:^{
//                                                               [Utility showHUDAlert:self.view content:@"昵称可用" type:TEXT duration:1.5f useColor:nil];
//                                                           }
//                                                           failure:^(NSError *error) {
//                                                               // 当前昵称不可用
//                                                               [Utility showHUDAlert:self.view content:error.userInfo[@"QZError"] type:TEXT duration:1.f useColor:nil];
//                                                           }];
//}

/*
- (BOOL)isInputInfoValid {
    NSString *mobileNum = _mobileNumTextField.text;
    NSString *password  = _passwordTextField.text;
    NSString *nickName  = _nickNameTextField.text;
    
    if (mobileNum.length != 11 || ![Utility isMobileNum:mobileNum]) {
        NSString *message = mobileNum.length == 0 ? @"请输入手机号" : @"手机号格式不正确";
        UIAlertController *alert = [Utility showAlertWithTitle:@"请检查输入内容" message:message cancleActionTitle:nil goActionTitle:@"确认" handler:^(UIAlertAction *action) {
//            [self.mobileNumTextField becomeFirstResponder];
        }];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    if (password.length < 6) {
//        [_passwordTextField becomeFirstResponder];
        NSString *message = password.length == 0 ? @"请输入密码" : @"密码长度必须大于6个字符";
        UIAlertController *alert = [Utility showAlertWithTitle:@"请检查输入内容" message:message cancleActionTitle:nil goActionTitle:@"确认" handler:^(UIAlertAction *action) {
            
        }];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    if (nickName.length < 2) {
//        [_nickNameTextField becomeFirstResponder];
        NSString *message = nickName.length == 0 ? @"请输入昵称" : @"昵称长度必须为2-12个字符";
        UIAlertController *alert = [Utility showAlertWithTitle:@"请检查输入内容" message:message cancleActionTitle:nil goActionTitle:@"确认" handler:^(UIAlertAction *action) {
            
        }];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}
 */

#pragma mark nextAction

- (IBAction)nextStepAction:(id)sender {
    [self.view endEditing:YES];
    // 本地验证（暂时关闭）
//    if (![self isInputInfoValid]) {
//        return;
//    }
    
    // 检验注册信息是否合法，验证通过后自动请求验证码
    [[UserManager shardManager] validateRegisterWithPhoneNumber:self.mobileNumTextField.text
                                                        password:self.passwordTextField.text
                                                           uname:self.nickNameTextField.text
                                                         success:^{
                                                             [self requestVerifyCode];
                                                             
                                                         } failure:^(NSError *error) {
                                                             [Utility showHUDTextAlert:self.view content:error.userInfo[@"QZError"]];
                                                         }];
    
}

- (void)requestVerifyCode {
    @weakify(self);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[UserManager shardManager] requestVerifyCodeWithPhoneNumber:_mobileNumTextField.text success:^{
        @strongify(self);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        QZGetVerifyCodeViewController *getVerifyCodeVC =
        [[QZGetVerifyCodeViewController alloc] initWithNibName:@"QZGetVerifyCodeViewController" bundle:nil];
        getVerifyCodeVC.mobileNum = _mobileNumTextField.text;
        getVerifyCodeVC.password  = _passwordTextField.text;
        getVerifyCodeVC.nickName  = _nickNameTextField.text;
        
        [self.navigationController pushViewController:getVerifyCodeVC animated:YES];
        
    } failure:^(NSError *error) {
        @strongify(self);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [Utility showHUDTextAlert:self.view content:error.userInfo[@"QZError"]];
        NSLog(@"error %@", error);
    }];
}

// 三方账户请求登录
- (void)thirdTypeRequestLogin {
    @weakify(self);
    [[UserManager shardManager] loginWithThirdPartyOid:_thirdTypeOid
                                                  type:_thirdType
                                               success:^(QZUserModel *userModel) {
                                                   @strongify(self);
                                                   [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                   
                                                   // 登陆成功，将用户信息存储到本地
                                                   [UserManager shardManager].user = userModel;
                                                   [self startApp];
                                                   
                                                   // 通知‘我的’界面更新信息
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil];
                                                   
                                                   // 跳转逻辑
                                                   if (_isLoadFromGuidView) {
                                                       for (UIView *view in [UIApplication sharedApplication].keyWindow.rootViewController.view.subviews) {
                                                           if ([view isKindOfClass:[QZGuidView class]]) {
                                                               [view removeFromSuperview];
                                                           }
                                                       }
                                                   }
                                                   [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                               }
                                               failure:^(NSError *error) {
                                                   @strongify(self);
                                                   [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                   
                                                   if (error.code == QZErrorTypeThirdNoRegisterFailure) {
                                                       // 未绑定三方账号，先检查用户名是否可用再去注册页
                                                       [self checkThirdTypeUserNameAvailability];
                                                       
                                                   } else {
                                                       [Utility showHUDAlert:self.view content:error.userInfo[@"QZError"] type:TEXT duration:1.f useColor:nil];
                                                   }
                                               }];
}

// 请求三方授权
- (void)requestOauthWithType:(NSString *)type typeDesc:(NSString *)typeDesc{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:type];
    
    snsPlatform.loginClickHandler(self, [UMSocialControllerService defaultControllerService], YES, ^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:type];
            
            NSLog(@"userName is %@, unionId is %@, token is %@, url is %@", snsAccount.userName, snsAccount.unionId, snsAccount.accessToken, snsAccount.iconURL);
            
            self.thirdTypeUserName = snsAccount.userName;
            self.thirdTypeAvatarURL = snsAccount.iconURL;
            self.thirdType = typeDesc;
            
            if ([UMShareToWechatSession isEqualToString:type]) {
                self.thirdTypeOid = snsAccount.unionId;
            } else {
                self.thirdTypeOid = snsAccount.usid;
            }
            
            [self thirdTypeRequestLogin];
        } else {
            kTipAlert(@"授权失败");
        }
    });
}

// 微信登录
- (IBAction)weixinBtnClicked:(id)sender {
    // 发送统计日志
    [[QZDataManager sharedLogManager] sendLogToServerWithURLString:@"/action/register/weixin"];
    
    [self requestOauthWithType:UMShareToWechatSession typeDesc:@"weixin"];
}

// QQ登录
- (IBAction)qqBtnClicked:(id)sender {
    // 发送统计日志
    [[QZDataManager sharedLogManager] sendLogToServerWithURLString:@"/action/register/qq"];
    
    [self requestOauthWithType:UMShareToQQ typeDesc:@"qq"];
}

// 微博登录
- (IBAction)weiboBtnClicked:(id)sender {
    // 发送统计日志
    [[QZDataManager sharedLogManager] sendLogToServerWithURLString:@"/action/register/weibo"];
    
    [self requestOauthWithType:UMShareToSina typeDesc:@"sina"];
}

// 检查第三方账号的用户名是否可用
- (void)checkThirdTypeUserNameAvailability {
    
    QZCompleteUserInfoViewController *completeUserInfoVC = [[QZCompleteUserInfoViewController alloc] initWithNibName:@"QZCompleteUserInfoViewController" bundle:nil];
    completeUserInfoVC.userName     = self.thirdTypeUserName;
    completeUserInfoVC.oid          = self.thirdTypeOid;
    completeUserInfoVC.avatarURL    = self.thirdTypeAvatarURL;
    completeUserInfoVC.type         = self.thirdType;
    completeUserInfoVC.isThirdLogin = YES;
    
    [self.navigationController pushViewController:completeUserInfoVC animated:YES];
    
    /*
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[UserManager shardManager] checkUserNameExistenceWithUserName:self.thirdTypeUserName
                                                           success:^{
                                                               
                                                               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                               
                                                               // 用户名可用，直接跳转
                                                               [self.navigationController pushViewController:completeUserInfoVC animated:YES];
                                                               
                                                           } failure:^(NSError *error) {
                                                               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                               // 用户名不可用，在其后面添加3位随机数
                                                               self.thirdTypeUserName = [NSString stringWithFormat:@"%@%.3d", self.thirdTypeUserName, (arc4random() %1000)];
                                                               completeUserInfoVC.userName = self.thirdTypeUserName;
                                                               [self.navigationController pushViewController:completeUserInfoVC animated:YES];
                                                               
                                                           }];
     */
}

- (void)startApp {
    [[QZDataManager sharedManager] requestWithMethod:QZRequestMethodHTTPGETUID URLString:@"user/startApp"
                                          parameters:nil
                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                 ResultModel *result = [[ResultModel alloc] initWithDictionary:responseObject error:nil];
                                                 if (result && !result.status) {
                                                     [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"startDate"];
                                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                                     
                                                     [Utility showHUDAlert:[[UIApplication sharedApplication] keyWindow] content:@"打开客户端 +50" type:TASK duration:3.0 useColor:nil];
                                                 }
                                                 
                                             } failure:^(NSError *error) {
                                                 
                                             }];
}


#pragma mark delete local avatar file

- (void)deleteLocalAvatar:(NSString *)filePath {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL success = [fileManager fileExistsAtPath:filePath];
    if(success) {
        success = [fileManager removeItemAtPath:filePath error:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
