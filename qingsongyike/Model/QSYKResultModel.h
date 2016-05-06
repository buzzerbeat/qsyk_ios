//
//  QSYKResultModel.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/29/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface QSYKResultModel : JSONModel
@property (nonatomic) BOOL success;
@property (nonatomic, copy) NSString *msg;

@end
