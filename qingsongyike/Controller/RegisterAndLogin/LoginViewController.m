//
//  LoginViewController.m
//  quiz
//
//  Created by Xin on 15/9/15.
//  Copyright (c) 2015年 subo. All rights reserved.
//

#import "LoginViewController.h"



@interface LoginViewController () <UserCallBackDelegate, UITextFieldDelegate>
- (IBAction)loginBtnClicked:(id)sender;
- (IBAction)forgetPwdBthClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *phoneNum;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (strong, nonatomic) NSString *pno;
@property (strong, nonatomic) UserManager *userManager;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneNum.text = self.pno;
    self.phoneNum.delegate = self;
    self.password.delegate = self;
}

- (UserManager *)userManager
{
    if (!_userManager) {
        _userManager = [[UserManager alloc] init];
        _userManager.delegate = self;
    }
    return _userManager;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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

- (IBAction)loginBtnClicked:(id)sender {
    [self.view endEditing:YES];
    if (self.password.text.length == 0) {
        [Utility showHUDAlert:self.view content:@"请输入密码" type:TEXT duration:1.f useColor:nil];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.phoneNum.text.length && self.password.text.length) {
//        [self.userManager mobilePhoneLoginWithUserName:self.phoneNum.text password:self.password.text sender:self];
    }
}

- (IBAction)forgetPwdBthClicked:(id)sender {
    UIViewController *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:@"verifyCode"];
    nextVC.navigationItem.title = @"找回密码";
    
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)returnSuccess
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)returnFailed:(NSString *)message
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Utility showHUDAlert:self.view content:message type:TEXT duration:1.f useColor:nil];
}
@end
