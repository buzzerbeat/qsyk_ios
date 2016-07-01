//
//  QSYKAdModel.h
//  qingsongyike
//
//  Created by 苗慧宇 on 6/27/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface QSYKAdModel : JSONModel
@property (nonatomic, copy) NSString *banner;   // banner URL
@property (nonatomic, copy) NSString *logo;     // logo URL
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *link;     // 点击后跳转链接
@property (nonatomic, copy) NSString *action;   // 按钮title

@end
