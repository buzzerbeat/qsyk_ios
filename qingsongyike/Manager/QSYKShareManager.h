//
//  QSYKShareManager.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/27/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QSYKShareManager : NSObject

+ (QSYKShareManager *)sharedManager;

- (void)showInVC:(UIViewController *)target resourceSid:(NSString *)resourceSid content:(NSString *)content;

@end
