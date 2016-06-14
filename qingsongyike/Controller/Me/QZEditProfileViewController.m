//
//  QZEditProfileViewController.m
//  quiz
//
//  Created by subo on 15/12/29.
//  Copyright © 2015年 subo. All rights reserved.
//

#import "QZEditProfileViewController.h"

@interface QZEditProfileViewController () <UITextFieldDelegate>
{
    BOOL _isEdit;
}

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *separatorHeightCon;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (copy, nonatomic) NSString *propertyCurrentValue;

@end

@implementation QZEditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"昵称";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.textField.text = self.propertyOldValue;
    [self.textField becomeFirstResponder];
    
    for (NSLayoutConstraint *con in self.separatorHeightCon) {
        con.constant = 1.0 / [UIScreen mainScreen].scale;
    }
    
    // 显示名字是否可以修改的提示
    QSYKUserModel *user = [QSYKUserManager sharedManager].user;
    if (user.nameEditable.editable) {
        self.descLabel.text = @"当前可以修改";
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
        [dateFormatter setTimeZone:timeZone];
        NSString *timeStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[user.nameEditable.editableTime doubleValue]]];
        
        self.descLabel.text = [NSString stringWithFormat:@"需至%@后修改", timeStr];
    }
    
    UIButton *completeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    completeBtn.frame = CGRectMake(0, 0, 30, 30);
    [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(editComplete:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:completeBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:UITextFieldTextDidChangeNotification object:_textField];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    UITextRange *selectedRange = [textField markedTextRange];
    //获取高亮部分
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position) {
        
        if (toBeString.length < 3) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        } else if (toBeString.length > 10) {
            textField.text = [toBeString substringToIndex:10];
        }
    }
    // 有高亮选择的字符串，则暂不对文字进行统计和限制
    else{
        
    }
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    
//    NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    textField.text = updatedString;
//    
//    _isEdit = YES;
//    
//    // 修改昵称时如果新昵称长度小于3，提交按钮不可用
//    if ([self.toBeEditedPropertyName isEqualToString:@"name"] && updatedString.length < 3) {
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//    }else {
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    }
//    
//    return NO;
//}

- (BOOL)textFieldShouldClear:(UITextField *)textField {

    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    return YES;
}

- (void)editComplete:(id)sender
{
    // 如果编辑后的内容没有改变，则不提交到server
    if (![self.textField.text isEqualToString:self.propertyOldValue]) {
        
        // 更新信息到server
        [SVProgressHUD show];
        
        @weakify(self);
        [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                               URLString:@"/v2/user/edit"
                                              parameters:@{@"nick_name": self.textField.text}
                                                 success:^(NSURLSessionDataTask *task, id responseObject) {
                                                     @strongify(self);
                                                     
                                                     QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                     if (result && !result.status) {
                                                         [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                                                         
                                                         QSYKUserModel *tempModel = [QSYKUserManager sharedManager].user;
                                                         
                                                         tempModel.userName = self.textField.text;
                                                         [QSYKUserManager sharedManager].user = tempModel;
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:kEditProfileNotification object:@{@"key": @"name"}];
                                                         
                                                         [self.navigationController popViewControllerAnimated:YES];
                                                         
                                                     } else {
                                                         [SVProgressHUD showErrorWithStatus:result.message];
                                                     }
                                                     
                                                 }
                                                 failure:^(NSError *error) {
                                                     NSLog(@"error = %@", error);
                                                     [SVProgressHUD showErrorWithStatus:@"修改失败"];
                                                     // 提交失败后留在当前页还是返回
                                                 }];
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
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


