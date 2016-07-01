//
//  QSYKResourceInnerPageViewController.h
//  qingsongyike
//
//  Created by 苗慧宇 on 6/16/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKBaseViewController.h"

@protocol QSYKInnerPageDelegate;

@interface QSYKResourceInnerPageViewController : UIViewController
@property (nonatomic, strong) NSArray *resources;
@property (nonatomic, strong) NSArray *ads;
@property (nonatomic, assign) NSUInteger curIndex;  // 当前显示该页第几个资源
@property (nonatomic) BOOL needScrollToPost;   // 需要在页面显示时定位到评论的位置

@property (nonatomic, weak) id<QSYKInnerPageDelegate> delegate;

@end

@protocol QSYKInnerPageDelegate <NSObject>

- (void)tableViewScrollToIndex:(NSInteger)index;

@end