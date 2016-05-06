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
                                            success:(void (^)(NSArray<QSYKResourceModel *> *resourceList))success
                                            failure:(void (^)(NSError *error))failure {
    
    return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
                                                    URLString:@"resource/listJson/"
                                                   parameters:parameters
                                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                                          
                                                          QSYKResourceList *resourceList = [[QSYKResourceList alloc]
                                                                                         initWithArray:responseObject];
                                                          success(resourceList.list);
                                                      }
                                                      failure:^(NSError *error) {
                                                          failure(error);
                                                      }];
}

- (NSURLSessionDataTask *)getResourceDetailWithParameters:(NSDictionary *)parameters
                                            success:(void (^)(QSYKResourceModel *resource))success
                                            failure:(void (^)(NSError *error))failure {
    
    return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
                                                    URLString:@"resource/detailJson/"
                                                   parameters:parameters
                                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                                          QSYKResourceModel *resource = [[QSYKResourceModel alloc] initWithDictionary:responseObject error:nil];
                                                          
                                                          success(resource);
                                                      }
                                                      failure:^(NSError *error) {
                                                          failure(error);
                                                      }];
}

@end
