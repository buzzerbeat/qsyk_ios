//
//  QSYKUserModel.m
//  qingsongyike
//
//  Created by 苗慧宇 on 6/6/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKUserModel.h"

@implementation QSYKUserNameEditable

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"editable_time": @"editableTime"}];
}

@end

@implementation QSYKTaskModel

@end

@implementation QSYKUserModel

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"uid": @"userId",
                                                       @"nick_name": @"userName",
                                                       @"avatarSid": @"userAvatar",
                                                       @"sex": @"userSex",
                                                       @"birthday": @"userBirthday",
                                                       @"personal_sign": @"userBrief",
                                                       @"mobile": @"userMobile",
                                                       @"bindQq": @"isBindQq",
                                                       @"bindWeixin": @"isBindWeixin",
                                                       @"bindWeibo": @"isBindWeibo"
                                                       }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
