//
//  QSYKDataManager.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef NS_ENUM(NSInteger, QSYKHTTPMethod) {
    QSYKHTTPMethodGET  = 1,
    QSYKHTTPMethodPOST = 2,
    
};

@interface QSYKDataManager : NSObject

+ (QSYKDataManager *)sharedManager;

- (NSURLSessionDataTask *)requestWithMethod:(QSYKHTTPMethod)method
                                  URLString:(NSString *)URLString
                                 parameters:(NSDictionary *)parameters
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSError *error))failure;

- (void)checkToken;
- (void)registerAction;

/**
 * 发送日志
 */
- (void)sendLogWithURLString:(NSString *)URLString;


- (NSURLSessionDataTask *)mobileInitWithURLString:(NSString *)URLString
                                       parameters:(NSDictionary *)parameters
                                          success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                          failure:(void (^)(NSError *error))failure;


- (NSURLSessionDataTask *)requestWithMethod:(QSYKHTTPMethod)method
                                  URLString:(NSString *)URLString
                                 uploadData:(NSData *)uploadData
                                 parameters:(NSDictionary *)parameters
                                    success:(void (^)(NSURLSessionDataTask * task, id responseObject))success
                                    failure:(void (^)(NSError *error))failure;


- (void)startApp;
- (void)ratePostWithSid:(NSString *)sid;
- (void)rateResourceWithSid:(NSString *)sid type:(NSInteger)type;



@end
