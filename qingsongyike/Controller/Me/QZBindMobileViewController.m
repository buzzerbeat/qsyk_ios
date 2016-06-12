//
//  QZBindMobileViewController.m
//  quiz
//
//  Created by 苗慧宇 on 16/1/6.
//  Copyright © 2016年 subo. All rights reserved.
//

#import "QZBindMobileViewController.h"

@interface QZBindMobileViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *mobileNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *getVerifyCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *backView;

@property (strong, nonatomic) NSTimer *timer;

@end

static int remainSeconds = 60;

@implementation QZBindMobileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"绑定手机";
    
//    UIButton *bindBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    bindBtn.frame = CGRectMake(0, 0, 30, 30);
//    [bindBtn setTitle:@"绑定" forState:UIControlStateNormal];
//    [bindBtn setTitleColor:[UIColor black75PercentColor] forState:UIControlStateDisabled];
//    [bindBtn setTitleColor:[UIColor black50PercentColor] forState:UIControlStateNormal];
//    [bindBtn addTarget:self action:@selector(bindMobile:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"绑定" style:UIBarButtonItemStylePlain target:self action:@selector(bindMobile:)];
    
    _backView.layer.cornerRadius = 5.f;
    _backView.layer.borderColor = kSeparatorLightGrayColor.CGColor;
    _backView.layer.borderWidth = 1.f;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getVerifyCodeAction:)];
    [self.getVerifyCodeLabel addGestureRecognizer:tapGesture];
    
    [_mobileNumTextField addTarget:self action:@selector(limitMobileNumLength:) forControlEvents:UIControlEventEditingChanged];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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

- (BOOL)isInputInfoValid {
    NSString *mobileNum = _mobileNumTextField.text;
    NSString *verifyCode = _verifyCodeTextField.text;
    NSString *password = _passwordTextField.text;
    NSString *message = nil;
    int flag = 0;
    
    if (![QSYKUtility isMobileNum:mobileNum]) {
        [_mobileNumTextField becomeFirstResponder];
        message = @"请输入正确的手机号";
        flag = 1;
    } else if (verifyCode.length < 6) {
        [_verifyCodeTextField becomeFirstResponder];
        message = @"请输入正确的验证码";
        flag = 1;
    } else if (password.length < 6) {
        [_verifyCodeTextField becomeFirstResponder];
        message = @"密码长度必须大于6个字符";
        flag = 1;
    }
    
    if (flag) {
        UIAlertController *alert = [QSYKUtility alertControllerWithTitle:@"请检查输入内容" message:message cancleActionTitle:nil goActionTitle:@"确定" preferredStyle:UIAlertControllerStyleAlert handler:nil];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    } else {
        return  YES;
    }
    
}

- (void)disableGetVerifyCodeLabelUserInteraction {
    
    self.getVerifyCodeLabel.userInteractionEnabled = NO;
    self.getVerifyCodeLabel.textColor = [UIColor colorFromHexString:@"#9B9B9B"];
}

- (void)enableGetVerifyCodeLabelUserInteraction {
    
    self.getVerifyCodeLabel.userInteractionEnabled = YES;
    self.getVerifyCodeLabel.textColor = kCoreColor;
}

- (void)getVerifyCodeAction:(id)sender
{
    if (![QSYKUtility isMobileNum:_mobileNumTextField.text]) {
        [_mobileNumTextField becomeFirstResponder];
        UIAlertController *alert = [QSYKUtility alertControllerWithTitle:@"请检查输入内容" message:@"请输入正确的手机号" cancleActionTitle:nil goActionTitle:@"确认" preferredStyle:UIAlertControllerStyleAlert handler:nil];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    @weakify(self);
    [SVProgressHUD show];
    
    [[QSYKUserManager shardManager] requestVerifyCodeWithPhoneNumber:self.mobileNumTextField.text
                                                         success:^{
                                                             @strongify(self);
                                                             
                                                             [SVProgressHUD showSuccessWithStatus:@"验证码已发送"];
                                                             [self disableGetVerifyCodeLabelUserInteraction];
                                                             self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(fireTime) userInfo:nil repeats:YES];
                                                             
                                                             
                                                         }
                                                         failure:^(NSError *error) {
                                                             @strongify(self);
                                                             
                                                             if (error.code == QSYKErrorTypeRegisterFailure) {
                                                                 [SVProgressHUD showErrorWithStatus:error.userInfo[@"QSYKError"]];
                                                             } else {
                                                                 [SVProgressHUD showErrorWithStatus:@"发送失败"];
                                                             }
                                                             NSLog(@"error %@", error);
                                                             
                                                         }];
}

- (void)fireTime
{
    if (--remainSeconds <= 0) {
        [self.timer invalidate];
        self.timer = nil;
        remainSeconds = 60;
        
        [self enableGetVerifyCodeLabelUserInteraction];
        self.getVerifyCodeLabel.text = @"获取验证码";
        self.getVerifyCodeLabel.userInteractionEnabled = YES;
        self.getVerifyCodeLabel.textColor = [UIColor grassColor];
    } else {
        [self disableGetVerifyCodeLabelUserInteraction];
        self.getVerifyCodeLabel.text = [NSString stringWithFormat:@"%d秒后重新发送", remainSeconds];
    }
}

- (void)bindMobile:(id)sender {
    [self.view endEditing:YES];
    if (![self isInputInfoValid]) {
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"vco": self.verifyCodeTextField.text,
                                 @"pno": self.mobileNumTextField.text,
                                 @"pwd": self.passwordTextField.text
                                 };
    
    [SVProgressHUD show];
    @weakify(self);
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                           URLString:@"user/mobileBind"
                                          parameters:parameters
                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                 @strongify(self);
                                                 
                                                 QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                 if (result) {
                                                     if (result.status == 0) {
                                                         [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
                                                         
                                                         QSYKUserModel *tempUser = [QSYKUserManager shardManager].user;
                                                         NSString *secureMobileNumber = [self.mobileNumTextField.text
                                                                                         stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                                                         tempUser.userMobile = secureMobileNumber;
                                                         [QSYKUserManager shardManager].user = tempUser;
                                                         
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:kEditProfileNotification
                                                                                                             object:@{
                                                                                                                      @"key": @"mobile"
                                                                                                                      }];
                                                         [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(popViewController) userInfo:nil repeats:NO];
                                                         
                                                     } else if(result.status == 1) {
                                                         [SVProgressHUD showErrorWithStatus:@"已存在绑定的手机号码"];
                                                     }
                                                     
                                                 }
                                                 
                                             } failure:^(NSError *error) {
                                                 [SVProgressHUD showErrorWithStatus:@"绑定失败"];
                                             }];
}

- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
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
