//
//  CustomPickerView.m
//  quiz
//
//  Created by subo on 15/11/11.
//  Copyright © 2015年 subo. All rights reserved.
//

#import "CustomPickerView.h"

@interface CustomPickerView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) UIView *backView;
@property (copy, nonatomic) NSString *finalData;    //界面显示选中的数据
@property (assign, nonatomic) NSInteger index;

@end

@implementation CustomPickerView

- (id)initWithTitileName:(NSString *)titile dataArray:(NSArray *)dataArray delegate:(id<CustomPickerViewDelegate>)delegate
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"CustomPickerView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        self.delegate = delegate;
        self.dataArray = dataArray;
        self.finalData = [dataArray objectAtIndex:0];
        self.myPickerView.delegate = self;
        self.myPickerView.dataSource = self;
        self.titleLabel.text = titile;
        CGRect screenRect = [UIScreen mainScreen].bounds;
        self.backView = [[UIView alloc] initWithFrame:screenRect];
        self.backView.backgroundColor = [UIColor blackColor];
        self.backView.alpha = 0.f;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackView:)];
        [self.backView addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)tapBackView:(UIGestureRecognizer *)gesture
{
    [self cancelPicker];
}

#pragma mark - UIPickerView delegate and source
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0f;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.dataArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.dataArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.finalData = [self.dataArray objectAtIndex:row];
    self.index = row;
}

#pragma mark - privateAction
- (void)showInView:(UIView *)superView
{
    if (!self.superview) {
        [superView addSubview:self.backView];
        [superView addSubview:self];
    }
    
    self.frame = CGRectMake(0, superView.bounds.size.height, superView.bounds.size.width, 200);
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = superView.bounds.size.height - frame.size.height;
        self.frame = frame ;
        self.backView.alpha = 0.3;
    }];
}

#pragma mark - privateAction
- (IBAction)finishedTap:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(pickerDidSelected:customPickerView:)]) {
        [_delegate pickerDidSelected:self.index customPickerView:self];
    }

    [self cancelPicker];
}

- (IBAction)cancelTap:(id)sender
{
    [self cancelPicker];
}

- (void)cancelPicker
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, self.frame.origin.y+self.frame.size.height, self.frame.size.width, self.frame.size.height);
                         self.backView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         [self.backView removeFromSuperview];
                     }];
    
}

@end
