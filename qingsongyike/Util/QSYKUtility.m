//
//  QSYKUtility.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKUtility.h"
#import "SSKeychain.h"
#import "LYTopWindow.h"
#import "QSYKTopWindow.h"

@implementation QSYKUtility

+ (NSString *)imgUrl:(NSString *)sid width:(int)width height:(int)height extension:(NSString *)extension
{
    return [NSString stringWithFormat:@"%@img/show/sid/%@/w/%d/h/%d/t/1/show.%@", kPictureBaseURL, sid, width, height, extension];
}

+ (NSString *)imgUrl:(NSString *)sid {
    return [NSString stringWithFormat:@"%@img/show/sid/%@/w//h//t/1/show.png", kPictureBaseURL, sid];
}

+ (CGFloat)heightForMutilLineLabel:(NSString *)string font:(CGFloat)fontSize width:(CGFloat)width {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:TEXT_LING_SPACING];
    
    CGSize titleSize = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{
                                                      NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                                      NSParagraphStyleAttributeName : paragraphStyle}
                                            context:nil].size;
    
    return ceil(titleSize.height);
}

+ (UIAlertController *)alertControllerWithTitle:(NSString *)title
                                        message:(NSString *)message
                              cancleActionTitle:(NSString *)cancleActionTitle
                                  goActionTitle:(NSString *)goActionTitle
                                 preferredStyle:(UIAlertControllerStyle)preferredStyle
                                        handler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    
    if (cancleActionTitle.length) {
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:cancleActionTitle style:UIAlertActionStyleCancel handler:nil];
        [alertView addAction:cancleAction];
    }
    
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:goActionTitle style:UIAlertActionStyleDefault handler:handler];
    [alertView addAction:createAction];
    
    return alertView;
}

+ (NSString *)mid {
    NSString *mid = [SSKeychain passwordForService:@"MID" account:@"qingsongyike"];
    if (!mid) {
        mid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:mid forService:@"MID" account:@"qingsongyike"];
    }
    
    return mid;
}

+ (NSString *)UAString {
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *mid = [QSYKUtility mid];
    
    return [NSString stringWithFormat:@"%@ iOS v%@ mid:%@", appName, version, mid];
}

+ (void)startApp {
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
                                             URLString:[NSString stringWithFormat:@"%@/user/sign-task", kAuthBaseURL]
                                            parameters:nil
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:kUserInfoChangedNotification object:nil];
                                               }
                                               failure:^(NSError *error) {
                                                   
                                               }];
}

+ (void)rateResourceWithSid:(NSString *)sid type:(NSInteger)type {
    NSString *URLStr = type == 1 ? @"/resource/like" : @"/resource/hate";
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                 URLString:[NSString stringWithFormat:@"%@/%@", kAuthBaseURL, URLStr]
                                                parameters:@{
                                                             @"sid" : sid,
                                                             }
                                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                                       QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                       
                                                       if (result && !result.status) {
                                                           NSLog(@"评价成功");
                                                       }
                                                       
                                                   } failure:^(NSError *error) {
                                                       NSLog(@"评价失败  %@", error);
                                                   }];
}

+ (void)loadSplash {
    
    NSString *device = [UIDevice currentDevice].model;
    NSString *sysver = [UIDevice currentDevice].systemVersion;
    NSString *urlStr = [NSString stringWithFormat:@"%@/splash?device=%@&sysver=%@", kAuthBaseURL, device, sysver];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSLog(@"splash URL = %@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:[QSYKUtility UAString] forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"GET"];
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(concurrentQueue, ^{
        
        // 1.请求加密的数据
        NSURLResponse *response;
        NSError *encodeError = nil;
        NSData *encodedData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&encodeError];
        
        if (encodeError) {
            // Deal with your error
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                NSLog(@"HTTP Error: %ld %@", (long)httpResponse.statusCode, encodeError);
                return;
            }
            NSLog(@"Error %@", encodeError);
            return;
        }
        
//        NSString *responeString = [[NSString alloc] initWithData:encodedData
//                                                        encoding:NSUTF8StringEncoding];

        
        // 2.解码数据
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedData:encodedData options:0];
        
        // 3.把解密后的数据转换为字典类型
        NSError *parseError = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:decodedData options:0 error:&parseError];
        NSLog(@"dic = %@", dic);
        
        // 提取开关设置
        BOOL lotteryEnable = [dic[@"config"][@"lotteryEnable"] boolValue];
        BOOL beautyEnable  = [dic[@"config"][@"beautyEnable"] boolValue];
        
        // 存到本地
        [[NSUserDefaults standardUserDefaults] setBool:lotteryEnable forKey:@"lotteryEnable"];
        [[NSUserDefaults standardUserDefaults] setBool:beautyEnable forKey:@"beautyEnable"];
        BOOL saveSuccess = [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"saveSuccess = %d", saveSuccess);
    });
    
    /*
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
                                             URLString:[NSString stringWithFormat:@"%@/splash", kAuthBaseURL]
                                            parameters:nil
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   NSData *decodedData = [[NSData alloc] initWithBase64EncodedData:responseObject options:0];
                                                   NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:decodedData options:0 error:nil];
                                                   NSLog(@"dic = %@", dic);
                                               }
                                               failure:^(NSError *error) {
                                                   
                                               }];
     */
}

// 隐藏topWindow
+ (void)hideTopWindow {
    if (SYSTEM_VERSION >= 8.0) {
        [LYTopWindow sharedTopWindow].hidden = YES;
    } else {
        [QSYKTopWindow hide];
    }
}

// 显示topWindow
+ (void)showTopWindow {
    if (SYSTEM_VERSION >= 8.0) {
        [LYTopWindow sharedTopWindow].hidden = NO;
    } else {
        [QSYKTopWindow show];
    }
}

@end
