//
//  QZLoginViewController.m
//  quiz
//
//  Created by subo on 15/12/24.
//  Copyright © 2015年 subo. All rights reserved.
//

#import "QZLoginViewController.h"
#import <UMSocial.h>
#import "QSYKError.h"
#import "QZRegisterViewController.h"
#import "QZVerifyCodeViewController.h"
#import "QZCompleteUserInfoViewController.h"

@interface QZLoginViewController () <UITextFieldDelegate>
{
    BOOL _isSecureTextEntry;
}

@property (weak, nonatomic) IBOutlet UITextField *mobileNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *registerLabel;
@property (weak, nonatomic) IBOutlet UILabel *forgotPwdLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *weixinBtn;
@property (weak, nonatomic) IBOutlet UIButton *qqBtn;
@property (weak, nonatomic) IBOutlet UIButton *weiboBtn;
@property (weak, nonatomic) IBOutlet UIView *turnToRegisterPageView;
@property (weak, nonatomic) IBOutlet UIButton *dismissBtn;

@property (weak, nonatomic) IBOutlet UIImageView *userNameIV;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (weak, nonatomic) IBOutlet UIImageView *passwordIV;
@property (weak, nonatomic) IBOutlet UIButton *pwdVisibilityBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgetPwdBtn;
@property (strong, nonatomic) IBOutletCollection(id) NSArray *thirdTypeViews;

@property (copy, nonatomic) NSString *thirdTypeUserName;
@property (copy, nonatomic) NSString *thirdTypeAvatarURL;
@property (copy, nonatomic) NSString *thirdTypeOid;
@property (copy, nonatomic) NSString *thirdType;
@property (nonatomic, assign) BOOL thirdLoginEnable;
@property (nonatomic) BOOL flag;

@end

@implementation QZLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"登录";
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(0, 0, 30, 30);
    [closeBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    self.navigationItem.leftBarButtonItem = closeItem;
    
    _loginBtn.layer.cornerRadius = 5.f;
    _backView.layer.cornerRadius = 5.f;
    _backView.layer.borderColor  = kSeparatorLightGrayColor.CGColor;
    _backView.layer.borderWidth  = 1.f;
    
    [_turnToRegisterPageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popToRegisterPage:)]];
    
    _registerLabel.userInteractionEnabled  = YES;
    _forgotPwdLabel.userInteractionEnabled = YES;
    [_registerLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(registerAction:)]];
    [_forgotPwdLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forgetPwdAction:)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(limitMobileNumLength:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)exitAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.thirdLoginEnable = [[[NSUserDefaults standardUserDefaults] valueForKey:@"thirdLoginEnable"] boolValue];
//    if (!_thirdLoginEnable) {
//        for (UIView *subView in self.thirdTypeViews) {
//            subView.hidden = YES;
//        }
//    }
    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)keyboardDidShow:(NSNotification *)noti {
    if (!_flag) {
        [UIView animateKeyframesWithDuration:0.3f delay:0.f options:0 animations:^{
            self.view.y -= 30;
        } completion:nil];
    }
    _flag = YES;
}

- (void)keyboardWillHide:(NSNotification *)noti {
    if (_flag) {
        [UIView animateKeyframesWithDuration:0.3f delay:0.f options:0 animations:^{
            self.view.y += 30;
        } completion:nil];
    }
    _flag = NO;
}

// 设置密码是否可见及右侧图片样式
- (IBAction)pwdVisibilityBtnClicked:(id)sender
{
    _isSecureTextEntry = !self.passwordTextField.secureTextEntry;
    [self.passwordTextField setSecureTextEntry:_isSecureTextEntry];
//    [self.passwordTextField becomeFirstResponder];
    
    if (_isSecureTextEntry) {
        [self.pwdVisibilityBtn setImage:[UIImage imageNamed:@"login_visibility_on"] forState:UIControlStateNormal];
    } else {
        [self.pwdVisibilityBtn setImage:[UIImage imageNamed:@"login_visibility_off"] forState:UIControlStateNormal];
    }
}

- (void)limitMobileNumLength:(NSNotification *)noti {
    UITextField *textField = (UITextField *)noti.object;
    if ([textField isEqual:_mobileNumTextField]) {
        NSString *text = _mobileNumTextField.text;
        if (text.length > 11) {
            _mobileNumTextField.text = [text substringToIndex:11];
        }
    }
}

- (void)popToRegisterPage:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)registerAction:(id)sender
{
    QZRegisterViewController *registerViewController = [[QZRegisterViewController alloc] initWithNibName:@"QZRegisterViewController" bundle:nil];
    [self.navigationController pushViewController:registerViewController animated:YES];
    
}

