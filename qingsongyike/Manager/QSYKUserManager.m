//
//  UserManager.m
//  quiz
//
//  Created by Xin on 15/9/18.
//  Copyright (c) 2015年 subo. All rights reserved.
//

#import "QSYKUserManager.h"
#import "QSYKResultModel.h"
#import <UMSocial.h>
#import <UMSocialQQHandler.h>
#import <UMSocialWechatHandler.h>
#import "QSYKUserModel.h"
#import "QSYKError.h"

static NSString *const kUsername = @"userName";
static NSString *const kUserid = @"userId";
static NSString *const kAvatarSid = @"avatarSid";
static NSString *const kUserIsLogin = @"userIsLogin";



@implementation QSYKUserManager

+ (QSYKUserManager *)shardManager
{
    static QSYKUserManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QSYKUserManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserIsLogin] boolValue];
        if (isLogin) {
            QSYKUserModel *user = [[QSYKUserModel alloc] init];
            user.login = YES;
            user.userId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserid];
            user.userName = [[NSUserDefaults standardUserDefaults] objectForKey:kUsername];
            user.userAvatar = [[NSUserDefaults standardUserDefaults] objectForKey:kAvatarSid];
            _user = user;
        }
    }
    return self;
}

- (void)setUser:(QSYKUserModel *)user {
    _user = user;
    if (user) {
        self.user.login = YES;
        [[NSUserDefaults standardUserDefaults] setObject:user.userName forKey:kUsername];
        [[NSUserDefaults standardUserDefaults] setObject:user.userAvatar forKey:kAvatarSid];
        [[NSUserDefaults standardUserDefaults] setObject:user.auth_key forKey:@"auth_key"];
        [[NSUserDefaults standardUserDefaults] setObject:user.accessToken forKey:@"accessToken"];
        [[NSUserDefaults standardUserDefaults] setObject:user.refreshToken forKey:@"refreshToken"];
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserIsLogin];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUsername];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAvatarSid];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"auth_key"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"accessToken"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"refreshToken"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserIsLogin];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


#pragma mark Public Request Methods - Login & Profile

- (NSURLSessionDataTask *) loginWithMobileNum:(NSString *)mobileNum
                                     password:(NSString *)password
                                      success:(void (^)(QSYKUserModel *userModel))success
                                      failure:(void (^)(NSError *error))failure {
    
    /**
     mobile : 手机号
     password : 密码
     client : client id
     client_secret : client secret
     */
    NSDictionary *parameters = @{
                                 @"mobile": mobileNum,
                                 @"password": password,
                                 @"client": CLIENT_ID,
                                 @"client_secret": CLIENT_SECRET,
                                 };
    
    
    
    return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                  URLString:@"/v2/user/login"
                                                 parameters:parameters
                                                    success:^(NSURLSessionDataTask *task, id responseObject) {
                                                        QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                        if (result && !result.status) {
                                                            QSYKUserModel *userModel = [[QSYKUserModel alloc] initWithDictionary:result.user error:nil];
                                                            success(userModel);
                                                        } else {
                                                            NSError *error;
                                                            if (result.status == 1) {
                                                                error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeNoFoundUserLoginFailure userInfo:@{
                                                                                                                                                                       @"QSYKError":result.message
                                                                                                                                                                       }];
                                                            } else {
                                                                error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeLoginFailure userInfo:@{
                                                                                                                                                            @"QSYKError":result.message
                                                                                                                                                            }];
                                                                
                                                            }
                                                            failure(error);
                                                        }
                                                        
                                                    } failure:^(NSError *error) {
                                                        failure(error);
                                                    }];
}




