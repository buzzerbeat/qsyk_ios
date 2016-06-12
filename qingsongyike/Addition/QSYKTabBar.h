//
//  QSYKTabBar.h
//  qingsongyike
//
//  Created by 苗慧宇 on 6/1/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark 因为在UITabBar中已经声明过一个UITabBarDelegate协议，
#pragma mark 我们若想新增一个对外的代理函数，可以让我们自定义的协议继承自UITabBarDelegate，添加一个扩展函数。

@class QSYKTabBar;

@protocol QSYKTabBarDelegate <UITabBarDelegate>

@optional
- (void)tabBarDidClickMiddleButton:(QSYKTabBar *)tabBar;

@end

@interface QSYKTabBar : UITabBar
@property (nonatomic, weak) id<QSYKTabBarDelegate> tabBarDelegate;

@end
