//
//  QSYKUserManager.h
//  quiz
//
//  Created by Xin on 15/9/18.
//  Copyright (c) 2015年 subo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSYKUserModel.h"
#import "QSYKDataManager.h"
@protocol UserCallBackDelegate <NSObject>

@optional
- (void)returnSuccess;
- (void)returnSuccess:(NSDictionary *)data;
- (void)returnFailed:(NSString *)message;

- (void)startCountDown;
- (void)phoneNumExist;
- (void)isThirdNameCanUse:(BOOL)flag;  //此处需要修改
@end

@interface QSYKUserManager : NSObject
@property (weak, nonatomic) id <UserCallBackDelegate> delegate;
+ (QSYKUserManager *)shardManager;

@property (nonatomic, strong) QSYKUserModel *user;


#pragma mark Public Request Methods - Login & Profile


- (NSURLSessionDataTask *) loginWithMobileNum:(NSString *)mobileNum
                                     password:(NSString *)password
                                      success:(void (^)(QSYKUserModel *userModel))success
                                      failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *) registerWithMobileNumber:(NSString *)mobileNumber
                                               name:(NSString *)name
                                           password:(NSString *)password
                                         avatarData:(NSData *)avatar
                                            success:(void (^)(QSYKUserModel *userModel))success
                                            failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *) registerWithThirdPartyOid:(NSString *)oid
                                                type:(NSString *)type
                                                name:(NSString *)name
                                          avatarData:(NSData *)avatar
                                             success:(void (^)(QSYKUserModel *userModel))success
                                             failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *) requestVerifyCodeWithPhoneNumber:(NSString *)pno
                                                      success:(void (^)(void))success
                                                      failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)loginWithThirdPartyOid:(NSString *)oid
                                              type:(NSString *)type
                                           success:(void (^)(QSYKUserModel *userModel))success
                                           failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)verifyCodeCorrectWithPhoneNumber:(NSString *)mobileNumber
                                                   verifyCode:(NSString *)verifyCode
                                                      success:(void (^)(void))success
                                                      failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)forgotPasswordWithPhoneNumber:(NSString *)mobileNumber
                                                   success:(void (^)(void))success
                                                   failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)refreshVerifyCodeStateWithPhoneNumber:(NSString *)mobileNumber
                                                           success:(void (^)(void))success
                                                           failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)resetPasswordWithPhoneNumber:(NSString *)mobileNumber
                                           newPassword:(NSString *)newPassword
                                               success:(void (^)(void))success
                                               failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)checkUserNameExistenceWithUserName:(NSString *)userName
                                                       success:(void (^)(void))success
                                                       failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)validateRegisterWithPhoneNumber:(NSString *)pno
                                                 password:(NSString *)pwd
                                                    uname:(NSString *)uname
                                                  success:(void (^)(void))success
                                                  failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)validatePhoneNumber:(NSString *)pno
                                      success:(void (^)(void))success
                                      failure:(void (^)(NSError *error))failure;

@end
