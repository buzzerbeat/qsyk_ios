//
//  QSYKFavoriteResourceModel.m
//  qingsongyike
//
//  Created by 苗慧宇 on 5/16/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKFavoriteResourceModel.h"

@implementation QSYKFavoriteResourceModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation QSYKFavoriteModel

@end

@implementation QSYKFavoriteResourceList

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        NSMutableArray *tmpArray = [NSMutableArray new];
        for (NSDictionary *dic in array) {
            NSError *error = nil;
            QSYKFavoriteModel *resource = [[QSYKFavoriteModel alloc] initWithDictionary:dic error:&error];
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
