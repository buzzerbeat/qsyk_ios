//
//  QSYKEditSignViewController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 6/12/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKEditSignViewController.h"

static int PERSONAL_SIGN_LENGTH = 30;

@interface QSYKEditSignViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *signTextView;
@property (weak, nonatomic) IBOutlet UILabel *charCountLabel;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *separatorHeightCons;

@end

@implementation QSYKEditSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"个性签名";
    
    for (NSLayoutConstraint *con in self.separatorHeightCons) {
        con.constant = 1.0 / [UIScreen mainScreen].scale;
    }
    
    self.signTextView.text = self.propertyOldValue;
    [self.signTextView becomeFirstResponder];
    self.charCountLabel.text = [NSString stringWithFormat:@"%lu", PERSONAL_SIGN_LENGTH - self.signTextView.text.length];
    
    UIButton *completeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    completeBtn.frame = CGRectMake(0, 0, 30, 30);
    [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(editComplete:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:completeBtn];
}

- (void)textViewDidChange:(UITextView *)textView {
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position) {
        if (textView.text.length > PERSONAL_SIGN_LENGTH) {
            textView.text = [textView.text substringToIndex:PERSONAL_SIGN_LENGTH];
        }
    }
    self.charCountLabel.text = [NSString stringWithFormat:@"%lu", PERSONAL_SIGN_LENGTH - textView.text.length];
}

- (void)editComplete:(id)sender
{
    // 如果编辑后的内容没有改变，则不提交到server
    if (![self.signTextView.text isEqualToString:self.propertyOldValue]) {
        
        [SVProgressHUD show];
        
        @weakify(self);
        [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                 URLString:@"/v2/user/edit"
                                                parameters:@{@"personal_sign": self.signTextView.text}
                                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                                       @strongify(self);
                                                       
                                                       QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                       if (result && !result.status) {
                                                           [SVProgressHUD showSuccessWithStatus:@"设置成功"];
                                                           
                                                           QSYKUserModel *tempModel = [QSYKUserManager sharedManager].user;
                                                           
                                                           tempModel.userBrief = self.signTextView.text;
                                                           [QSYKUserManager sharedManager].user = tempModel;
                                                           [[NSNotificationCenter defaultCenter] postNotificationName:kEditProfileNotification object:@{@"key": @"sign"}];
                                                           
                                                           [self.navigationController popViewControllerAnimated:YES];
                                                           
                                                       } else {
                                                           [SVProgressHUD showErrorWithStatus:result.message];
                                                       }
                                                       
                                                   }
                                                   failure:^(NSError *error) {
                                                       NSLog(@"error = %@", error);
                                                       [SVProgressHUD showErrorWithStatus:@"设置失败"];
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
