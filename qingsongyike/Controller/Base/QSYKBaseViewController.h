//
//  QSYKBaseViewController.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSYKAdTableViewCell.h"
#import <GDTNativeAd.h>
#import "QSYKResourceInnerPageViewController.h"

@interface QSYKBaseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, GDTNativeAdDelegate>
@property (nonatomic) BOOL isRefresh;   // 标识页面是否正在进行下拉刷新操作
@property (nonatomic, copy) NSString *deletingResourceSid;  // 将要删除的资源的sid
@property (nonatomic, strong) NSIndexPath *deletingResourceIndexPath;  // 将要删除的资源的indexPath

@property (nonatomic, strong) NSMutableArray *cellTypeArray;
@property (nonatomic, strong) GDTNativeAd *gdtNativeAd;
@property (nonatomic, strong) NSMutableArray *adData;

- (void)showRemoteNotiResource:(NSNotification *)noti;

@end
