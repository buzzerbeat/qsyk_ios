//
//  AppDelegate.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "AppDelegate.h"
#import "QSYKBaseNavigationController.h"
#import "QSYKIndexViewController.h"
#import <UMengSocial/UMSocial.h>
#import "QSYKJPushManager.h"
#import "JPUSHService.h"
#import "QSYKUMengManager.h"
#import "LYTopWindow.h"
#import "QSYKRootTabBarController.h"
#import "QSYKTopWindow.h"
#import "QSYKResourceDetailViewController.h"
#import <AdSupport/AdSupport.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification) {
        NSString *resourceSid = [NSString stringWithFormat:@"%@", remoteNotification[@"resourceSid"]];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFromRemotePushNotification object:nil userInfo:@{@"resourceSid": resourceSid}];
        [[NSUserDefaults standardUserDefaults] setObject:resourceSid forKey:kRemotePushedResourceSid];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //AFNetwork state monitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //TODO: 网络状况变化处理方法
        
    }];
    
//    NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // 实现点击状态栏让keyWindow上的ScrollView滚动到顶部
    if (SYSTEM_VERSION >= 8.0) {
        [[LYTopWindow sharedTopWindow] setClickStatusBarBlock:^{
            // 让keyWindow上的ScrollView滚动到顶部
            [[LYTopWindow sharedTopWindow] searchAllScrollViewsInView:[UIApplication sharedApplication].keyWindow];
            
            // 如果需要实现点击状态栏，实现其他功能，可用在这里编写功能代码
        }];
    } else {
        [QSYKTopWindow show];
    }
    
    // 极光推送
    [QSYKJPushManager sharedManager];
    // 注册通知监听自定义推送消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
    // 友盟
    [QSYKUMengManager shardManager];
    // 设置APP最大缓存为 100M
    [[SDImageCache sharedImageCache] setMaxCacheSize:100 * 1024 * 1024];
    
    // 启动app时如果本地没有token，通过注册获得
    NSString *token = kToken;
    if (!token.length) {
        [[QSYKDataManager sharedManager] registerAction];
    } else {
        [[QSYKDataManager sharedManager] startApp];
        
        // 检查token是否可用
        [[QSYKDataManager sharedManager] checkToken];
    }
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
//    self.window.rootViewController = [[QSYKBaseNavigationController alloc]
//                                      initWithRootViewController:[[QSYKIndexViewController alloc] init]]
    
    // 安装并启动app时先设置配置信息的默认值
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isReStart"]) {
        [QSYKUtility setDefaultConfig];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isReStart"];
    }
    [QSYKUtility loadSplash];
    
    // 设置默认文本字体大小
    [[NSUserDefaults standardUserDefaults] setFloat:18 forKey:@"text_font"];
    
    // 设置 HUD 显示时间为 2s
    [SVProgressHUD setMinimumDismissTimeInterval:2.0];
    
    
    // 展示SplashView
    UIImage *launchImg = nil;
    if (kIsIphone) {
        launchImg = [UIImage imageNamed:@"default_4.7"];
    } else {
        UIInterfaceOrientation orientation = application.statusBarOrientation;
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            launchImg = [UIImage imageNamed:@"iPad_portrait"];
        } else if (UIInterfaceOrientationIsLandscape(orientation)) {
            launchImg = [UIImage imageNamed:@"iPad_landscape"];
        }
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:launchImg];
    imageView.frame = SCREEN_FRAME;
    UIViewController *tempVC = [[UIViewController alloc] init];
    [tempVC.view addSubview:imageView];
    self.window.rootViewController = tempVC;
    
    NSTimeInterval timeInterval = SYSTEM_VERSION >= 8.0 ? 2.5f : 0;
    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timeoutForSplashView) userInfo:nil repeats:NO];
     
    
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    // iPhone只支持竖屏
    if (kIsIphone) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)timeoutForSplashView {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    self.window.rootViewController = [[QSYKRootTabBarController alloc] init];
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
//    NSDictionary * userInfo = [notification userInfo];
//    NSString *content = [userInfo valueForKey:@"content"];
//    NSDictionary *extras = [userInfo valueForKey:@"extras"];
//    NSString *resourceSid = [extras valueForKey:@"resourceSid"]; //自定义参数，key是自己定义的
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [UMSocialSnsService  applicationDidBecomeActive];
    
    // 打开app时将badgeNumber置为0
    [application setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // JPush
    [JPUSHService registerDeviceToken:deviceToken];
    NSLog(@"Device Token: %@", deviceToken);
    
    [JPUSHService setTags:nil alias:@"mhy" fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
        NSLog(@"%d", iResCode);
    }];
}

// 当 DeviceToken 获取失败时，系统会回调此方法
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"DeviceToken 获取失败，原因：%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    

    if (application.applicationState == UIApplicationStateInactive) {
        // 参数resourceSid，打开本sid的资源，左上角返回后，返回首页
        // 当resourceSid为空，或者不存在本参数时，直接打开客户端首页即可
        NSString *resourceSid = userInfo[@"resourceSid"];
        if (resourceSid && resourceSid.length) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadFromRemotePushNotification object:nil userInfo:@{@"resourceSid": resourceSid}];
        }
    }
}

@end
