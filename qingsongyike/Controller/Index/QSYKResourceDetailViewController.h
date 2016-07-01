//
//  QSYKResourceDetailViewController.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/25/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKBaseViewController.h"
@class GDTNativeAdData;

@interface QSYKResourceDetailViewController : QSYKBaseViewController
@property (nonatomic, copy) NSString *sid;  // 资源sid
@property (nonatomic) BOOL needScrollToPost;   // 需要在页面显示时定位到评论的位置
@property (nonatomic, strong) GDTNativeAdData *ad;

@end
