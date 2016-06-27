//
//  QSYKMyFavoriteTableViewController.h
//  qingsongyike
//
//  Created by 苗慧宇 on 5/16/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKBaseViewController.h"
@class QSYKTagModel;

@interface QSYKMyFavoriteTableViewController : QSYKBaseViewController
@property (nonatomic, copy) NSString *URLStr;
@property (nonatomic) BOOL isReadHistory;   // 标识是否显示最近浏览内容
@property (nonatomic, strong) QSYKTagModel *tag;       // 标签信息

@end
