//
//  DropDownMenu.h
//  quiz
//
//  Created by subo on 15/11/18.
//  Copyright © 2015年 subo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DropDownMenuDelegate <NSObject>

- (void)menuDismiss;

@end

@interface DropDownMenu : UIView
+ (instancetype)menu;

/**
 *  显示
 */
- (void)showFrom:(UIView *)from;
/**
 *  销毁
 */
- (void)dismiss;

/**
 *  内容
 */
@property (nonatomic, strong) UIView *content;
/**
 *  内容控制器
 */
@property (nonatomic, strong) UIViewController *contentController;

//代理
@property (weak, nonatomic) id<DropDownMenuDelegate> delegate;
@end
