//
//  UIImageView+Avatar.m
//  qingsongyike
//
//  Created by 苗慧宇 on 5/9/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "UIImageView+Avatar.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (Avatar)

- (void)setAvatar:(NSString *)aURL {
    UIImage *placeholder = [[UIImage imageNamed:@"icon_avatar"] roundImage];
    [self sd_setImageWithURL:[NSURL URLWithString:aURL] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.image = image ? [image roundImage] : placeholder;
    }];
}

@end
