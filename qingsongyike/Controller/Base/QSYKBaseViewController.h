//
//  QSYKBaseViewController.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QSYKBaseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property (nonatomic) BOOL isRefresh;   // 标识页面是否正在进行下拉刷新操作
@property (nonatomic, copy) NSString *deletingResourceSid;  // 将要删除的资源的sid
@property (nonatomic, strong) NSIndexPath *deletingResourceIndexPath;  // 将要删除的资源的indexPath

- (void)showRemoteNotiResource:(NSNotification *)noti;

@end
