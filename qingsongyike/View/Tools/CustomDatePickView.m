//
//  CustomDatePickView.m
//  cinema
//
//  Created by subo on 15/11/4.
//  Copyright © 2015年 subo. All rights reserved.
//

#import "CustomDatePickView.h"

@interface CustomDatePickView()
{
    UIView* _blackView;
}


@end
@implementation CustomDatePickView

+ (id)loadFromXib
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@",[self class]] owner:nil options:nil];
    if (array && [array count]) {
        return array[0];
    }else {
        return nil;
    }
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    _datePicker.maximumDate = [NSDate date];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    _datePicker.locale = locale;
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    _blackView = [[UIView alloc]initWithFrame:screenRect];
    _blackView.backgroundColor = [UIColor blackColor];
    _blackView.alpha = 0.f;
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBlackView:)];
    [_blackView addGestureRecognizer:gesture];
}
#pragma mark -public method
-(void)showInView:(UIView*)superView
{
    if (!self.superview) {
        [superView addSubview:_blackView];
        [superView addSubview:self];
    }
    
//    double height = (superView.bounds.size.width - 3)
    self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * 0.8);
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = superView.bounds.size.height - frame.size.height;
        self.frame = frame ;
        _blackView.alpha = 0.3f;
    }];
}
-(IBAction)hide:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-20, self.frame.size.width, self.frame.size.height);
        _blackView.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
        [_blackView removeFromSuperview];
    }];
}

#pragma mark ib method
- (IBAction)sureBtnClicked:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"yyyy-MM-dd"]];
    
    NSTimeInterval timeInterval = [_datePicker.date timeIntervalSince1970];
    if(_delegate&&[_delegate respondsToSelector:@selector(datePickerSelected:)]){
        [_delegate datePickerSelected:timeInterval];
    }
    [self hide:nil];
}

#pragma mark -private method
-(void)tapBlackView:(UIGestureRecognizer*)gesture
{
    [self hide:nil];
}
@end

