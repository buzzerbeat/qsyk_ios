//
//  QSYKRefreshFooter.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/25/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>

@interface QSYKRefreshFooter : MJRefreshAutoFooter

+ (instancetype)footerWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock;

@end
