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

@interface QSYKSharePopupView() <UMSocialUIDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIButton *shareToWechatTimeLineBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareToWechatSessionBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareToQqBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareToQzoneBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightCon;

@property (copy, nonatomic) NSString *platformType;
@property (nonatomic, copy) NSString *platformBrief;

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
            _platformBrief = @"group";
            break;
            
        case 102:
            _platformType = UMShareToWechatSession;
            _platformBrief = @"weixin";
            break;
            
        case 103:
            _platformType = UMShareToQQ;
            _platformBrief = @"qq";
            break;
            
        case 104:
            _platformType = UMShareToQzone;
            _platformBrief = @"qzone";
            break;
            
        case 105:
            _platformType = UMShareToSina;
            _platformBrief = @"weibo";
            break;
            
        default:
            break;
    }
    
    if (button.tag == 102 || button.tag == 103 || button.tag == 104) {
        self.shareTitle = @"轻松一刻";
    } else {
        self.shareContent = [NSString stringWithFormat:@"轻松一刻：%@", self.shareContent];
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
    
    // 分享到微博
    if ([_platformType isEqualToString:UMShareToSina]) {
        /*
        // sina 分享字数限制小于140，需要截取文字（"轻松一刻："前缀占5个字符，还需要把URL长度算进去）
        int maxLength = 140 - 3 - 5 - (int)_shareURL.length;
        if (_shareContent.length > maxLength) {
            // x = 140 - 3（"..."） - 5（"轻松一刻："）- shareURL.length
            NSString *newContent = [_shareContent substringWithRange:NSMakeRange(0, maxLength)];
            _shareContent = [NSString stringWithFormat:@"%@...%@", newContent, _shareURL];
        } else {
            _shareContent = [NSString stringWithFormat:@"%@%@", _shareContent, _shareURL];
        }*/
        
        _shareContent = [NSString stringWithFormat:@"%@%@", _shareContent, _shareURL];
        
        //设置分享内容和回调对象
        [[UMSocialControllerService defaultControllerService]
                             setShareText:_shareContent
                               shareImage:self.shareImage//[UIImage imageNamed:@"AppIcon_512"]
                         socialUIDelegate:self];
        
        [UMSocialSnsPlatformManager getSocialPlatformWithName:
         UMShareToSina].snsClickHandler(_target,[UMSocialControllerService defaultControllerService],YES);
        
        return;
    }
    
    
    [[QSYKUMengManager shardManager] shareToThirdPlatformWithType:_platformType
                                          title:self.shareTitle
                                            url:self.shareURL
                                        content:self.shareContent
                                            image:self.shareImage
                                       location:nil
                                    urlResource:self.shareURLResource
                            presentedController:_target
                                        success:^{
                                            [SVProgressHUD showSuccessWithStatus:@"分享成功"];
                                            [self shareSuccess];
                                        }
                                        failure:^(NSInteger responseCode) {
                                            if (responseCode == UMSResponseCodeCancel) {
                                                [SVProgressHUD showErrorWithStatus:@"已取消"];
                                            } else {
                                                [SVProgressHUD showErrorWithStatus:@"分享失败"];
                                            }
                                        }];
}

// sina 分享回掉
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {
//    UIViewController *viewController = (UIViewController *)self.delegate;
    
    if (response.responseCode == UMSResponseCodeSuccess) {
        [SVProgressHUD showSuccessWithStatus:@"分享成功"];
        [self shareSuccess];
        
    } else if (response.responseCode == UMSResponseCodeCancel) {
        [SVProgressHUD showErrorWithStatus:@"已取消"];
        
    }else {
        [SVProgressHUD showErrorWithStatus:@"分享失败"];
    }
}

- (void)shareSuccess {
    // 完成分享任务（请求分享任务接口）
    [[QSYKDataManager sharedManager]requestWithMethod:QSYKHTTPMethodPOST
                                            URLString:@"user/share-task"
                                           parameters:nil
                                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:kUserInfoChangedNotification object:nil];
                                              }
                                              failure:^(NSError *error) {
                                                  
                                              }];
    
    // 发送分享日志
    [[QSYKDataManager sharedManager] sendLogWithURLString:[NSString stringWithFormat:@"%@/share/r/%@/p/%@", kLogBaseURL, _resourceSid, _platformBrief]];
}

- (IBAction)copyResourceAction:(id)sender {
    UIPasteboard *pastboard = [UIPasteboard generalPasteboard];
    pastboard.string = _shareURL;
    [self showHUDWithString:@"复制成功"];
}

- (IBAction)collectResourceAction:(id)sender {
    self.dismissPopupBlock();
    
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                             URLString:@"resource/fav"
                                            parameters:@{@"sid": _resourceSid}
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   NSError *error = nil;
                                                   QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:&error];
                                                   if (error) {
                                                       NSLog(@"error = %@", error);
                                                   } else if (!result.status) {
                                                       [self showHUDWithString:@"收藏成功"];
                                                   } else {
                                                       [self showHUDWithString:result.message];
                                                   }
                                               }
                                               failure:^(NSError *error) {
                                                   [self showHUDWithString:@"收藏失败"];
                                                   NSLog(@"error = %@", error);
                                               }];
}

- (IBAction)reportResourceAction:(id)sender {
    self.dismissPopupBlock();
    
    if (SYSTEM_VERSION >= 8.0) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:@"举报" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [actionSheet addAction:cancleAction];
        
        // 广告
        UIAlertAction *adAction = [UIAlertAction actionWithTitle:@"广告" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self submitReportWithType:0];
        }];
        [actionSheet addAction:adAction];
        
        // 辱骂
        UIAlertAction *abuseAction = [UIAlertAction actionWithTitle:@"辱骂" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self submitReportWithType:1];
        }];
        [actionSheet addAction:abuseAction];
        
        // 色情
        UIAlertAction *eroticAction = [UIAlertAction actionWithTitle:@"色情" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self submitReportWithType:2];
        }];
        [actionSheet addAction:eroticAction];
        
        if (!(kIsIphone)) {
            actionSheet.popoverPresentationController.permittedArrowDirections = NO;
            actionSheet.popoverPresentationController.sourceView = _target.view;
            actionSheet.popoverPresentationController.sourceRect = _target.view.bounds;
        }
        [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:actionSheet animated:YES completion:nil];
        
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"举报" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"广告", @"辱骂", @"色情", nil];
        
        if (kIsIphone) {
            [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        } else {
            [actionSheet showFromRect:_target.view.frame inView:_target.view animated:YES];
        }
    }
    
    
}

- (void)submitReportWithType:(NSInteger)type {
    // 0广告，1辱骂，2色情
    NSLog(@"sid=%@,type=%ld", _resourceSid, (long)type);
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                             URLString:@"resource/report"
                                            parameters:@{
                                                         @"sid": _resourceSid,
                                                         @"type": @(type)
                                                         }
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   NSError *error = nil;
                                                   QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:&error];
                                                   if (error) {
                                                       NSLog(@"error = %@", error);
                                                   } else if (!result.status) {
                                                       [self showHUDWithString:@"举报成功"];
                                                   } else {
                                                       [self showHUDWithString:result.message];
                                                   }
                                               } failure:^(NSError *error) {
                                                   [self showHUDWithString:@"举报失败"];
                                                   NSLog(@"error = %@", error);
                                               }];
}

- (void)showHUDWithString:(NSString *)string {
    [SVProgressHUD showImage:nil status:string];
    self.dismissPopupBlock();
}

#pragma mark UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // ‘取消’操作的index=3，
    if (buttonIndex < 3) {
        [self submitReportWithType:buttonIndex - 1];
    }
}

@end
