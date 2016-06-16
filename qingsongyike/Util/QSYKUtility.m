//
//  QSYKUtility.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKUtility.h"
#import "SSKeychain.h"
#import "LYTopWindow.h"
#import "QSYKTopWindow.h"
#import <FMDB/FMDB.h>

#define FMDBQuickCheck(SomeBool) { if (!(SomeBool)) { NSLog(@"Failure on line %d", __LINE__); abort(); } }
static int MAX_READHISTORY_COUNT = 1000;

@implementation QSYKUtility

+ (NSString *)imgUrl:(NSString *)sid width:(int)width height:(int)height extension:(NSString *)extension
{
    return [NSString stringWithFormat:@"%@img/show/sid/%@/w/%d/h/%d/t/1/show.%@", kPictureBaseURL, sid, width, height, extension];
}

+ (NSString *)imgUrl:(NSString *)sid {
    return [NSString stringWithFormat:@"%@img/show/sid/%@/w//h//t/1/show.png", kPictureBaseURL, sid];
}

+ (CGFloat)heightForMutilLineLabel:(NSString *)string font:(CGFloat)fontSize width:(CGFloat)width {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:TEXT_LING_SPACING];
    
    string = [string stringByAppendingString:@"占"];
    CGSize titleSize = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                            options: NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{
                                                      NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                                      NSParagraphStyleAttributeName : paragraphStyle}
                                            context:nil].size;
    
    return ceil(titleSize.height);
}

+ (UIAlertController *)alertControllerWithTitle:(NSString *)title
                                        message:(NSString *)message
                              cancleActionTitle:(NSString *)cancleActionTitle
                                  goActionTitle:(NSString *)goActionTitle
                                 preferredStyle:(UIAlertControllerStyle)preferredStyle
                                        handler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    
    if (cancleActionTitle.length) {
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:cancleActionTitle style:UIAlertActionStyleCancel handler:nil];
        [alertView addAction:cancleAction];
    }
    
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:goActionTitle style:UIAlertActionStyleDefault handler:handler];
    [alertView addAction:createAction];
    
    return alertView;
}

+ (NSString *)mid {
    NSString *mid = [SSKeychain passwordForService:@"MID" account:@"qingsongyike"];
    if (!mid) {
        mid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:mid forService:@"MID" account:@"qingsongyike"];
    }
    
    return mid;
}

+ (NSString *)UAString {
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *mid = [QSYKUtility mid];
    
    return [NSString stringWithFormat:@"%@ iOS v%@ mid:%@", appName, version, mid];
}

//+ (void)startApp {
//    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
//                                             URLString:@"user/sign-task"
//                                            parameters:nil
//                                               success:^(NSURLSessionDataTask *task, id responseObject) {
//                                                   [[NSNotificationCenter defaultCenter] postNotificationName:kUserInfoChangedNotification object:nil];
//                                               }
//                                               failure:^(NSError *error) {
//                                                   
//                                               }];
//}
//
//+ (void)rateResourceWithSid:(NSString *)sid type:(NSInteger)type {
//    NSString *URLStr = type == 1 ? @"/resource/like" : @"/resource/hate";
//    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
//                                                 URLString:URLStr
//                                                parameters:@{
//                                                             @"sid" : sid,
//                                                             }
//                                                   success:^(NSURLSessionDataTask *task, id responseObject) {
//                                                       QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
//                                                       
//                                                       if (result && !result.status) {
//                                                           NSLog(@"评价成功");
//                                                       }
//                                                       
//                                                   } failure:^(NSError *error) {
//                                                       NSLog(@"评价失败  %@", error);
//                                                   }];
//}
//
//+ (void)ratePostWithSid:(NSString *)sid {
//    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
//                                             URLString:[NSString stringWithFormat:@"/post/like?sid=%@", sid]
//                                            parameters:nil
//                                               success:^(NSURLSessionDataTask *task, id responseObject) {
//                                                   QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
//                                                   
//                                                   if (result && !result.status) {
//                                                       NSLog(@"评价成功");
//                                                   }
//                                                   
//                                               } failure:^(NSError *error) {
//                                                   NSLog(@"评价失败  %@", error);
//                                               }];
//}

