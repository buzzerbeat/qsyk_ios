//
//  QSYKPostModel.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKPostModel.h"

@implementation QSYKPostModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"hasDigged"] ||
        [propertyName isEqualToString:@"reply"]) {
        return YES;
    }
    
    return NO;
}

@end

