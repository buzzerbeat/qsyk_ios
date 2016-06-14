//
//  QSYKError.h
//  qingsongyike
//
//  Created by 苗慧宇 on 6/6/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const DOMAIN_NAME;

@interface QSYKError : NSObject

typedef NS_ENUM(NSInteger, QSYKErrorType) {
    
    QSYKErrorTypeNoDEf          = 600,
    QSYKErrorTypeLoginFailure   = 601,
    QSYKErrorTypeNoFoundUserLoginFailure = 602,
    QSYKErrorTypeRegisterFailure = 603,
    QSYKErrorTypeNoLoginFailure = 604,
    QSYKErrorTypeRequestVerifyCodeFailure = 605,
    QSYKErrorTypeVerifyCodeWrongFailure = 606,
    QSYKErrorTypeThirdLoginFailure = 607,
    QSYKErrorTypeThirdNoRegisterFailure = 608,
    QSYKErrorTypeResetPasswordFailure = 609,
    QSYKErrorTypeRefreshVerifyCodeFailure = 610,
    QSYKErrorTypeMobileNoRegisterFailure = 611,
    QSYKErrorTypeExpireFailure = 612,
    QSYKErrorTypeParameterIllegalFailure = 613,
    QSYKErrorTypeUserNameNotExistFailure = 614,
    QSYKErrorTypeValidateRegisterFailure = 615,
};

@end
