//
//  QZResetPasswordViewController.m
//  quiz
//
//  Created by subo on 15/12/30.
//  Copyright © 2015年 subo. All rights reserved.
//

#import "QZResetPasswordViewController.h"
#import "QZLoginViewController.h"

@interface QZResetPasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UIImageView *visibilityImageView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIButton *completionBtn;

@end

@implementation QZResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"重设密码";
    
//    self.backView.layer.borderColor = kSeparatorLightGrayColor.CGColor;
    self.backView.layer.borderWidth = 1.f;
    self.backView.layer.cornerRadius = 3.f;
    self.completionBtn.layer.cornerRadius = 3.f;
    
    self.visibilityImageView.userInteractionEnabled = YES;
    [self.visibilityImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeTextFieldSecureState:)]];
}

- (void)changeTextFieldSecureState:(id)sender {
    _pwdTextField.secureTextEntry = !_pwdTextField.secureTextEntry;
    
    if (_pwdTextField.isSecureTextEntry) {
        _visibilityImageView.image = [UIImage imageNamed:@"login_visibility_on"];
    } else {
        _visibilityImageView.image = [UIImage imageNamed:@"login_visibility_off"];
    }
}

//- (IBAction)completion:(id)sender {
//    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    @weakify(self);
//    [[UserManager shardManager] resetPasswordWithPhoneNumber:self.pno newPassword:self.pwdTextField.text success:^{
//        @strongify(self);
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        [Utility showHUDAlert:self.view content:@"修改成功" type:TEXT duration:1.5f useColor:nil];
//        
//        [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(gotoLoginPage) userInfo:nil repeats:NO];
//        
//    } failure:^(NSError *error) {
//        @strongify(self);
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        [Utility showHUDTextAlert:self.view content:@"修改失败"];
//    }];
//}

- (void)gotoLoginPage {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc class] == [QZLoginViewController class]) {
            [self.navigationController popToViewController:vc animated:NO];
            break;
        }
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
