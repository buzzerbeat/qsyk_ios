//
//  QSYKUserInfoModel.h
//  qingsongyike
//
//  Created by 苗慧宇 on 5/20/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol QSYKTaskModel
@end

@interface QSYKTaskModel : JSONModel
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) int current;
@property (nonatomic, assign) int total;

@end

@interface QSYKUserInfoModel : JSONModel
@property (nonatomic, assign) int points;
@property (nonatomic, copy  ) NSString *authKey;
@property (nonatomic, copy  ) NSString<Optional> *nickName;
@property (nonatomic, strong) NSArray<QSYKTaskModel, Optional> *taskList;

@end
