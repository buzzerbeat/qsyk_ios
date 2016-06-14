//
//  QSYKUserModel.h
//  qingsongyike
//
//  Created by 苗慧宇 on 6/6/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface QSYKUserNameEditable : JSONModel
@property (nonatomic) BOOL editable;
@property (nonatomic, copy) NSString *editableTime;

@end

@protocol QSYKTaskModel
@end

@interface QSYKTaskModel : JSONModel
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) int current;
@property (nonatomic, assign) int total;

@end

@interface QSYKUserModel : JSONModel
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userAvatar;
@property (nonatomic, strong) NSString *userBirthday;
@property (nonatomic, strong) NSString *userBrief;
@property (nonatomic, strong) NSString *userMobile;

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, copy) NSString *auth_key;
@property (nonatomic, assign) int points;
@property (nonatomic, strong) QSYKUserNameEditable *nameEditable;
@property (nonatomic, strong) NSArray<QSYKTaskModel> *taskList;

@property (nonatomic, assign) int userSex;
@property (nonatomic, assign) BOOL isBindWeixin;
@property (nonatomic, assign) BOOL isBindQq;
@property (nonatomic, assign) BOOL isBindWeibo;


@property (nonatomic, assign) int unReadMsgNum;

@property (assign, nonatomic) int unFinishTaskNum;

@property (nonatomic, assign, getter=isLogin) BOOL login;

@end
