//
//  QZCompleteUserInfoViewController.h
//  quiz
//
//  Created by 苗慧宇 on 3/8/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "BaseViewController.h"

@interface QZCompleteUserInfoViewController : BaseViewController

@property (nonatomic, copy) NSString *mobileNum;

@property (assign, nonatomic) BOOL isThirdLogin;
@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *oid;
@property (copy, nonatomic) NSString *avatarURL;
@property (copy, nonatomic) NSString *type;

@end
