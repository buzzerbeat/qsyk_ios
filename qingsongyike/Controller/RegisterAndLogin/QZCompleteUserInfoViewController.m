//
//  QZCompleteUserInfoViewController.m
//  quiz
//
//  Created by 苗慧宇 on 3/8/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QZCompleteUserInfoViewController.h"
#import "CustomPickerView.h"
#import "CustomDatePickView.h"
#import "QZRootTabViewController.h"
#import "MyHeadImageViewController.h"

@interface QZCompleteUserInfoViewController () <CustomDatePickViewDelegate, CustomPickerViewDelegate, MyHeadImageDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIView *sexView;
@property (weak, nonatomic) IBOutlet UIView *birthdayView;
@property (weak, nonatomic) IBOutlet UITextField *sexTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UIButton *completeBtn;
@property (weak, nonatomic) IBOutlet UIView *nickNameView;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sexViewTopCon;

@property (nonatomic, strong) CustomDatePickView *customDatePickView;
@property (nonatomic, strong) CustomPickerView *customPickerView;
@property (nonatomic, strong) NSArray *genderTypesArray;
@property (nonatomic, assign) NSInteger selectedSex;
@property (nonatomic, assign) NSTimeInterval selectedTimeInterval;
@property (nonatomic, strong) QZUserModel *user;
@property (nonatomic, strong) MyHeadImageViewController *setAvatarVC;
@property (nonatomic, strong) NSData *avatarData;
@property (nonatomic) BOOL flag;

@end

@implementation QZCompleteUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;

    _completeBtn.layer.cornerRadius = _completeBtn.height / 2;
    _avatarImageView.layer.cornerRadius = _avatarImageView.height / 2;
    _avatarImageView.userInteractionEnabled = YES;
    [_avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setAvatar:)]];
    
    [_sexView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectSexAction:)]];
    [_birthdayView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBirthdayAction:)]];
    
    self.user = [UserManager shardManager].user;
    self.genderTypesArray = @[@"保密", @"男", @"女"];
    self.selectedTimeInterval = -1;
    self.selectedSex = -1;
    
    [_nickNameTextField addTarget:self action:@selector(checkUserNameExist:) forControlEvents:UIControlEventEditingDidEndOnExit | UIControlEventEditingDidEnd];
    
    if (self.avatarURL) {
        self.avatarData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.avatarURL]];
        self.avatarImageView.image = [UIImage imageWithData:self.avatarData];
    }
    if (self.userName) {
        self.nickNameTextField.text = self.userName;
    }
    if (!self.isThirdLogin) {
        self.sexViewTopCon.constant = 40.f;
        self.nickNameView.hidden = YES;
    }
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardDidShow:(NSNotification *)noti {
    if (!_flag) {
        [UIView animateKeyframesWithDuration:0.3f delay:0.f options:0 animations:^{
            self.view.y -= 130;
        } completion:nil];
    }
    _flag = YES;
}

