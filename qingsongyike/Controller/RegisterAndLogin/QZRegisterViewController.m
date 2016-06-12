//
//  QZRegisterViewController.m
//  quiz
//
//  Created by subo on 15/12/25.
//  Copyright © 2015年 subo. All rights reserved.
//

#import "QZRegisterViewController.h"
#import "MyHeadImageViewController.h"
#import <UMSocial.h>
#import "QZCompleteUserInfoViewController.h"
#import "WebViewController.h"
#import "QZLoginViewController.h"

#define SELF_VIEW_Y self.view.y
static int remainSeconds = 60;

@interface QZRegisterViewController () <UITextFieldDelegate>
{
    BOOL _isSecureTextEntry;
}

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *getVerifyCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileNumTextField;
@property (weak, nonatomic) IBOutlet UIImageView *pwdVisibiltyImageView;
@property (weak, nonatomic) IBOutlet UIButton *completeBtn;
@property (weak, nonatomic) IBOutlet UILabel *agreementLabel;
@property (strong, nonatomic) IBOutletCollection(id) NSArray *thirdTypeViews;

//@property (strong, nonatomic) NSString *pno;
//@property (strong, nonatomic) NSData *avatarData;
//@property (copy, nonatomic) NSString *imageFilePath;
@property (assign, nonatomic) BOOL flag;    //标识当前键盘是否弹出
@property (nonatomic, strong) NSTimer *timer;

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
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(0, 0, 30, 30);
    [closeBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    self.navigationItem.leftBarButtonItem = closeItem;
    
    _backView.layer.cornerRadius    = 5.f;
    _backView.layer.borderWidth     = 1.f;
    _backView.layer.borderColor     = kSeparatorLightGrayColor.CGColor;
    _completeBtn.layer.cornerRadius = 5.f;
    
    [_mobileNumTextField addTarget:self action:@selector(limitMobileNumLength:) forControlEvents:UIControlEventEditingChanged];
    
    _mobileNumTextField.delegate  = self;
    _passwordTextField.delegate   = self;
    _nickNameTextField.delegate   = self;
    _verifyCodeTextField.delegate = self;
    
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(fireTime) userInfo:nil repeats:NO];
    // [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(fireTime) userInfo:nil repeats:YES];
    [self disableGetVerifyCodeLabelUserInteraction];
    [_getVerifyCodeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getVerifyCode:)]];
    
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
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.thirdLoginEnable = [[[NSUserDefaults standardUserDefaults] valueForKey:@"thirdLoginEnable"] boolValue];
//    if (!_thirdLoginEnable) {
//        for (UIView *subView in self.thirdTypeViews) {
//            subView.hidden = YES;
//        }
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.view endEditing:YES];
}

- (IBAction)dismissBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)enableGetVerifyCodeLabelUserInteraction {
    
    self.getVerifyCodeLabel.userInteractionEnabled = YES;
    self.getVerifyCodeLabel.textColor = [UIColor colorFromHexString:@"f34a23"];
}

- (void)disableGetVerifyCodeLabelUserInteraction {
    
    self.getVerifyCodeLabel.userInteractionEnabled = NO;
    self.getVerifyCodeLabel.textColor = [UIColor colorFromHexString:@"#9B9B9B"];
}

- (void)keyboardDidShow:(NSNotification *)noti {
    if (!(SCREEN_HEIGHT == 480)) {
        if (!_flag) {
            [UIView animateKeyframesWithDuration:0.3f delay:0.f options:0 animations:^{
                if (SCREEN_HEIGHT == 480) {
                    self.view.y -= 80;
                } else {
                    self.view.y -= 30;
                }
            } completion:nil];
        }
        _flag = YES;
    }
}