- (NSURLSessionDataTask *) registerWithMobileNumber:(NSString *)mobileNumber
                                               name:(NSString *)name
                                           password:(NSString *)password
                                     avatarData:(NSData *)avatar
                                            success:(void (^)(QSYKUserModel *userModel))success
                                            failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameters = @{
                                 @"mobile": mobileNumber,
                                 @"nickname": name,
                                 @"password": password,
                                 @"client": CLIENT_ID,
                                 @"client_secret": CLIENT_SECRET,
                                 };
    
    if (avatar) {
        
        return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                      URLString:@"/v2/user/register"
                                                     uploadData:avatar
                                                     parameters:parameters
                                                        success:^(NSURLSessionDataTask *task, id responseObject) {
                                                            QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                            
                                                            if (result && !result.status) {
                                                                QSYKUserModel *userModel = [[QSYKUserModel alloc] initWithDictionary:result.user error:nil];
                                                                success(userModel);
                                                            } else {
                                                                NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeRegisterFailure userInfo:@{
                                                                                                                                                                        @"QSYKError":result.message
                                                                                                                                                                        }];
                                                                failure(error);
                                                            }
                                                        } failure:^(NSError *error) {
                                                            failure(error);
                                                        }];
    } else {
        
        return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                      URLString:@"/v2/user/register"
                                                     parameters:parameters
                                                        success:^(NSURLSessionDataTask *operation, id responseObject) {
                                                            
                                                            QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                            if (result && !result.status) {
                                                                QSYKUserModel *userModel = [[QSYKUserModel alloc] initWithDictionary:result.user error:nil];
                                                                success(userModel);
                                                            } else {
                                                                NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeRegisterFailure userInfo:@{
                                                                                                                                                                        @"QSYKError":result.message
                                                                                                                                                                        }];
                                                                failure(error);
                                                            }
                                                            
                                                        } failure:^(NSError *error) {
                                                            failure(error);
                                                        }];
    }
    
}

- (NSURLSessionDataTask *) registerWithThirdPartyOid:(NSString *)oid
                                                type:(NSString *)type
                                                name:(NSString *)name
                                          avatarData:(NSData *)avatar
                                             success:(void (^)(QSYKUserModel *userModel))success
                                             failure:(void (^)(NSError *error))failure {
    
    /**
     from : 值为qq，weixin，weibo
     oid : 第三方唯一标示
     client : client id
     client_secret : client secret
     nickname : 昵称，第三方请求的昵称
     avatarFile* : 上传头像文件
     avatar* : 上传头像url
     */
    
    NSMutableDictionary *parameters = [@{
                                        @"oid": oid,
                                        @"from": type,
                                        @"nickname": name,
                                        @"client": CLIENT_ID,
                                        @"client_secret": CLIENT_SECRET,
                                        } mutableCopy];
    
    if ([avatar isKindOfClass:[NSData class]]) {
        
        return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                        URLString:@"/v2/user/third-register"
                                                       uploadData:avatar
                                                       parameters:parameters
                                                          success:^(NSURLSessionDataTask *task, id responseObject) {
                                                              QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                              
                                                              if (result && !result.status) {
                                                                  QSYKUserModel *userModel = [[QSYKUserModel alloc] initWithDictionary:result.user error:nil];
                                                                  success(userModel);
                                                              } else {
                                                                  NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeRegisterFailure userInfo:@{
                                                                                                                                                                            @"QSYKError":result.message
                                                                                                                                                                            }];
                                                                  failure(error);
                                                              }
                                                          } failure:^(NSError *error) {
                                                              failure(error);
                                                          }];
    } else {
        [parameters setObject:avatar forKey:@"avatarFile"];
        
        return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                        URLString:@"/v2/user/third-register"
                                                       parameters:parameters
                                                          success:^(NSURLSessionDataTask *operation, id responseObject) {
                                                              
                                                              QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                              if (result && !result.status) {
                                                                  QSYKUserModel *userModel = [[QSYKUserModel alloc] initWithDictionary:result.user error:nil];
                                                                  success(userModel);
                                                              } else {
                                                                  NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeRegisterFailure userInfo:@{
                                                                                                                                                                            @"QSYKError":result.message
                                                                                                                                                                            }];
                                                                  failure(error);
                                                              }
                                                              
                                                          } failure:^(NSError *error) {
                                                              failure(error);
                                                          }];
    }
    
}


- (NSURLSessionDataTask *) requestVerifyCodeWithPhoneNumber:(NSString *)pno
                                                    success:(void (^)(void))success
                                                    failure:(void (^)(NSError *error))failure {
    
    
    return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                  URLString:@"/v2/user/request-code"
                                                   parameters:@{@"mobile": pno}
                                                    success:^(NSURLSessionDataTask *operation, id responseObject) {
                                                        QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                        if (result && !result.status) {
                                                            success();
                                                        } else {
                                                            NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeRegisterFailure userInfo:@{
                                                                                                                                                                    @"QSYKError":result.message
                                                                                                                                                                    }];
                                                            failure(error);
                                                        }
                                                        
                                                    } failure:^(NSError *error) {
                                                        failure(error);
                                                    }];
    
}

