//
//  QSYKPostModel.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "QSYKReplyModel.h"

@interface QSYKPostModel : JSONModel
@property (nonatomic, strong) NSArray<QSYKReplyModel *> *list;
@property (nonatomic, strong) NSArray<QSYKReplyModel *> *hot;
@property (nonatomic, assign) NSInteger      total;

@end
