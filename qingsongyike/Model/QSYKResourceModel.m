//
//  QSYKResourceModel.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKResourceModel.h"

@implementation QSYKResourceModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation QSYKResourceList

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        NSMutableArray *tmpArray = [NSMutableArray new];
        for (NSDictionary *dic in array) {
            NSError *error = nil;
            QSYKResourceModel *resource = [[QSYKResourceModel alloc] initWithDictionary:dic error:&error];
            if (error) {
                NSLog(@"error = %@", error);
            } else {
                [tmpArray addObject:resource];
            }
        }
        
        self.list = [tmpArray copy];
    }
    return self;
}

@end


//+ (BOOL)propertyIsOptional:(NSString *)propertyName {
//    return YES;
//}
//
//+ (JSONKeyMapper *)keyMapper {
//    return [[JSONKeyMapper alloc] initWithDictionary:@{
//                                                       @"user_avatar" : @"userAvatar",
//                                                       @"pub_time" : @"pubTime",
//                                                       @"favorate" : @"favorite",
//                                                       @"user" : @"username"
//                                                       }];
//}
//
//@end
//
//@implementation QSYKResourceList
//
//- (instancetype)initWithArray:(NSArray *)array {
//    self = [super init];
//    NSMutableArray *tempArray = [NSMutableArray new];
//    for (NSDictionary *item in array) {
//        NSError *error = nil;
//        QSYKResourceModel *aResource = [[QSYKResourceModel alloc] initWithDictionary:item error:&error];
//        if (error) {
//            NSLog(@"error %@", error);
//        }
//        [tempArray addObject:aResource];
//    }
//    self.list = [tempArray copy];
//    
//    return self;
//}
//
//@end
