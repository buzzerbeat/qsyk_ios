//
//  QSYKDataManager.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKDataManager.h"

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

@end