- (void)keyboardWillHide:(NSNotification *)noti {
    if (!(SCREEN_HEIGHT == 480)) {
        if (_flag) {
            [UIView animateKeyframesWithDuration:0.3f delay:0.f options:0 animations:^{
                if (SCREEN_HEIGHT == 480) {
                    self.view.y += 80;
                } else {
                    self.view.y += 30;
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
        
        if ([QSYKUtility isMobileNum:_mobileNumTextField.text]) {
            [self validateVerifyCode];
        } else {
            [self disableGetVerifyCodeLabelUserInteraction];
        }
    }
}

#pragma mark textfield delgate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (SCREEN_HEIGHT == 480) {
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
    QZLoginViewController *loginPage = [[QZLoginViewController alloc] initWithNibName:@"QZLoginViewController" bundle:nil];
    loginPage.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:loginPage animated:YES];
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
//    [[QSYKUserManager shardManager] checkUserNameExistenceWithUserName:userName
//                                                           success:^{
//                                                               [Utility showHUDAlert:self.view content:@"昵称可用" type:TEXT duration:1.5f useColor:nil];
//                                                           }
//                                                           failure:^(NSError *error) {
//                                                               // 当前昵称不可用
//                                                               [Utility showHUDAlert:self.view content:error.userInfo[@"QSYKError"] type:TEXT duration:1.f useColor:nil];
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

- (void)validateVerifyCode {
    [[QSYKUserManager shardManager] validatePhoneNumber:_mobileNumTextField.text
                                                success:^{
                                                    NSLog(@"手机号验证成功，可以请求验证码");
                                                    [self enableGetVerifyCodeLabelUserInteraction];
                                                } failure:^(NSError *error) {
                                                     NSLog(@"手机号验证失败");
                                                    [self disableGetVerifyCodeLabelUserInteraction];
                                                    
                                                    if (error.userInfo[@"QSYKError"]) {
                                                        [SVProgressHUD showErrorWithStatus:error.userInfo[@"QSYKError"]];
                                                    } else {
                                                        [SVProgressHUD showErrorWithStatus:@"服务器开小差了！"];
                                                    }
                                                }];
}

- (void)getVerifyCode:(id)sender {
    
    [SVProgressHUD show];
    @weakify(self);
    
    [[QSYKUserManager shardManager] requestVerifyCodeWithPhoneNumber:_mobileNumTextField.text success:^{
        @strongify(self);
        
        [self disableGetVerifyCodeLabelUserInteraction];
        [SVProgressHUD showSuccessWithStatus:@"验证码已发送"];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(fireTime) userInfo:nil repeats:YES];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.userInfo[@"QSYKError"]];
        NSLog(@"error %@", error);
    }];
}

- (IBAction)nextStepAction:(id)sender {
    [self.view endEditing:YES];
    // 本地验证（暂时关闭）
//    if (![self isInputInfoValid]) {
//        return;
//    }
    
    NSString *mobile = _mobileNumTextField.text;
    NSString *password = _passwordTextField.text;
    NSString *code = _verifyCodeTextField.text;
    NSString *name = _nickNameTextField.text;
    
    // 提交注册前先检验验证码，验证通过后请求注册接口
    [[QSYKUserManager shardManager] verifyCodeCorrectWithPhoneNumber:mobile
                          verifyCode:code
                             success:^{
                             
                                 [[QSYKUserManager shardManager] registerWithMobileNumber:mobile
                                             name:name
                                         password:password
                                       avatarData:nil success:^(QSYKUserModel *userModel) {
                                           
                                           [QSYKUserManager shardManager].user = userModel;
                                           
                                           [self dismissViewControllerAnimated:YES completion:nil];
                                           [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil];
                                           NSLog(@"＊＊＊注册成功＊＊＊");
                                     
                                 } failure:^(NSError *error) {
                                     [SVProgressHUD showErrorWithStatus:error.userInfo[@"QSYKError"]];
                                    NSLog(@"error = %@", error);
                                 }];
                                 
                         } failure:^(NSError *error) {
                             [SVProgressHUD showErrorWithStatus:error.userInfo[@"QSYKError"]];
                             NSLog(@"error = %@", error);
                         }];
    
}

// 三方账户请求登录
- (void)thirdTypeRequestLogin {
    @weakify(self);
    [[QSYKUserManager shardManager] loginWithThirdPartyOid:_thirdTypeOid
                                                  type:_thirdType
                                               success:^(QSYKUserModel *userModel) {
                                                   @strongify(self);
                                                   
                                                   // 登陆成功，将用户信息存储到本地
                                                   [QSYKUserManager shardManager].user = userModel;
//                                                   [self startApp];
                                                   
                                                   // 通知‘我的’界面更新信息
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil];
                                                   
                                                   [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                               }
                                               failure:^(NSError *error) {
                                                   [SVProgressHUD dismiss];
                                                   @strongify(self);
                                                   
                                                   if (error.code == QSYKErrorTypeThirdNoRegisterFailure) {
                                                       // 未绑定三方账号，先检查用户名是否可用再去注册页
                                                       [self checkThirdTypeUserNameAvailability];
                                                       
                                                   } else {
                                                       [SVProgressHUD showErrorWithStatus:error.userInfo[@"QSYKError"]];
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
            [SVProgressHUD showErrorWithStatus:@"授权失败"];
        }
    });
}

// 微信登录
- (IBAction)weixinBtnClicked:(id)sender {
    // 发送统计日志
//    [[QSYKDataManager sharedLogManager] sendLogToServerWithURLString:@"/action/register/weixin"];
    
    [self requestOauthWithType:UMShareToWechatSession typeDesc:@"weixin"];
}

// QQ登录
- (IBAction)qqBtnClicked:(id)sender {
    // 发送统计日志
//    [[QSYKDataManager sharedLogManager] sendLogToServerWithURLString:@"/action/register/qq"];
    
    [self requestOauthWithType:UMShareToQQ typeDesc:@"qq"];
}

// 微博登录
- (IBAction)weiboBtnClicked:(id)sender {
    // 发送统计日志
//    [[QSYKDataManager sharedLogManager] sendLogToServerWithURLString:@"/action/register/weibo"];
    
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
    [[QSYKUserManager shardManager] checkUserNameExistenceWithUserName:self.thirdTypeUserName
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

//- (void)startApp {
//    [[QSYKDataManager sharedManager] requestWithMethod:QZRequestMethodHTTPGETUID URLString:@"user/startApp"
//                                          parameters:nil
//                                             success:^(NSURLSessionDataTask *task, id responseObject) {
//                                                 QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
//                                                 if (result && !result.status) {
//                                                     [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"startDate"];
//                                                     [[NSUserDefaults standardUserDefaults] synchronize];
//                                                     
//                                                     [Utility showHUDAlert:[[UIApplication sharedApplication] keyWindow] content:@"打开客户端 +50" type:TASK duration:3.0 useColor:nil];
//                                                 }
//                                                 
//                                             } failure:^(NSError *error) {
//                                                 
//                                             }];
//}


- (void)fireTime
{
    if (--remainSeconds <= 0) {
        [self.timer invalidate];
        self.timer = nil;
        remainSeconds = 60;
        
        self.getVerifyCodeLabel.text = @"获取验证码";
        [self enableGetVerifyCodeLabelUserInteraction];
    } else {
        self.getVerifyCodeLabel.text = [NSString stringWithFormat:@"%d秒后重发", remainSeconds];
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
