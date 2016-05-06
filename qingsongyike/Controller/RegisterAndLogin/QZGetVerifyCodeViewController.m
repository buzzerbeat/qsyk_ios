//
//  QZGetVerifyCodeViewController.m
//  quiz
//
//  Created by 苗慧宇 on 3/8/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QZGetVerifyCodeViewController.h"
#import "QZCompleteUserInfoViewController.h"

@interface QZGetVerifyCodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *mobileNumLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *getVerifyCodeLabel;
@property (weak, nonatomic) IBOutlet UIButton *completeBtn;

@property (nonatomic, strong) NSTimer *timer;

@end

static int remainSeconds = 60;

@implementation QZGetVerifyCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"注册";
    _mobileNumLabel.text = _mobileNum;
    
    _backView.layer.cornerRadius = 5.f;
    _backView.layer.borderColor = kSeparatorLightGrayColor.CGColor;
    _backView.layer.borderWidth = 1.f;
    _completeBtn.layer.cornerRadius = 5.f;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(fireTime) userInfo:nil repeats:YES];
    [self disableGetVerifyCodeLabelUserInteraction];
    [_getVerifyCodeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getVerifyCode:)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(limitVerifyCodeLength:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)limitVerifyCodeLength:(NSNotification *)noti {
    UITextField *textField = (UITextField *)noti.object;
    if ([textField isEqual:_verifyCodeTextField]) {
        NSString *text = _verifyCodeTextField.text;
        if (text.length > 6) {
            _verifyCodeTextField.text = [text substringToIndex:6];
        }
    }
}

- (void)getVerifyCode:(id)sender {
    
    @weakify(self);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[UserManager shardManager] requestVerifyCodeWithPhoneNumber:_mobileNum success:^{
        @strongify(self);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [self disableGetVerifyCodeLabelUserInteraction];
        [Utility showHUDTextAlert:self.view content:@"验证码已发送"];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(fireTime) userInfo:nil repeats:YES];
    } failure:^(NSError *error) {
        @strongify(self);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [Utility showHUDTextAlert:self.view content:error.userInfo[@"QZError"]];
        NSLog(@"error %@", error);
    }];
}

- (IBAction)completeBtnClicked:(id)sender {
    [self.view endEditing:YES];
    NSString *verifyCode = _verifyCodeTextField.text;
    
    if (verifyCode.length < 6) {
        [_verifyCodeTextField becomeFirstResponder];
        UIAlertController *alert = [Utility showAlertWithTitle:@"请检查输入内容" message:@"请输入验证码" cancleActionTitle:nil goActionTitle:@"确认" handler:^(UIAlertAction *action) {
            
        }];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    @weakify(self);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[UserManager shardManager] verifyCodeCorrectWithPhoneNumber:_mobileNum
                                                      verifyCode:self.verifyCodeTextField.text
                                                         success:^{
                                                             // 验证通过，提交注册
                                                             [self registerAction];
                                                             
                                                         } failure:^(NSError *error) {
                                                             @strongify(self);
                                                             [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                             
                                                             [Utility showHUDAlert:self.view content:error.userInfo[@"QZError"] type:TEXT duration:1.f useColor:nil];
                                                         }];
    
}

- (void)registerAction {
    
    @weakify(self);
    [[UserManager shardManager] registerWithMobileNumber:_mobileNum
                                                    name:_nickName
                                                password:_password
                                                     sex:0
                                                birthday:nil
                                              avatarData:nil
                                                 success:^(QZUserModel *userModel) {
                                                     @strongify(self);
                                                     [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                     
                                                     [UserManager shardManager].user = userModel;
                                                     [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil];
                                                     
                                                     QZCompleteUserInfoViewController *vc =
                                                        [[QZCompleteUserInfoViewController alloc] initWithNibName:@"QZCompleteUserInfoViewController" bundle:nil];
                                                     vc.mobileNum = _mobileNum;
                                                     
                                                     [self.navigationController pushViewController:vc animated:YES];
                                                     
                                                 } failure:^(NSError *error) {
                                                     @strongify(self);
                                                     [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                     [Utility showHUDAlert:self.view content:@"注册失败" type:TEXT duration:1.5f useColor:nil];
                                                     NSLog(@"error %@", error);
                                                 }];
}

- (void)enableGetVerifyCodeLabelUserInteraction {
    
    self.getVerifyCodeLabel.userInteractionEnabled = YES;
    self.getVerifyCodeLabel.textColor = [UIColor colorFromHexString:@"f34a23"];
}

- (void)disableGetVerifyCodeLabelUserInteraction {
    
    self.getVerifyCodeLabel.userInteractionEnabled = NO;
    self.getVerifyCodeLabel.textColor = [UIColor colorFromHexString:@"#9B9B9B"];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
