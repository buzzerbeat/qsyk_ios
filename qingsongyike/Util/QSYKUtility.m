//
//  QSYKUtility.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKUtility.h"
#import "SSKeychain.h"

@implementation QSYKUtility

+ (NSString *)imgUrl:(NSString *)sid width:(int)width height:(int)height extension:(NSString *)extension
{
    return [NSString stringWithFormat:@"%@img/show/sid/%@/w/%d/h/%d/t/1/show.%@", kBaseURL, sid, width, height, extension];
}

+ (NSString *)imgUrl:(NSString *)sid {
    return [NSString stringWithFormat:@"%@img/show/sid/%@/w//h//t/1/show.png", kBaseURL, sid];
}

+ (CGFloat)heightForMutilLineLabel:(NSString *)string font:(CGFloat)fontSize width:(CGFloat)width {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:TEXT_LING_SPACING];
    
    CGSize titleSize = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{
                                                      NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                                      NSParagraphStyleAttributeName : paragraphStyle}
                                            context:nil].size;
    
    return ceil(titleSize.height);
}

+ (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message cancleActionTitle:(NSString *)cancleActionTitle goActionTitle:(NSString *)goActionTitle handler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
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

@end
