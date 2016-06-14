//
//  QZVerifyCodeViewController.m
//  quiz
//
//  Created by subo on 15/12/27.
//  Copyright © 2015年 subo. All rights reserved.
//

#import "QZVerifyCodeViewController.h"
#import "QZRegisterViewController.h"
#import "QZResetPasswordViewController.h"

static int remainSeconds = 60;

@interface QZVerifyCodeViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *mobielNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (weak, nonatomic) IBOutlet UILabel *getVerifyCodeLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UIImageView *mobileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *verifyCodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *agreementLabel;
@property (weak, nonatomic) IBOutlet UILabel *provisionLabel;

@property (copy, nonatomic) NSString *mobileNumber;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation QZVerifyCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"找回密码";
    
    _nextStepBtn.layer.cornerRadius = 5.f;
    _backView.layer.cornerRadius    = 5.f;
    _backView.layer.borderColor     = kSeparatorLightGrayColor.CGColor;
    _backView.layer.borderWidth     = 1.f;
    
    if (self.mobileNumber.length) {
        self.mobielNumberTextField.text = self.mobileNumber;
        [self.mobielNumberTextField becomeFirstResponder];
    }
    
    _getVerifyCodeLabel.userInteractionEnabled = YES;
    [_getVerifyCodeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getVerifyCodeAction:)]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(limitInputInfoLength:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
}

- (void)limitInputInfoLength:(NSNotification *)noti {
    UITextField *textField = (UITextField *)noti.object;
    if ([textField isEqual:_mobielNumberTextField]) {
        NSString *text = _mobielNumberTextField.text;
        if (text.length > 11) {
            _mobielNumberTextField.text = [text substringToIndex:11];
        }
    } else if ([textField isEqual:_verifyCodeTextField]) {
        NSString *text = _verifyCodeTextField.text;
        if (text.length > 6) {
            _verifyCodeTextField.text = [text substringToIndex:6];
        }
    }
}

- (void)gotoAgreementView
{
    NSLog(@"Goto agreementView");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)enableGetVerifyCodeLabelUserInteraction {
    
    self.getVerifyCodeLabel.userInteractionEnabled = YES;
    self.getVerifyCodeLabel.textColor = [UIColor colorFromHexString:@"f34a23"];
}

- (void)disableGetVerifyCodeLabelUserInteraction {
    
    self.getVerifyCodeLabel.userInteractionEnabled = NO;
    self.getVerifyCodeLabel.textColor = [UIColor colorFromHexString:@"#9B9B9B"];
}

- (void)getVerifyCodeAction:(id)sender
{
    if (![QSYKUtility isMobileNum:self.mobielNumberTextField.text]) {
        [_mobielNumberTextField becomeFirstResponder];
        UIAlertController *alert = [QSYKUtility alertControllerWithTitle:@"请检查输入内容" message:@"手机号格式不正确" cancleActionTitle:nil goActionTitle:@"确定" preferredStyle:UIAlertControllerStyleAlert handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    [SVProgressHUD show];
    
    [[QSYKUserManager sharedManager] forgotPasswordWithPhoneNumber:self.mobielNumberTextField.text
                                                      success:^{
                                                          
                                                          [self disableGetVerifyCodeLabelUserInteraction];
                                                          [SVProgressHUD showSuccessWithStatus:@"验证码已发送"];
                                                          
                                                          self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(fireTime) userInfo:nil repeats:YES];
                                                          
                                                      } failure:^(NSError *error) {
                                                          [SVProgressHUD showErrorWithStatus:error.userInfo[@"QSYKError"]];
                                                          NSLog(@"error %@", error);
                                                      }];
    
}

- (BOOL)isInputInfoValid {
    NSString *mobileNum  = _mobielNumberTextField.text;
    NSString *verifyCode = _verifyCodeTextField.text;
    
    if (![QSYKUtility isMobileNum:mobileNum]) {
        [_mobielNumberTextField becomeFirstResponder];
        UIAlertController *alert = [QSYKUtility alertControllerWithTitle:@"请检查输入内容" message:@"手机号格式不正确" cancleActionTitle:nil goActionTitle:@"确定" preferredStyle:UIAlertControllerStyleAlert handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    if (verifyCode.length == 0) {
        [_verifyCodeTextField becomeFirstResponder];
        UIAlertController *alert = [QSYKUtility alertControllerWithTitle:@"请检查输入内容" message:@"请输入验证码" cancleActionTitle:nil goActionTitle:@"确定" preferredStyle:UIAlertControllerStyleAlert handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

- (IBAction)nextStepClicked:(id)sender {
    if (![self isInputInfoValid]) {
        return;
    }
    
    self.nextStepBtn.enabled = NO;
    
    [SVProgressHUD show];
    @weakify(self);
    
    [[QSYKUserManager sharedManager] verifyCodeCorrectWithPhoneNumber:self.mobielNumberTextField.text
                                                      verifyCode:self.verifyCodeTextField.text
                                                         success:^{
                                                             [SVProgressHUD dismiss];
                                                             @strongify(self);
                                                             
                                                             // 验证通过，跳转到重设密码页面
                                                             QZResetPasswordViewController *resetPwdVC = [[QZResetPasswordViewController alloc] init];
                                                             resetPwdVC.pno = self.mobielNumberTextField.text;
                                                             
                                                             [self.navigationController pushViewController:resetPwdVC animated:YES];
                                                             
                                                         } failure:^(NSError *error) {
                                                             [SVProgressHUD dismiss];
                                                             self.nextStepBtn.enabled = YES;
                                                             
                                                             [SVProgressHUD showErrorWithStatus:error.userInfo[@"QSYKError"]];
                                                         }];
}

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
