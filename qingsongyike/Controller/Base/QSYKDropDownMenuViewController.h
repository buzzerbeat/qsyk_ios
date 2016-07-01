//
//  QSYKDropDownMenuViewController.h
//  qingsongyike
//
//  Created by 苗慧宇 on 6/28/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QSYKTagModel;

@interface QSYKDropDownMenuViewController : UITableViewController
@property (nonatomic, strong) QSYKTagGroupModel *dataSource;
@property (nonatomic, copy) void (^selectTagBlock) (QSYKTagModel *tag);

@end
