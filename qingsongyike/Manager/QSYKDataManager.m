//
//  QSYKDataManager.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKDataManager.h"
#import "QSYKResultModel.h"
#import "QSYKError.h"
#import "QZRegisterViewController.h"
#import "QSYKBaseNavigationController.h"

@interface QSYKDataManager()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation QSYKDataManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
        self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        self.manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        [self.manager.requestSerializer setValue:[QSYKUtility UAString] forHTTPHeaderField:@"User-Agent"];
    }
    return self;
}

+ (QSYKDataManager *)sharedManager {
    static QSYKDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QSYKDataManager alloc] init];
    });
    return instance;
}

- (NSURLSessionDataTask *)requestWithMethod:(QSYKHTTPMethod)method
                                  URLString:(NSString *)URLString
                                 parameters:(NSDictionary *)parameters
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSError *error))failure {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURLSessionDataTask *task = nil;
    
    // reset token
    NSString *token = kAccessToken;//@"qOGaqaWIMS8BLvkWOAr3f4MR5WwfJskV";
    NSString *finalToken = (token.length ? token : kToken);
    [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", finalToken] forHTTPHeaderField:@"Authorization"];
    NSLog(@"token = %@", finalToken);
    
    NSMutableDictionary *tempDic = parameters ? [parameters mutableCopy] : [NSMutableDictionary dictionary];
    NSString *timestemp = [NSString stringWithFormat:@"%ld", (long)TIMESTEMP];
    [tempDic setObject:timestemp forKey:@"zzz"];
    parameters = [tempDic copy];
    NSLog(@"****** parameters = %@", parameters);
    
    if (method == QSYKHTTPMethodGET) {
         NSLog(@"***** urlRequest Url = %@ Method = %@ param = %@ *****", URLString, @"GET", parameters);
        
        task = [self.manager GET:URLString
                      parameters:parameters
                        progress:nil
                         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                             success(task, responseObject);
                             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                         }
                         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                             failure(error);
                             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                         }];
    } else if (method == QSYKHTTPMethodPOST) {
        task = [self.manager POST:URLString
                       parameters:parameters
                         progress:nil
                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                              success(task, responseObject);
                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                          }
                          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                              failure(error);
                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                          }];
    }
    
    return task;
}

- (void)registerAction {
    
    NSLog(@"UUID = %@", UUID);
    [self requestWithMethod:QSYKHTTPMethodPOST
                  URLString:@"user/register"
                 parameters:@{@"uuid": UUID}
                    success:^(NSURLSessionDataTask *task, id responseObject) {
                        
                        NSError *error = nil;
                        QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:&error];
                        if (result && !result.status) {
                            // 注册成功后把返回的token保存到本地
                            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                            [userDefaults setObject:result.user[@"auth_key"] forKey:@"token"];
                            [userDefaults synchronize];
                            
                            [[QSYKDataManager sharedManager] startApp];
                        }
                    } failure:^(NSError *error) {
                        NSLog(@"error = %@", error);
                    }];
}

- (void)checkToken {
    NSString *token = kAccessToken;
    NSString *finalToken = (token.length ? token : kToken);
    NSDictionary *parameters = @{
                                 @"client": CLIENT_ID,
                                 @"token": finalToken ?: @"",
                                 };
    
    [self requestWithMethod:QSYKHTTPMethodGET
                  URLString:@"/v2/user/token-check"
                 parameters:parameters
                    success:^(NSURLSessionDataTask *task, id responseObject) {
                        
                        NSError *error = nil;
                        QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:&error];
                        if (result && result.status == 1) {
                            //token已过期
                            QSYKUserModel *user = [QSYKUserManager sharedManager].user;
                            
                            // 如果是已登录用户，则清空登录信息并弹出登录界面
                            if (user.isLogin) {
                                [QSYKUserManager sharedManager].user = nil;
                                
                                QZRegisterViewController *registerView = [[QZRegisterViewController alloc] initWithNibName:@"QZRegisterViewController" bundle:nil];
                                QSYKBaseNavigationController *nav = [[QSYKBaseNavigationController alloc] initWithRootViewController:registerView];
                                
                                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
                            } else {
                                [self registerAction];
                            }
                        }
                    } failure:^(NSError *error) {
                        NSLog(@"error = %@", error);
                    }];
}

