//
//  QSYKResourceManager.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QSYKResourceModel;

@interface QSYKResourceManager : NSObject

+ (QSYKResourceManager *)sharedManager;

- (NSURLSessionDataTask *)getResourceWithParameters:(NSDictionary *)parameters
                                            success:(void (^)(NSArray<QSYKResourceModel *> *resourceList))success
                                            failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getResourceDetailWithParameters:(NSDictionary *)parameters
                                                  success:(void (^)(QSYKResourceModel *resource))success
                                                  failure:(void (^)(NSError *error))failure;

@end
