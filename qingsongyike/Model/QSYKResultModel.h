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

// register 接口返回字段
@property (nonatomic, assign) int status;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSDictionary *user;   // "auth_key": "token"

@end
