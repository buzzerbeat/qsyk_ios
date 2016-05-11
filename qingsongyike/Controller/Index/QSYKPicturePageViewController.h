//
//  QSYKPicturePageViewController.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKBaseViewController.h"

@interface QSYKPicturePageViewController : QSYKBaseViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) BOOL isDynamic;

@end