- (void)sendLogWithURLString:(NSString *)URLString {
    [self requestWithMethod:QSYKHTTPMethodPOST URLString:URLString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {} failure:^(NSError *error) {}];
}


- (NSURLSessionDataTask *)mobileInitWithURLString:(NSString *)URLString
                                       parameters:(NSDictionary *)parameters
                                          success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                          failure:(void (^)(NSError *error))failure {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSMutableDictionary *tempDic = parameters ? [parameters mutableCopy] : [NSMutableDictionary dictionary];
    NSString *timestemp = [NSString stringWithFormat:@"%ld", (long)TIMESTEMP];
    [tempDic setObject:timestemp forKey:@"zzz"];
    parameters = [tempDic copy];
    NSLog(@"parameters = %@", parameters);
    
    NSURLSessionDataTask *task = [self.manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        success(task, responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        failure(error);
    }];
    
    return task;
}

- (NSURLSessionDataTask *)requestWithMethod:(QSYKHTTPMethod)method
                                  URLString:(NSString *)URLString
                                 uploadData:(NSData *)uploadData
                                 parameters:(NSDictionary *)parameters
                                    success:(void (^)(NSURLSessionDataTask * task, id responseObject))success
                                    failure:(void (^)(NSError *error))failure {
    // stateBar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    void (^responseSuccessHandleBlock)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        success(task, responseObject);
        
    };
    
    void (^responseFailureHandleBlock)(NSError * _Nonnull error) = ^(NSError * _Nonnull error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        failure(error);
        
    };
    
    // Create HTTPSession
    NSURLSessionDataTask *uploadTask = nil;

    // reset token
    NSString *token = kAccessToken;
    [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", (token.length ? token : kToken)] forHTTPHeaderField:@"Authorization"];
    NSLog(@"token = %@", kToken);
    
    NSMutableDictionary *tempDic = parameters ? [parameters mutableCopy] : [NSMutableDictionary dictionary];
    NSString *timestemp = [NSString stringWithFormat:@"%ld", (long)TIMESTEMP];
    [tempDic setObject:timestemp forKey:@"zzz"];
    parameters = [tempDic copy];
    NSLog(@"parameters = %@", parameters);
    
    uploadTask = [self.manager POST:URLString parameters:parameters
          constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
              //                  [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"avatar" fileName:@"avatar.png" mimeType:@"image/jpeg" error:nil];
              [formData appendPartWithFileData:uploadData name:@"avatarFile" fileName:@"avatar.png" mimeType:@"image/png"];
          }
                           progress:nil
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                responseSuccessHandleBlock(task, responseObject);
                            }
                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                responseFailureHandleBlock(error);
                            }];
    
    [uploadTask resume];
    
    return uploadTask;
}

- (void)ratePostWithSid:(NSString *)sid {
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                             URLString:[NSString stringWithFormat:@"/post/like?sid=%@", sid]
                                            parameters:nil
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                   
                                                   if (result && !result.status) {
                                                       NSLog(@"评价成功");
                                                   }
                                                   
                                               } failure:^(NSError *error) {
                                                   NSLog(@"评价失败  %@", error);
                                               }];
}

- (void)rateResourceWithSid:(NSString *)sid type:(NSInteger)type {
    NSString *URLStr = type == 1 ? @"/resource/like" : @"/resource/hate";
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                             URLString:URLStr
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

- (void)deleteResourceWithSid:(NSString *)sid type:(NSInteger)type {
    NSString *urlStr = [NSString stringWithFormat:@"%@/logdomain/videoPlay/r/%@/t/%d", kLogBaseURL, sid, type];
    NSLog(@"delete resource log's url = %@", urlStr);
    
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                             URLString:urlStr
                                            parameters:nil
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   
                                                   NSLog(@"反馈成功");
                                                   
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteComplete" object:nil];
                                                   
                                               } failure:^(NSError *error) {
                                                   NSLog(@"反馈失败  %@", error);
                                               }];
}

- (void)startApp {
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
                                             URLString:@"user/sign-task"
                                            parameters:nil
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:kUserInfoChangedNotification object:nil];
                                               }
                                               failure:^(NSError *error) {
                                                   
                                               }];
}

@end