// 登录
- (IBAction)loginBtnClicked:(id)sender {
    [self.view endEditing:YES];
    if (![self isInputInfoValid]) {
        return;
    }
    
    [SVProgressHUD show];
    
    [[QSYKUserManager sharedManager] loginWithMobileNum:self.mobileNumTextField.text
                                         password:self.passwordTextField.text
                                          success:^(QSYKUserModel *userModel) {
                                              [SVProgressHUD dismiss];
                                              
                                              // 将用户信息存储到本地
                                              [QSYKUserManager sharedManager].user = userModel;
//                                              [self startApp];
                                              
                                              // 通知相关界面更新信息
                                              [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil];
                                              
                                              [self dismissViewControllerAnimated:YES completion:nil];
                                              
                                          }
                                          failure:^(NSError *error) {
                                              
                                              QSYKErrorType errorType = error.code;
                                              if (errorType == QSYKErrorTypeNoFoundUserLoginFailure) {
                                                  [SVProgressHUD dismiss];
                                                  
                                                  // 当用户输入的手机号未注册时提示是否去注册
                                                  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"该手机号未注册，去注册？" message:nil preferredStyle:UIAlertControllerStyleAlert];
                                                  
                                                  UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"算了" style:UIAlertActionStyleCancel handler:nil];
                                                  [alertController addAction:cancleAction];
                                                  
                                                  UIAlertAction *registerAction = [UIAlertAction actionWithTitle:@"去注册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                      
                                                      [self.navigationController popViewControllerAnimated:YES];
                                                  }];
                                                  [alertController addAction:registerAction];
                                                  
                                                  [self presentViewController:alertController animated:YES completion:nil];
                                              } else {
                                                  [SVProgressHUD showErrorWithStatus:error.userInfo[@"QSYKError"]];
                                              }
                                          }];
}

// 检查输入内容
- (BOOL)isInputInfoValid {
    NSString *mobileNum = _mobileNumTextField.text;
    NSString *password  = _passwordTextField.text;
    
    if (mobileNum.length != 11 || ![QSYKUtility isMobileNum:self.mobileNumTextField.text]) {
        [_mobileNumTextField becomeFirstResponder];
        NSString *message = mobileNum.length == 0 ? @"请输入手机号" : @"手机号格式不正确";
        UIAlertController *alert = [QSYKUtility alertControllerWithTitle:@"请检查输入内容" message:message cancleActionTitle:nil goActionTitle:@"确认" preferredStyle:UIAlertControllerStyleAlert handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    if (!password.length) {
        [_passwordTextField becomeFirstResponder];
        UIAlertController *alert =
        [QSYKUtility alertControllerWithTitle:@"请检查输入内容" message:@"请输入密码" cancleActionTitle:nil goActionTitle:@"确认" preferredStyle:UIAlertControllerStyleAlert handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

// 忘记密码
- (void)forgetPwdAction:(id)sender
{
    QZVerifyCodeViewController *verifyCodeViewController = [[QZVerifyCodeViewController alloc] initWithNibName:@"QZVerifyCodeViewController" bundle:nil];
    
    if ([QSYKUtility isMobileNum:self.mobileNumTextField.text]) {
        [verifyCodeViewController setValue:self.mobileNumTextField.text forKey:@"mobileNumber"];
    }
    [self.navigationController pushViewController:verifyCodeViewController animated:YES];
}

// 三方账户请求登录
- (void)thirdTypeRequestLogin {
    [[QSYKUserManager sharedManager] validateThirdWithOid:_thirdTypeOid from:_thirdType success:^{
        @weakify(self);
        [[QSYKUserManager sharedManager] loginWithThirdPartyOid:_thirdTypeOid
                                                           type:_thirdType
                                                        success:^(QSYKUserModel *userModel) {
                                                            @strongify(self);
                                                            
                                                            // 登陆成功，将用户信息存储到本地
                                                            [QSYKUserManager sharedManager].user = userModel;
                                                            //                                                   [self startApp];
                                                            
                                                            // 通知‘我的’界面更新信息
                                                            [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil];
                                                            
                                                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                            
                                                        }
                                                        failure:^(NSError *error) {
                                                            @strongify(self);
                                                            NSLog(@"error = %@", error);
                                                            
                                                            if (error.code == QSYKErrorTypeThirdNoRegisterFailure) {
                                                                // 未绑定三方账号，先检查用户名是否可用再去注册页
                                                                [self checkThirdTypeUserNameAvailability];
                                                                
                                                            } else {
                                                                [SVProgressHUD showErrorWithStatus:error.userInfo[@"QSYKError"]];
                                                            }
                                                        }];
    } failure:^(NSError *error) {
        NSLog(@"error = %@", error);
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"QSYKError"]];
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
            [SVProgressHUD showErrorWithStatus:@"授权失败"];
        }
    });
}

// 微信登录
- (IBAction)weixinBtnClicked:(id)sender {
    // 发送统计日志
//    [[QSYKDataManager sharedLogManager] sendLogToServerWithURLString:@"/action/login/weixin"];
    
    [self requestOauthWithType:UMShareToWechatSession typeDesc:@"weixin"];
}

// QQ登录
- (IBAction)qqBtnClicked:(id)sender {
    // 发送统计日志
//    [[QSYKDataManager sharedLogManager] sendLogToServerWithURLString:@"/action/login/qq"];
    
    [self requestOauthWithType:UMShareToQQ typeDesc:@"qq"];
}

// 微博登录
- (IBAction)weiboBtnClicked:(id)sender {
    // 发送统计日志
//    [[QSYKDataManager sharedLogManager] sendLogToServerWithURLString:@"/action/login/weibo"];
    
    [self requestOauthWithType:UMShareToSina typeDesc:@"weibo"];
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
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == _passwordTextField) {
        [self loginBtnClicked:nil];
    }
    return YES;
}

/*
- (void)startApp {
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGETUID URLString:@"user/startApp"
                                          parameters:nil
                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                 QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                 if (result && !result.status) {
                                                     [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"startDate"];
                                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                                     
                                                     [QSYKUtility showHUDAlert:[[UIApplication sharedApplication] keyWindow] content:@"打开客户端 +50" type:TASK duration:3.0 useColor:nil];
                                                 }
                                             } failure:^(NSError *error) {
                                                 
                                             }];
}
*/

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
