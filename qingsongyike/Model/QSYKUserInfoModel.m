//
//  QSYKUserInfoModel.m
//  qingsongyike
//
//  Created by 苗慧宇 on 5/20/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKUserInfoModel.h"

@implementation QSYKTaskModel

@end

@implementation QSYKUserInfoModel

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"auth_key": @"authKey",
                                                       @"nick_name": @"nickName",
                                                       }];
}

@end
