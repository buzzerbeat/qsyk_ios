//
//  QSYKDataManager.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKDataManager.h"
#import "QSYKResultModel.h"

@interface QSYKDataManager()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation QSYKDataManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
        self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//        [self.manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
//        [self.manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"text/raw", @"application/json", @"text/json", @"text/javascript", nil]];
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
    
    if ([URLString hasPrefix:@"http://c2"]) {
        NSString *token = [self.manager.requestSerializer valueForHTTPHeaderField:@"Authorization"];
        if (token.length < 14) {
            [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", kToken] forHTTPHeaderField:@"Authorization"];
            NSLog(@"token = %@", kToken);
        }
    }
    
    NSURLSessionDataTask *task = nil;
    
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
                  URLString:[NSString stringWithFormat:@"%@/user/register", kAuthBaseURL]
                 parameters:@{@"uuid": UUID}
                    success:^(NSURLSessionDataTask *task, id responseObject) {
                        
                        NSError *error = nil;
                        QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:&error];
                        if (result && !result.status) {
                            // 注册成功后把返回的token保存到本地
                            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                            [userDefaults setValue:result.user[@"auth_key"] forKey:@"token"];
                            [userDefaults synchronize];
                            
                            [QSYKUtility startApp];
                        }
                    } failure:^(NSError *error) {
                        NSLog(@"error = %@", error);
                    }];
}

@end
