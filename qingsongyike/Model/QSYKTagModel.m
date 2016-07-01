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


@implementation QSYKTagGroupModel

@end


@implementation QSYKTagList

- (instancetype)initWithArray:(NSArray *)array {
    if (array.count) {
        NSMutableArray *tmpArr = [NSMutableArray new];
        
        for (NSDictionary *dic in array) {
            NSError *error = nil;
            QSYKTagModel *tag = [[QSYKTagModel alloc] initWithDictionary:dic error:&error];
            if (!error) {
                [tmpArr addObject:tag];
            } else {
                NSLog(@"QSYKTagModel 生成失败");
            }
        }
        
        self.list = [tmpArr copy];
        return self;
    }
    
    return nil;
}

@end
