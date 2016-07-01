//
//  QSYKTagPageHeaderView.m
//  qingsongyike
//
//  Created by 苗慧宇 on 6/23/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKTagPageHeaderView.h"
#import "QSYKBaseNavigationController.h"
#import "QZRegisterViewController.h"
#import "QSYKTagModel.h"

@implementation QSYKTagPageHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    self.separatorHeightCon.constant = ONE_PIX;
    self.attentionBtn.layer.cornerRadius = 3.f;
    self.attentionBtn.layer.masksToBounds = YES;
    
    self.imageView.layer.cornerRadius = 5.f;
    self.imageView.layer.masksToBounds = YES;
}

- (void)setup {
//- (void)layoutSubviews {
//    [super layoutSubviews];
    if (!_tagModel) {
        return;
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@人已关注", _tagModel.focusCount];
    NSURL *url = [NSURL URLWithString:[QSYKUtility imgUrl:_tagModel.logoSid width:120 height:120 extension:@"jpg"]];
    [self.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"AppIcon_180"]];
    
    if (_tagModel.isFocus) {
        [self.attentionBtn setImage:nil forState:UIControlStateNormal];
        [self.attentionBtn setTitle:@"取消关注" forState:UIControlStateNormal];
        self.attentionBtn.backgroundColor = [UIColor colorFromHexString:@"#e8e8e8"];
        
    } else {
        [self.attentionBtn setImage:[UIImage imageNamed:@"ico_follow"] forState:UIControlStateNormal];
        [self.attentionBtn setTitle:@" 关注" forState:UIControlStateNormal];
        self.attentionBtn.backgroundColor = kCoreColor;
    }
    
    self.height = [QSYKTagPageHeaderView viewBaseHeight];
    self.descLabel.text = nil;
    if (_tagModel.desc.length) {
        self.descLabel.text = _tagModel.desc;
        self.height  += [QSYKUtility heightForMutilLineLabel:_tagModel.desc font:14 width:SCREEN_WIDTH - 20];
    }
    
}

- (IBAction)attentionBtnClicked:(id)sender {
    QSYKUserModel *user = [QSYKUserManager sharedManager].user;
    if (!user || !user.isLogin) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(focusActionWithUrl:) name:kLoginSuccessNotification object:nil];
        
        // 未登录时弹出登录界面
        QZRegisterViewController *registerView = [[QZRegisterViewController alloc] initWithNibName:@"QZRegisterViewController" bundle:nil];
        QSYKBaseNavigationController *nav = [[QSYKBaseNavigationController alloc] initWithRootViewController:registerView];
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
    } else {
        [self focusActionWithUrl:@"/tag/follow"];
    }
}

- (void)focusActionWithUrl:(NSString *)url {
    url = _tagModel.isFocus ? @"/tag/unfollow" : @"/tag/follow";
    NSString *successMsg = _tagModel.isFocus ? @"已取消" : @"关注成功";
    NSString *failedMsg = _tagModel.isFocus ? @"取消失败" : @"关注失败";
        
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                             URLString:url
                                            parameters:@{@"tag": _tagModel.sid}
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                   if (result && !result.status) {
                                                       [SVProgressHUD showSuccessWithStatus:successMsg];
                                                       
                                                       [[NSNotificationCenter defaultCenter] postNotificationName:kFocusedTagsChangedNotification object:nil];
                                                   } else {
                                                       [SVProgressHUD showErrorWithStatus:failedMsg];
                                                   }
                                               }
                                               failure:^(NSError *error) {
                                                   [SVProgressHUD showErrorWithStatus:@"failedMsg"];
                                               }];
}

+ (CGFloat)viewBaseHeight {
    return 70;
}

@end
