//
//  QSYKUMengManager.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/27/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CLLocation;
@class UMSocialUrlResource;

@interface QSYKUMengManager : NSObject

+ (QSYKUMengManager *)shardManager;

/**
 发送内容到多个平台
 
 @param platformType    分享到的平台，元素是`UMSocialSnsPlatformManager.h`定义的平台名的常量字符串，例如`UMShareToSina`，`UMShareToTencent`等。
 @param content          分享的文字内容
 @param image            分享的图片,可以传入UIImage类型或者NSData类型
 @param location         分享的地理位置信息
 @param urlResource      图片、音乐、视频等url资源
 @param completion       发送完成执行的block对象
 @param presentedController 如果发送的平台微博没有授权，传入要授权的viewController，将弹出授权页面，进行授权。可以传nil，将不进行授权。
 
 */
- (void)shareToThirdPlatformWithType:(NSString *)platformName
                               title:(NSString *)title
                                 url:(NSString *)url
                             content:(NSString *)content
                               image:(id)image
                            location:(CLLocation *)location
                         urlResource:(UMSocialUrlResource *)urlResource
                 presentedController:(UIViewController *)presentedController
                             success:(void (^)(void))succuess
                             failure:(void (^)(NSInteger responseCode))failure;

@end
