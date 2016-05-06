//
//  QSYKReplyModel.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface QSYKReplyModel : JSONModel
@property (nonatomic, copy  ) NSString  *sid;
@property (nonatomic, copy  ) NSString  *content;
@property (nonatomic, copy  ) NSString  *user;          // 被评论用户的sid
@property (nonatomic, copy  ) NSString  *username;      // 被评论的用户名
@property (nonatomic, copy  ) NSString  *avatar;
@property (nonatomic, assign) NSInteger dig;
@property (nonatomic, copy  ) NSString  *pubTimeStamp;
@property (nonatomic, copy  ) NSString  *pubTime;
@property (nonatomic, copy  ) NSString  *floor;
@property (nonatomic, copy  ) NSString  *reply;
@property (nonatomic, copy  ) NSString  *replyUser;     // 回复者用户sid
@property (nonatomic, copy  ) NSString  *replyContent;  // 回复内容
@property (nonatomic, copy  ) NSString  *replyUsername; // 回复者用户名
@property (nonatomic, copy  ) NSString  *start;         // 分页使用
@property (nonatomic, copy  ) NSString  *resSid;        // 回复资源sid

@end
