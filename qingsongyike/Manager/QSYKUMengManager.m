//
//  QSYKUMengManager.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/27/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKUMengManager.h"
#import <UMSocial.h>
#import <MobClick.h>
#import <UMSocialQQHandler.h>
#import <UMSocialWechatHandler.h>
#import <UMSocialSinaSSOHandler.h>

@implementation QSYKUMengManager

+ (QSYKUMengManager *)shardManager
{
    static QSYKUMengManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QSYKUMengManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [UMSocialConfig setFinishToastIsHidden:YES position:UMSocialiToastPositionCenter];
                
        // 友盟统计
        [MobClick startWithAppkey:@"55bb3a8367e58e30200011db"
                     reportPolicy:BATCH
                        channelId:@""];
        
        // 友盟分享
        //设置AppKey
        [UMSocialData setAppKey:@"55bb3a8367e58e30200011db"];
        
        //微信
        [UMSocialWechatHandler setWXAppId:@"wxe464ebb9bc216fb8"
                                appSecret:@"b49d599eef6cdfa2fa4ee03b709da3fe"
                                      url:nil];
        
        //QQ
        [UMSocialQQHandler setQQWithAppId:@"1104808816"
                                   appKey:@"Vyv6jpGWrd2rcAEp"
                                      url:nil];
        
        //sina
        [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"3412541166"
                                                  secret:@"c5dcd0ec1ad00c42a4ce950aba66e10c"
                                             RedirectURL:@"http://sns.whalecloud.com"];
    }
    
    return self;
}

- (void)shareToThirdPlatformWithType:(NSString *)platformName
                               title:(NSString *)title
                                 url:(NSString *)url
                             content:(NSString *)content
                               image:(id)image
                            location:(CLLocation *)location
                         urlResource:(UMSocialUrlResource *)urlResource
                 presentedController:(UIViewController *)presentedController
                             success:(void (^)(void))succuess
                             failure:(void (^)(NSInteger responseCode))failure {
    
    if ([platformName isEqualToString:UMShareToWechatTimeline]) {
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = url;
        [UMSocialData defaultData].extConfig.wechatTimelineData.title = title;
        
    } else if ([platformName isEqualToString:UMShareToWechatSession]) {
        [UMSocialData defaultData].extConfig.wechatSessionData.url = url;
        [UMSocialData defaultData].extConfig.wechatSessionData.title = title;
        
    } else if ([platformName isEqualToString:UMShareToQQ]) {
        [UMSocialData defaultData].extConfig.qqData.url = url;
        [UMSocialData defaultData].extConfig.qqData.title = title;
        [UMSocialQQHandler setQQWithAppId:@"1104808816" appKey:@"Vyv6jpGWrd2rcAEp" url:url];
        
    } else if ([platformName isEqualToString:UMShareToQzone]) {
        [UMSocialData defaultData].extConfig.qzoneData.url = url;
        [UMSocialData defaultData].extConfig.qzoneData.title = title;
        [UMSocialQQHandler setQQWithAppId:@"1104808816" appKey:@"Vyv6jpGWrd2rcAEp" url:url];
        
    }
    
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[platformName]
                                                        content:content
                                                          image:image
                                                       location:location
                                                    urlResource:urlResource
                                            presentedController:presentedController
                                                     completion:^(UMSocialResponseEntity *shareResponse){
                                                         if (shareResponse.responseCode == UMSResponseCodeSuccess) {
                                                             succuess();
                                                         } else {
                                                             failure(shareResponse.responseCode);
                                                         }
                                                     }];
    
}

@end
