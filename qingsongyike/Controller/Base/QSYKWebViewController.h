//
//  QSYKWebViewController.h
//  qingsongyike
//
//  Created by 苗慧宇 on 6/1/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKBaseViewController.h"

@interface QSYKWebViewController : QSYKBaseViewController
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *navTitle;

- (instancetype)initWithTitle:(NSString *)title url:(NSString *)url;

@end
