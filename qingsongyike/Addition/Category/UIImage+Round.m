//
//  UIImage+Round.m
//  qingsongyike
//
//  Created by 苗慧宇 on 5/9/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "UIImage+Round.h"

@implementation UIImage (Round)

- (UIImage *)roundImage {
    
    // NO透明
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    
    // 获得上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 添加一个圆
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextAddEllipseInRect(ctx, rect);
    
    // 裁剪
    CGContextClip(ctx);
    
    // 将图片画上去
    [self drawInRect:rect];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //结束上下文
    UIGraphicsEndImageContext();
    
    return image;
}

@end
