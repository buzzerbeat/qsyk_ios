//
//  QSYKTabBar.m
//  qingsongyike
//
//  Created by 苗慧宇 on 6/1/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKTabBar.h"

@interface QSYKTabBar()
@property (nonatomic, strong) UIButton *middleBtn;

@end

@implementation QSYKTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 添加一个按钮到tabbar中
        UIButton *middleBtn = [UIButton new];
//        [middleBtn setBackgroundImage:[UIImage imageNamed:@"tabbar_compose_button"] forState:UIControlStateNormal];
//        [middleBtn setBackgroundImage:[UIImage imageNamed:@"tabbar_compose_button_highlighted"] forState:UIControlStateHighlighted];
        [middleBtn setImage:[UIImage imageNamed:@"ic_lottery"] forState:UIControlStateNormal];
        [middleBtn setImage:[UIImage imageNamed:@"ic_lottery_pressed"] forState:UIControlStateHighlighted];
        middleBtn.size = CGSizeMake(SCREEN_WIDTH / 3, 49);//middleBtn.currentBackgroundImage.size;
        [middleBtn addTarget:self action:@selector(middleBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:middleBtn];
        self.middleBtn = middleBtn;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 1.设置按钮的位置
    self.middleBtn.centerX = self.width * 0.5;
    self.middleBtn.centerY = self.height * 0.5;
    
    // 解决第一个tabBarButton可点击的区域大于自身宽度，导致中间按钮的可点击区域变小的问题
    [self bringSubviewToFront:self.middleBtn];
    
    // 2.设置其它UITabBarButton的位置和尺寸
    CGFloat tabbarButtonW = self.width / 3;
    CGFloat tabbarButtonIndex = 0;
    for (UIView *child in self.subviews) {
        Class class = NSClassFromString(@"UITabBarButton");
        if ([child isKindOfClass:class]) {
            // 设置宽度
            child.width = tabbarButtonW;
            
            // 设置x
            child.x = tabbarButtonIndex * tabbarButtonW;
            
            // 增加索引
            tabbarButtonIndex++;
            if (tabbarButtonIndex == 1) {
                tabbarButtonIndex++;
            }
        }
    }
}

#pragma mark 加号按钮点击事件处理器
- (void)middleBtnClick
{
    // 通知代理
    if ([self.tabBarDelegate respondsToSelector:@selector(tabBarDidClickMiddleButton:)]) {
        [self.tabBarDelegate tabBarDidClickMiddleButton:self];
    }
}


@end
