//
//  UIViewController+IsVisible.m
//  qingsongyike
//
//  Created by 苗慧宇 on 6/1/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "UIViewController+IsVisible.h"

@implementation UIViewController (IsVisible)

- (BOOL)isVisible {
    return (self.isViewLoaded && self.view.window);
}

@end
