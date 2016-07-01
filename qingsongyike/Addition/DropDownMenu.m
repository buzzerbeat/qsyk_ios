//
//  DropDownMenu.m
//  quiz
//
//  Created by subo on 15/11/18.
//  Copyright © 2015年 subo. All rights reserved.
//

#import "DropDownMenu.h"
@interface DropDownMenu()
/**
 *  将来用来显示具体内容的容器
 */
@property (nonatomic, weak) UIImageView *containerView;
@end

@implementation DropDownMenu

- (UIImageView *)containerView
{
    if (!_containerView) {
        // 添加一个灰色图片控件
        UIImageView *containerView = [[UIImageView alloc] init];// WithFrame:CGRectMake(0, 0, MENU_WIDTH, MENU_HEIGHT)];
        
        UIImage *image = [UIImage imageNamed:@"popover_background"];
        containerView.image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5f topCapHeight:image.size.height * 0.5f];
        
//        containerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8f];
        containerView.userInteractionEnabled = YES; // 开启交互
        containerView.layer.cornerRadius = 3.f;
        containerView.layer.masksToBounds = YES;
        [self addSubview:containerView];
        self.containerView = containerView;
    }
    return _containerView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 清除颜色
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+ (instancetype)menu
{
    return [[self alloc] init];
}

- (void)setContent:(UIView *)content
{
    _content = content;
    
    // 调整内容的位置
    _content.x = 0;
    _content.y = 15;
    // 调整内容的frame
    _content.width = MENU_WIDTH - 5;//2 * content.x;
//    content.height -= (content.y + 8);
    
    
    // 设置灰色的高度
    self.containerView.height = _content.height + 25;
    // 设置灰色的宽度
    self.containerView.width = MENU_WIDTH;
    
    // 添加内容到灰色图片中
    [self.containerView addSubview:content];
}

- (void)setContentController:(UIViewController *)contentController
{
    _contentController = contentController;
    
    self.content = contentController.view;
}

/**
 *  显示
 */
- (void)showFrom:(UIView *)from
{
    // 1.获得最上面的窗口
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    // 2.添加自己到窗口上
    [window addSubview:self];
    
    self.alpha = 0;
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 1;
    }];
    
    // 3.设置尺寸
    self.frame = window.bounds;
    
    // 4.调整灰色图片的位置
    // 默认情况下，frame是以父控件左上角为坐标原点
    // 转换坐标系
    CGRect newFrame = [from convertRect:from.bounds toView:window];
    //    CGRect newFrame = [from.superview convertRect:from.frame toView:window];
    self.containerView.centerX = CGRectGetMidX(newFrame);
    self.containerView.y = CGRectGetMaxY(newFrame) - 7;
}

/**
 *  销毁
 */
- (void)dismiss
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuDismiss)]) {
        [self.delegate menuDismiss];
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}

@end