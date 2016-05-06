//
//  QSYKReplyModel.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKReplyModel.h"

@implementation QSYKReplyModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"pub_timestamp" : @"pubTimestamp",
                                                       @"pub_time" : @"pubTime",
                                                       @"reply_user" : @"reply_user",
                                                       @"reply_content" : @"replyContent",
                                                       @"reply_username" : @"replyUsername",
                                                       @"res_sid" : @"resSid",
                                                       }];
}

@end