- (NSURLSessionDataTask *)loginWithThirdPartyOid:(NSString *)oid
                                            type:(NSString *)type
                                         success:(void (^)(QSYKUserModel *userModel))success
                                         failure:(void (^)(NSError *error))failure {
    
    /**
     from : 值为qq，weixin，weibo
     oid : 第三方唯一标示
     client : client id
     client_secret : client secret
     */
    
    NSDictionary *parameters = @{
                                 @"oid": oid,
                                 @"from": type,
                                 @"client": CLIENT_ID,
                                 @"client_secret": CLIENT_SECRET,
                                 
                                 };
    
    return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                  URLString:@"/v2/user/third-login"
                                                 parameters:parameters
                                                    success:^(NSURLSessionDataTask *operation, id responseObject) {
                                                        
                                                        QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                        if (result) {
                                                            if (result.status == 0) {
                                                                QSYKUserModel *userModel = [[QSYKUserModel alloc] initWithDictionary:result.user error:nil];
                                                                success(userModel);
                                                            } else if (result.status == 1) {
                                                                NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeThirdNoRegisterFailure userInfo:@{
                                                                                                                                                                               @"QSYKError":result.message
                                                                                                                                                                               }];
                                                                failure(error);
                                                                
                                                            } else {
                                                                NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeThirdLoginFailure userInfo:@{
                                                                                                                                                                          @"QSYKError":result.message
                                                                                                                                                                          }];
                                                                failure(error);
                                                                
                                                            }
                                                            
                                                        } else {
                                                            
                                                            NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeThirdLoginFailure userInfo:@{
                                                                                                                                                                      @"QSYKError":result.message
                                                                                                                                                                      }];
                                                            failure(error);
                                                        }
                                                        
                                                    } failure:^(NSError *error) {
                                                        failure(error);
                                                    }];
}

- (NSURLSessionDataTask *)verifyCodeCorrectWithPhoneNumber:(NSString *)mobileNumber
                                                verifyCode:(NSString *)verifyCode
                                                   success:(void (^)(void))success
                                                   failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameters = @{
                                 @"mobile": mobileNumber,
                                 @"code": verifyCode
                                 };
    
    return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                  URLString:@"/v2/user/verify-code"
                                                 parameters:parameters
                                                    success:^(NSURLSessionDataTask *operation, id responseObject) {
                                                        
                                                        QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                        if (result && !result.status) {
                                                            success();
                                                        } else {
                                                            NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeVerifyCodeWrongFailure userInfo:@{
                                                                                                                                                                      @"QSYKError":result.message
                                                                                                                                                                      }];
                                                            failure(error);
                                                        }
                                                        
                                                    } failure:^(NSError *error) {
                                                        failure(error);
                                                    }];
}

- (NSURLSessionDataTask *)forgotPasswordWithPhoneNumber:(NSString *)mobileNumber
                                                success:(void (^)(void))success
                                                failure:(void (^)(NSError *))failure {
    
    NSDictionary *parameters = @{
                                 @"mobile": mobileNumber
                                 };
    
    return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                  URLString:@"user/forgotPassword"
                                                 parameters:parameters
                                                    success:^(NSURLSessionDataTask *operation, id responseObject) {
                                                        
                                                        QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                        if (result) {
                                                            if (result.status == 0) {
                                                                success();
                                                            } else if (result.status == 1) {
                                                                NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeResetPasswordFailure userInfo:@{
                                                                                                                                                                             @"QSYKError":result.message
                                                                                                                                                                             }];
                                                                failure(error);
                                                            } else if (result.status == 2) {
                                                                NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeExpireFailure userInfo:@{
                                                                                                                                                                             @"QSYKError":result.message
                                                                                                                                                                             }];
                                                                failure(error);
                                                            } else if (result.status == -1) {
                                                                NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeParameterIllegalFailure userInfo:@{
                                                                                                                                                                             @"QSYKError":result.message
                                                                                                                                                                             }];
                                                                failure(error);
                                                            }
                                                            
                                                        } else {
                                                            NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeResetPasswordFailure userInfo:@{
                                                                                                                                                                         @"QSYKError":result.message
                                                                                                                                                                         }];
                                                            failure(error);
                                                        }
                                                        
                                                    } failure:^(NSError *error) {
                                                        failure(error);
                                                    }];
    
}