+ (void)loadSplash {
    // 更新数据库资源阅读记录（大于1000条数据时清除最早数据）
    [QSYKUtility updateReadHistory];
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:kDBPath];
    FMDBQuickCheck(queue);
    
    __block NSString *readHistoryStr = @"";
    
    {
        [queue inDatabase:^(FMDatabase *db) {
            
            int _2h = 0;
            int _24h = 0;
            int _72h = 0;
            int _168h = 0;
            
            FMResultSet *r = [db executeQuery:@"select * from readhistory"];
            NSInteger now = [[NSDate date] timeIntervalSince1970];
            
            while ([r next]) {
//                NSLog(@"sid=%@, time=%d", [r stringForColumn:@"sid"], [r intForColumn:@"createtime"]);
                NSInteger createTime = [r intForColumn:@"createtime"];
                NSInteger hours = (now - createTime) / 3600;
                
                if (hours <= 2) {
                    _2h++;
                }
                if (hours <= 24) {
                    _24h++;
                }
                if (hours <= 72) {
                    _72h++;
                }
                if (hours <= 168) {
                    _168h++;
                }
            }
            
            // 发送
            readHistoryStr = [NSString stringWithFormat:@"2hour=%d&24hour=%d&3day=%d&7day=%d", _2h, _24h, _72h, _168h];
            
        }];
    }
    
    NSString *device = [UIDevice currentDevice].model;
    NSString *sysver = [UIDevice currentDevice].systemVersion;
    NSString *urlStr = [NSString stringWithFormat:@"%@/splash?device=%@&sysver=%@&%@&%ld", kBaseURL, device, sysver, readHistoryStr, (long)TIMESTEMP];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSLog(@"splash URL = %@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:[QSYKUtility UAString] forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"GET"];
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        // 1.请求加密的数据
        NSURLResponse *response;
        NSError *encodeError = nil;
        NSData *encodedData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&encodeError];
        
        if (encodeError) {
            // Deal with your error
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                NSLog(@"HTTP Error: %ld %@", (long)httpResponse.statusCode, encodeError);
                return;
            }
            NSLog(@"Error %@", encodeError);
            return;
        }
        
//        NSString *responeString = [[NSString alloc] initWithData:encodedData
//                                                        encoding:NSUTF8StringEncoding];

        
        // 2.解码数据
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedData:encodedData options:0];
        if (!decodedData) {
            return;
        }
        
        // 3.把解密后的数据转换为字典类型
        NSError *parseError = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:decodedData options:0 error:&parseError];
        NSLog(@"dic = %@", dic);
        
        // 提取开关设置
        BOOL lotteryEnable = [dic[@"config"][@"lotteryEnable"] boolValue];
        BOOL beautyEnable  = [dic[@"config"][@"beautyEnable"] boolValue];
        BOOL thirdLoginEnable  = [dic[@"config"][@"thirdLoginEnable"] boolValue];
        
        // 存到本地
        [[NSUserDefaults standardUserDefaults] setBool:lotteryEnable forKey:@"lotteryEnable"];
        [[NSUserDefaults standardUserDefaults] setBool:beautyEnable forKey:@"beautyEnable"];
        [[NSUserDefaults standardUserDefaults] setBool:thirdLoginEnable forKey:@"thirdLoginEnable"];
        BOOL saveSuccess = [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"设置配置成功 = %d", saveSuccess);
    });
}

+ (void)setDefaultConfig {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"lotteryEnable"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"beautyEnable"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"thirdLoginEnable"];
    
    BOOL saveSuccess = [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"设置默认配置成功 = %d", saveSuccess);
}

// 隐藏topWindow
+ (void)hideTopWindow {
    if (SYSTEM_VERSION >= 8.0) {
        [LYTopWindow sharedTopWindow].hidden = YES;
    } else {
        [QSYKTopWindow hide];
    }
}

// 显示topWindow
+ (void)showTopWindow {
    if (SYSTEM_VERSION >= 8.0) {
        [LYTopWindow sharedTopWindow].hidden = NO;
    } else {
        [QSYKTopWindow show];
    }
}

+ (NSString *)formateTimeInterval:(NSString *)timeInterval {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd hh:mm"];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [dateFormatter setTimeZone:timeZone];
    return  [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[timeInterval doubleValue]]];
}

+ (NSString *)dbPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"qsyk.db"];
    
    return dbPath;
}

