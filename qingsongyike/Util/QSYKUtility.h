//
//  QSYKUtility.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QSYKUtility : NSObject

/**
 * 封装请求图片的URL（带 width & height 参数）
 */
+ (NSString * _Nonnull)imgUrl:(NSString * _Nonnull)sid width:(int)width height:(int)height extension:(NSString * _Nonnull)extension;

/**
 * 封装请求图片的URL（不带 width & height 参数）
 */
+ (NSString * _Nonnull)imgUrl:(NSString * _Nonnull)sid;

+ (CGFloat)heightForMutilLineLabel:(NSString * _Nonnull)string font:(CGFloat)fontSize width:(CGFloat)width;

+ (UIAlertController * _Nonnull)alertControllerWithTitle:(NSString * _Nullable)title
                                                 message:(NSString * _Nullable)message
                                       cancleActionTitle:(NSString * _Nullable)cancleActionTitle
                                           goActionTitle:(NSString * _Nonnull)goActionTitle
                                                 preferredStyle:(UIAlertControllerStyle)preferredStyle
                                                 handler:(void (^ __nullable)(UIAlertAction * _Nonnull action))handler;

+ (NSString * _Nonnull)mid;

+ (NSString * _Nonnull)UAString;

//+ (void)startApp;
//
//+ (void)rateResourceWithSid:(NSString * _Nonnull)sid type:(NSInteger)type;
//
//+ (void)ratePostWithSid:(NSString * _Nonnull)sid;

+ (void)loadSplash;

+ (void)setDefaultConfig;

+ (void)hideTopWindow;

+ (void)showTopWindow;

/**
 * 格式：MM-dd hh:mm
 */
+ (NSString * _Nonnull)formateTimeInterval:(NSString * _Nonnull)timeInterval;

/**
 * 数据库路径
 */
+ (NSString * _Nonnull)dbPath;


/**
 * 数据库路径
 */
+ (void)saveResourceSidIntoDBWithSid:(NSString * _Nonnull)sid;

/**
 * 刷新数据库
 */
+ (void)updateReadHistory;

/**
 * 读取数据库记录到数组
 */
+ (NSArray * _Nonnull)readHistoryArray;

+ (NSArray * _Nonnull)removeRedundantData:(NSArray * _Nonnull)original;

/**
 * 校验是否为合法的手机号
 */
+ (BOOL)isMobileNum:(NSString * _Nonnull)mobileNum;

/**
 * 格式化日期格式为“yyyy-MM-dd”
 */
+ (NSString * _Nonnull)formateBirthdayWithTimeInterval:(NSString * _Nonnull)timeInterval;

+ (void)showDeleteResourceReasonsWithSid:(NSString * _Nonnull)sid delegate:(id _Nonnull)delegate;

/**
 * 设置多行 label 的文字的行间距
 */
+ (NSMutableAttributedString * _Nonnull)attrStringWithString:(NSString * _Nonnull)string;

@end
