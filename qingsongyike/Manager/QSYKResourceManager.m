//
//  QSYKResourceManager.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKResourceManager.h"
#import "QSYKResourceModel.h"

@implementation QSYKResourceManager

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (QSYKResourceManager *)sharedManager {
    static QSYKResourceManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QSYKResourceManager alloc] init];
    });
    return instance;
}

- (NSURLSessionDataTask *)getResourceWithParameters:(NSDictionary *)parameters
                        success:(void (^)(NSArray<QSYKResourceModel *> *resourceList, NSURLSessionDataTask *task))success
                        failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *mDic = [parameters mutableCopy];
    [mDic setObject:@"godPosts,tags" forKey:@"expand"];
    [mDic setObject:@40 forKey:@"per-page"];
    
    return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
                                                    URLString:@"resources"
                                                   parameters:mDic
                                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                                          
                                                          QSYKResourceList *resourceList = [[QSYKResourceList alloc]
                                                                                         initWithArray:responseObject];
                                                          success(resourceList.list, task);
                                                      }
                                                      failure:^(NSError *error) {
                                                          failure(error);
                                                      }];
}

- (NSURLSessionDataTask *)getResourceDetailWithParameters:(NSDictionary *)parameters
                                            success:(void (^)(QSYKResourceModel *resource))success
                                            failure:(void (^)(NSError *error))failure {
    
    NSString *sid = parameters[@"sid"];
    NSString *expand = @"expand=hotPosts,posts,godPosts,tags";
    NSString *urlStr = [NSString stringWithFormat:@"resources/%@?%@", sid, expand];
    return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
                                                    URLString:urlStr
                                                   parameters:nil
                                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                                          
                                                          NSError *error = nil;
                                                          QSYKResourceModel *resource = [[QSYKResourceModel alloc] initWithDictionary:responseObject error:&error];
                                                          
                                                          success(resource);
                                                      }
                                                      failure:^(NSError *error) {
                                                          failure(error);
                                                      }];
}

@end