- (void)keyboardWillHide:(NSNotification *)noti {
    if (_flag) {
        [UIView animateKeyframesWithDuration:0.3f delay:0.f options:0 animations:^{
            self.view.y += 130;
        } completion:nil];
    }
    _flag = NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// 判断当前昵称是否可用
- (void)checkUserNameExist:(id)sender {
    
    [[UserManager shardManager] checkUserNameExistenceWithUserName:_nickNameTextField.text
                                                           success:^{
                                                               [Utility showHUDAlert:self.view content:@"昵称可用" type:TEXT duration:1.5f useColor:nil];
                                                           }
                                                           failure:^(NSError *error) {
                                                               // 当前昵称不可用
                                                               [Utility showHUDAlert:self.view content:error.userInfo[@"QZError"] type:TEXT duration:1.f useColor:nil];
                                                           }];
}

- (CustomDatePickView *)customDatePickView {
    if (!_customDatePickView) {
        _customDatePickView = [CustomDatePickView loadFromXib];
        _customDatePickView.datePicker.maximumDate = [NSDate date];
        _customDatePickView.delegate = self;
    }
    
    return _customDatePickView;
}

- (CustomPickerView *)customPickerView {
    if (!_customPickerView) {
        _customPickerView = [[CustomPickerView alloc] initWithTitileName:@"" dataArray:_genderTypesArray delegate:self];
    }
    
    return _customPickerView;
}

- (void)selectSexAction:(id)sender {
    
    [self.customPickerView.myPickerView selectRow:_selectedSex inComponent:0 animated:NO];
    [self.customPickerView showInView:self.view.superview];
}

- (void)selectBirthdayAction:(id)sender {
    if (_selectedTimeInterval != -1) {
        self.customDatePickView.datePicker.date = [NSDate dateWithTimeIntervalSince1970:_selectedTimeInterval];
    } else {
        self.customDatePickView.datePicker.date = [NSDate date];
    }
    [self.customDatePickView showInView:self.view.superview];
}

- (IBAction)completeBtnClicked:(id)sender {
    @weakify(self);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (self.isThirdLogin) {
        
        [[UserManager shardManager] registerWithThirdPartyOid:self.oid
                                                         type:self.type
                                                         name:self.nickNameTextField.text
                                                          sex:0
                                                     birthday:nil
                                                   avatarData:self.avatarData
         
                                                      success:^(QZUserModel *userModel) {
                                                          @strongify(self);
                                                          [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                          
                                                          [UserManager shardManager].user = userModel;
                                                          
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil];
                                                          
                                                          [Utility showHUDAlert:self.view content:@"注册成功" type:TEXT duration:1.5f useColor:nil];
                                                          [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(gotoMainViewControllerAction) userInfo:nil repeats:NO];
                                                          
                                                      } failure:^(NSError *error) {
                                                          @strongify(self);
                                                          [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                          NSLog(@"error %@", error);
                                                          
                                                          [Utility showHUDAlert:self.view content:error.userInfo[@"QZError"] type:TEXT duration:1.5f useColor:nil];
                                                      }];
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        if (_selectedTimeInterval != -1) {
            [parameters setObject:@(_selectedTimeInterval) forKey:@"birthday"];
        }
        if (_selectedSex != -1) {
            [parameters setObject:@(_selectedSex) forKey:@"sex"];
        }
        
        [[QZDataManager sharedManager] requestWithMethod:QZRequestMethodHTTPPOSTUID URLString:@"user/editProfile" parameters:parameters
                                                 success:^(NSURLSessionDataTask *task, id responseObject) {
                                                     
                                                     @strongify(self);
                                                     [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                     
                                                     ResultModel *result = [[ResultModel alloc] initWithDictionary:responseObject error:nil];
                                                     if (result && !result.status) {
                                                         
                                                         _user.userBirthday = [NSString stringWithFormat:@"%f", _selectedTimeInterval];
                                                         _user.userSex = @(_selectedSex).intValue;
                                                         
                                                         [UserManager shardManager].user = _user;
                                                         
                                                         [Utility showHUDAlert:self.view content:@"设置成功" type:TEXT duration:1.5f useColor:nil];
                                                         [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(gotoMainViewControllerAction) userInfo:nil repeats:NO];
                                                         
                                                     } else {
                                                         [Utility showHUDAlert:self.view content:result.message type:TEXT duration:1.5f useColor:nil];
                                                     }
                                                     
                                                 } failure:^(NSError *error) {
                                                     @strongify(self);
                                                     [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                     [Utility showHUDAlert:self.view content:@"设置失败" type:TEXT duration:1.5f useColor:nil];
                                                 }];
    }
}

// 设置头像
- (void)setAvatar:(UITapGestureRecognizer *)gesture
{
    self.setAvatarVC = [[MyHeadImageViewController alloc] initWithTarget:self];
    [self presentViewController:self.setAvatarVC.actionSheet animated:YES completion:^{}];
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
    self.avatarData = [NSData dataWithContentsOfFile:filePath];
    
    [self deleteLocalAvatar:filePath];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    @weakify(self);
    [[QZDataManager sharedManager] requestWithMethod:QZRequestMethodHTTPPOSTUID
                                           URLString:@"user/mobileAvatarUpload"
                                          uploadData:_avatarData
                                          parameters:nil
                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                 @strongify(self);
                                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                 ResultModel *result = [[ResultModel alloc] initWithDictionary:responseObject error:nil];
                                                 
                                                 if (result && !result.status) {
                                                     [Utility showHUDAlert:self.view content:@"上传头像成功" type:TEXT duration:1.5f useColor:nil];
                                                     
                                                     _user.userAvatar = result.data[@"avatar"];
                                                     [UserManager shardManager].user = _user;
                                                     
                                                     // 刷新当前页的头像
                                                     [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[Utility imgUrl:_user.userAvatar width:120 height:120]] placeholderImage:[UIImage imageNamed:@"icon_avatar"]];
                                                     
                                                     // 通知myPageViewController 刷新的头像
                                                     [[NSNotificationCenter defaultCenter] postNotificationName:kAvatarDidChangedNotification
                                                                                                         object:@{
                                                                                                                  @"avatar": _user.userAvatar
                                                                                                                  }];
                                                 } else {
                                                     [Utility showHUDAlert:self.view content:result.message type:TEXT duration:1.5f useColor:nil];
                                                 }
                                             } failure:^(NSError *error) {
                                                 @strongify(self);
                                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                 [Utility showHUDAlert:self.view content:@"上传头像失败" type:TEXT duration:1.5f useColor:nil];
                                             }];
}


#pragma mark - CustomPickerView Delegate and DataSource

- (void)pickerDidSelected:(NSInteger)index customPickerView:(CustomPickerView *)customPickerView {
//    [self updateProfileWithKey:@"sex" value:[NSString stringWithFormat:@"%ld", (long)index]];
    switch (index) {
        case 0:
            _sexTextField.text = @"保密";
            break;
        case 1:
            _sexTextField.text = @"男";
            break;
        case 2:
            _sexTextField.text = @"女";
            break;
            
        default:
            break;
    }
}

#pragma mark - CustomDatePickDelegate

-(void)datePickerSelected:(NSTimeInterval)timeInterval {
    self.selectedTimeInterval = timeInterval;
//    [self updateProfileWithKey:@"birthday" value:[NSString stringWithFormat:@"%.f", timeInterval]];
    _birthdayTextField.text = [Utility formateBirthdayWithTimeInterval:[NSString stringWithFormat:@"%.f", timeInterval]];
}

#pragma mark delete local avatar file

- (void)deleteLocalAvatar:(NSString *)filePath {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL success = [fileManager fileExistsAtPath:filePath];
    if(success) {
        success = [fileManager removeItemAtPath:filePath error:nil];
    }
}

- (void)updateProfileWithKey:(NSString *)key value:(NSString *)value {
    
    NSDictionary *params = @{key: value};
    NSLog(@"%@", params);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    @weakify(self);
    [[QZDataManager sharedManager] requestWithMethod:QZRequestMethodHTTPPOSTUID URLString:@"user/editProfile" parameters:params
                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                 
                                                 @strongify(self);
                                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                 
                                                 ResultModel *result = [[ResultModel alloc] initWithDictionary:responseObject error:nil];
                                                 if (result && !result.status) {
                                                     
                                                     if ([key isEqualToString:@"sex"]) {
                                                         _user.userSex = [value intValue];
                                                         
                                                         switch (_user.userSex) {
                                                             case 0:
                                                                 _sexTextField.text = @"保密";
                                                                 break;
                                                             case 1:
                                                                 _sexTextField.text = @"男";
                                                                 break;
                                                             case 2:
                                                                 _sexTextField.text = @"女";
                                                                 break;
                                                                 
                                                             default:
                                                                 break;
                                                         }
                                                         
                                                     } else {
                                                         _user.userBirthday = value;
                                                         
                                                         _birthdayTextField.text = [Utility formateBirthdayWithTimeInterval:_user.userBirthday];
                                                     }
                                                     [UserManager shardManager].user = _user;
                                                     
                                                     [Utility showHUDAlert:self.view content:@"设置成功" type:TEXT duration:1.5f useColor:nil];
                                                     
                                                 } else {
                                                     [Utility showHUDAlert:self.view content:result.message type:TEXT duration:1.5f useColor:nil];
                                                 }
                                                 
                                             } failure:^(NSError *error) {
                                                 @strongify(self);
                                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                 [Utility showHUDAlert:self.view content:@"设置失败" type:TEXT duration:1.5f useColor:nil];
                                             }];
}

- (void)gotoMainViewControllerAction {
    [UIApplication sharedApplication].keyWindow.rootViewController = [[QZRootTabViewController alloc] init];
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
