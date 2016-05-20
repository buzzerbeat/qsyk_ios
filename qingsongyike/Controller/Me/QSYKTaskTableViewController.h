//
//  QSYKTaskTableViewController.h
//  qingsongyike
//
//  Created by 苗慧宇 on 5/20/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QSYKTaskTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *taskList;

- (instancetype)initWithTaskList:(NSArray *)taskList;

@end