- (NSURLSessionDataTask *)refreshVerifyCodeStateWithPhoneNumber:(NSString *)mobileNumber
                                                        success:(void (^)(void))success
                                                        failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameters = @{
                                 @"mobile": mobileNumber
                                 };
    
    return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                  URLString:@"user/refreshVerifyCodeState"
                                                 parameters:parameters
                                                    success:^(NSURLSessionDataTask *operation, id responseObject) {
                                                        
                                                        QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                        if (result && !result.status) {
                                                            success();
                                                        } else {
                                                            NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeRefreshVerifyCodeFailure userInfo:@{
                                                                                                                                                                      @"QSYKError":result.message
                                                                                                                                                                      }];
                                                            failure(error);
                                                        }
                                                        
                                                    } failure:^(NSError *error) {
                                                        failure(error);
                                                    }];
}


- (NSURLSessionDataTask *)resetPasswordWithPhoneNumber:(NSString *)mobileNumber
                                           newPassword:(NSString *)newPassword
                                               success:(void (^)(void))success
                                               failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameters = @{
                                 @"mobile": mobileNumber,
                                 @"npwd": newPassword
                                 };
    
    return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                  URLString:@"user/resetPassword"
                                                 parameters:parameters
                                                    success:^(NSURLSessionDataTask *operation, id responseObject) {
                                                        
                                                        QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                        if (result) {
                                                            if (result.status == 0) {
                                                                success();
                                                            } else if (result.status == -1) {
                                                                NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeParameterIllegalFailure userInfo:@{
                                                                                                                                                                                @"QSYKError":result.message
                                                                                                                                                                                }];
                                                                failure(error);
                                                            } else if (result.status == 3) {
                                                                NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeExpireFailure userInfo:@{
                                                                                                                                                                      @"QSYKError":result.message
                                                                                                                                                                      }];
                                                                failure(error);
                                                            }
                                                        } else {
                                                            NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeResetPasswordFailure userInfo:@{
                                                                                                                                                                      @"QSYKError":result.message
                                                                                                                                                                      }];
                                                            failure(error);
                                                        }
                                                        
                                                    } failure:^(NSError *error) {
                                                        failure(error);
                                                    }];	
}

- (NSURLSessionDataTask *)checkUserNameExistenceWithUserName:(NSString *)userName
                                                     success:(void (^)(void))success
                                                     failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameters = @{
                                 @"nickname": userName
                                 };
    
    return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                  URLString:@"/v2/user/name-valid"
                                                 parameters:parameters
                                                    success:^(NSURLSessionDataTask *operation, id responseObject) {
                                                        
                                                        QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                        if (result && !result.status) {
                                                            success();
                                                        } else {
                                                            NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeUserNameNotExistFailure userInfo:@{
                                                                                                                                                                            @"QSYKError":result.message
                                                                                                                                                                            }];
                                                            failure(error);
                                                        }
                                                        
                                                    } failure:^(NSError *error) {
                                                        failure(error);
                                                    }];
}

- (NSURLSessionDataTask *)validateRegisterWithPhoneNumber:(NSString *)pno
                                                 password:(NSString *)pwd
                                                    uname:(NSString *)uname
                                                  success:(void (^)(void))success
                                                  failure:(void (^)(NSError *error))failure {
    
    NSDictionary *paramters = @{
                                @"mobile": pno,
                                @"pwd": pwd,
                                @"uname": uname
                                };
    
    return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST URLString:@"/user/validateRegister"
                                          parameters:paramters
                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                 QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                 if (result && !result.status) {
                                                     success();
                                                 } else {
                                                     NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeValidateRegisterFailure userInfo:@{
                                                                                                                                                                     @"QSYKError":result.message
                                                                                                                                                                     }];
                                                     failure(error);
                                                 }
                                             } failure:^(NSError *error) {
                                                 failure(error);
                                             }];
}

- (NSURLSessionDataTask *)validatePhoneNumber:(NSString *)pno
                                      success:(void (^)(void))success
                                      failure:(void (^)(NSError *error))failure {
    
    return [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                                    URLString:@"/v2/user/mobile-valid"
                                                   parameters:@{@"mobile": pno}
                                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                                          QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                          if (result && !result.status) {
                                                              success();
                                                          } else {
                                                              NSError *error = [[NSError alloc] initWithDomain:DOMAIN_NAME code:QSYKErrorTypeValidateRegisterFailure userInfo:@{
                                                                                                                                                                                @"QSYKError":result.message
                                                                                                                                                                                }];
                                                              failure(error);
                                                          }
                                                      } failure:^(NSError *error) {
                                                          failure(error);
                                                      }];
}

@end
