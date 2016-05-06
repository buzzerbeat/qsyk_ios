//
//  QSYKResourceDetailViewController.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/25/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKBaseViewController.h"

@interface QSYKResourceDetailViewController : QSYKBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *sid;  // 资源sid
@property (nonatomic, assign) NSInteger type;

@end
