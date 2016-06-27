//
//  QSYKTagModel.m
//  qingsongyike
//
//  Created by 苗慧宇 on 6/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKTagModel.h"

@implementation QSYKTagModel

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"is_show" : @"isShow",
                                                       }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end