+ (void)saveResourceSidIntoDBWithSid:(NSString *)sid {
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:kDBPath];
    
    FMDBQuickCheck(queue);
    
    {
        [queue inDatabase:^(FMDatabase *db) {
            
            [db executeUpdate:@"create table if not exists readhistory(\
                                     sno        INTEGER PRIMARY KEY,\
                                     sid        TEXT,\
                                     createtime INTEGER);"];
            
            NSInteger timeInterval = [[NSDate date] timeIntervalSince1970];
            NSString *sql = [NSString stringWithFormat:@"insert into readhistory values(NULL, '%@', %ld)", sid, (long)timeInterval];
            NSLog(@"%@", sql);
            [db executeUpdate:sql];
            
            // 保存到本地，用来在渲染资源时去重
            
            NSMutableDictionary *mDic = [kUserReadHistory mutableCopy];
            [mDic setObject:sid forKey:sid];
            [[NSUserDefaults standardUserDefaults] setObject:mDic forKey:kReadHistoryDicKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
//            FMResultSet *r = [db executeQuery:@"select * from readhistory"];
//            while ([r next]) {
//                NSLog(@"sid=%@, time=%d", [r stringForColumn:@"sid"], [r intForColumn:@"createtime"]);
//            }
        }];
    }
    
}

+ (void)updateReadHistory {
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:kDBPath];
    
    FMDBQuickCheck(queue);
    
    {
        [queue inDatabase:^(FMDatabase *db) {
            
            int total = 0;
            int max   = 0;
            
            FMResultSet *r = [db executeQuery:@"select count(*) from readhistory"];
            if ([r next]) {
                total = [r intForColumnIndex:0];
                NSLog(@"columnCount = %d", total);
            }
            
            // 大于1000条记录时删除最早的记录
            if (total > MAX_READHISTORY_COUNT) {
                // 获取最大id，根据id进行清除
                r = [db executeQuery:@"select max(sno) from readhistory"];
                if ([r next]) {
                    max = [r intForColumnIndex:0];
                }
                
                int temp = max - MAX_READHISTORY_COUNT;
                r = [db executeQuery:@"select * from readhistory"];
                while ([r next]) {
                    int curSno = [r intForColumn:@"sno"];
                    if (curSno <= temp) {
                        NSString *sql = [NSString stringWithFormat:@"delete from readhistory where sno = %d", curSno];
                        [db executeUpdate:sql];
                        
                        // 同时删除本地的记录
                        NSMutableDictionary *mDic = [kUserReadHistory mutableCopy];
                        [mDic removeObjectForKey:[r stringForColumn:@"sid"]];
                        [[NSUserDefaults standardUserDefaults] setObject:mDic forKey:kReadHistoryDicKey];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
            }
            
//            r = [db executeQuery:@"select * from readhistory"];
//            while ([r next]) {
//                NSLog(@"%@", [r stringForColumn:@"sid"]);
//            }
            
        }];
    }
}

+ (NSArray *)readHistoryArray {
    // 先更新阅读历史记录
    [QSYKUtility updateReadHistory];
    
    FMDatabase *db = [FMDatabase databaseWithPath:kDBPath];
    
    NSMutableArray *readHistory = [NSMutableArray new];
    if ([db open]) {
        FMResultSet *r = [db executeQuery:@"select * from readhistory"];
        while ([r next]) {
            if (![readHistory containsObject:[r stringForColumn:@"sid"]]) {
                NSDictionary *dic = @{[r stringForColumn:@"sid"] : [r stringForColumn:@"createtime"]};
                [readHistory addObject:dic];
                
//                NSLog(@"createTime = %@", [r stringForColumn:@"createtime"]);
            }
        }
    }
    
    [db close];
    
    return [readHistory copy];
}

+ (NSArray *)removeRedundantData:(NSArray *)original {
    NSMutableArray *temp = [NSMutableArray new];
    
    NSDictionary *readHistory = kUserReadHistory;
    for (QSYKResourceModel *aResource in original) {
        if ([readHistory objectForKey:aResource.sid] != nil) {
            continue;
        }
        
        [temp addObject:aResource];
    }
    
    return [temp copy];
}

+ (BOOL)isMobileNum:(NSString *)mobileNum
{
    NSString * phoneRegex = @"^(0|86|17951)?(1[23][0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    BOOL isMatch = [pred evaluateWithObject:mobileNum];
    return isMatch;
}

+ (NSString *)formateBirthdayWithTimeInterval:(NSString *)timeInterval {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [dateFormatter setTimeZone:timeZone];
    return  [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[timeInterval doubleValue]]];
}

@end
