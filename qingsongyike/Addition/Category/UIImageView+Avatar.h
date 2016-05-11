//
//  UIImageView+Avatar.h
//  qingsongyike
//
//  Created by 苗慧宇 on 5/9/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Avatar)

/**
    默认头像的 name 为‘icon_avatar’,使用时可以修改为项目中已有的图片的name，或者修改图片的name
 */
- (void)setAvatar:(NSString *)aURL;

@end
