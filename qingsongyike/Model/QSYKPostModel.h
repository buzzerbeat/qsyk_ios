//
//  QSYKPostModel.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "QSYKReplyModel.h"

/*
 sid: "fL_UNGzsonW",
 content: "当兵的动你家祖坟了？",
 userName: "透明杜蕾斯",
 userAvatar: "u_j-Jg0Mwg0",
 dig: 8,
 createTimeElapsed: "3天前",
 createTime: 1464283090,
 floor: "10楼",
 reply: null
 */

@protocol QSYKPostModel
@end

@interface QSYKPostModel : JSONModel
@property (nonatomic, assign) int    dig;
@property (nonatomic, copy) NSString *sid;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userAvatar;
@property (nonatomic, copy) NSString *createTimeElapsed;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *floor;
@property (nonatomic, copy) NSString *reply;
@property (nonatomic) BOOL hasDigged;

@end
