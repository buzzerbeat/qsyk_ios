//
//  QSYKSharePopupView.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/27/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKSharePopupView.h"
#import <UMSocial.h>
#import "QSYKUMengManager.h"

typedef NS_ENUM(NSInteger, QZShareToPlatformType) {
    QZShareToWechatSession  = 701,
    QZShareToWechatTimeLine = 702,
    QZShareToQQ             = 703,
    QZShareToQzone          = 704
};

@interface QSYKSharePopupView() <UMSocialUIDelegate>
@property (weak, nonatomic) IBOutlet UIButton *shareToWechatTimeLineBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareToWechatSessionBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareToQqBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareToQzoneBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightCon;

@property (copy, nonatomic) NSString *platformType;

@end

@implementation QSYKSharePopupView

- (void)awakeFromNib {
    self.separatorViewHeightCon.constant = 1.0 / [[UIScreen mainScreen] scale];
}

- (IBAction)shareToThirdPlatform:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    switch (button.tag) {
        case 101:
            _platformType = UMShareToWechatTimeline;
            break;
        case 102:
            _platformType = UMShareToWechatSession;
            break;
        case 103:
            _platformType = UMShareToQQ;
            break;
        case 104:
            _platformType = UMShareToQzone;
            break;
        case 105:
            _platformType = UMShareToSina;
            break;
            
        default:
            break;
    }
    
    self.dismissPopupBlock();
    
    // 请求分享接口
    // 请求成功后调用beginSharing方法
    [self beginSharing];
    
}

- (IBAction)cancleAction:(id)sender {
    self.dismissPopupBlock();
}

- (void)beginSharing {
    if ([_platformType isEqualToString:UMShareToSina]) {
        //设置分享内容和回调对象
        [[UMSocialControllerService defaultControllerService] setShareText:[NSString stringWithFormat:@"%@%@", _shareContent, _shareURL]
                                                                shareImage:[UIImage imageNamed:@"AppIcon_512"] socialUIDelegate:self];
        [UMSocialSnsPlatformManager getSocialPlatformWithName:
         UMShareToSina].snsClickHandler(_target,[UMSocialControllerService defaultControllerService],YES);
        
        return;
    }
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [[QSYKUMengManager shardManager] shareToThirdPlatformWithType:_platformType
                                                          title:self.shareTitle
                                                            url:self.shareURL
                                                        content:self.shareContent
                                                            image:[UIImage imageNamed:@"AppIcon_60"]
                                                       location:nil
                                                    urlResource:self.shareURLResource
                                            presentedController:_target
                                                        success:^{
                                                            [SVProgressHUD showSuccessWithStatus:@"分享成功"];
                                                        }
                                                        failure:^(NSInteger responseCode) {
                                                            if (responseCode == UMSResponseCodeCancel) {
                                                                [SVProgressHUD showErrorWithStatus:@"已取消"];
                                                            } else {
                                                                [SVProgressHUD showErrorWithStatus:@"分享失败"];
                                                            }
                                                        }];
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {
//    UIViewController *viewController = (UIViewController *)self.delegate;
    
    if (response.responseCode == UMSResponseCodeSuccess) {
        [SVProgressHUD showSuccessWithStatus:@"分享成功"];
    } else if (response.responseCode == UMSResponseCodeCancel) {
        [SVProgressHUD showErrorWithStatus:@"已取消"];
    }else {
        [SVProgressHUD showErrorWithStatus:@"分享失败"];
    }
}

- (IBAction)copyResourceAction:(id)sender {
    UIPasteboard *pastboard = [UIPasteboard generalPasteboard];
    pastboard.string = _shareURL;
    [self showHUDWithString:@"复制成功"];
}

- (IBAction)collectResourceAction:(id)sender {
    
}

- (IBAction)reportResourceAction:(id)sender {
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                             URLString:@"http://c.appcq.cn/resource/report" parameters:@{@"sid" : _resourceSid}
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   NSError *error = nil;
                                                   QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:&error];
                                                   if (error) {
                                                       NSLog(@"error = %@", error);
                                                   } else if (result.success) {
                                                       [self showHUDWithString:@"举报成功"];
                                                   }
                                               } failure:^(NSError *error) {
                                                   [self showHUDWithString:@"举报失败"];
                                               }];
}

- (void)showHUDWithString:(NSString *)string {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setCornerRadius:5.f];
    [SVProgressHUD showImage:nil status:string];
    self.dismissPopupBlock();
}

@end
