//
//  QSYKSharePopupView.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/27/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UMSocialUrlResource;

@interface QSYKSharePopupView : UIView
@property (copy, nonatomic) NSString *shareURL;
@property (copy, nonatomic) NSString *shareTitle;
@property (copy, nonatomic) NSString *shareContent;
@property (strong, nonatomic) id shareImage;
@property (strong, nonatomic) UMSocialUrlResource *shareURLResource;
@property (nonatomic, strong) UIViewController *target;
@property (nonatomic, copy) NSString *resourceSid;

@property (copy) void (^dismissPopupBlock)(void);    // 隐藏popupView

@end
