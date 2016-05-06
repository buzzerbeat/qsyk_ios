//
//  QSYKRefreshFooter.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/25/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKRefreshFooter.h"

@implementation QSYKRefreshFooter

- (instancetype)init {
    self = [super init];
    if (self) {
        self.triggerAutomaticallyRefreshPercent = -10.f;
    }
    return self;
}

+ (instancetype)footerWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock {
    MJRefreshFooter *cmp = [[self alloc] init];
    cmp.refreshingBlock = refreshingBlock;
    return cmp;
}

@end
