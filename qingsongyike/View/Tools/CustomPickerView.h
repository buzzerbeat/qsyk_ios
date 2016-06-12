//
//  CustomPickerView.h
//  quiz
//
//  Created by subo on 15/11/11.
//  Copyright © 2015年 subo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomPickerViewDelegate;

@interface CustomPickerView : UIView
@property (weak, nonatomic) IBOutlet UIPickerView *myPickerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) id<CustomPickerViewDelegate> delegate;

- (id)initWithTitileName:(NSString *)titile dataArray:(NSArray *)dataArray delegate:(id<CustomPickerViewDelegate>)delegate;
- (void)showInView:(UIView *)view;

@end

@protocol CustomPickerViewDelegate<NSObject>

- (void)pickerDidSelected:(NSInteger)index customPickerView:(CustomPickerView *)customPickerView;

@end
