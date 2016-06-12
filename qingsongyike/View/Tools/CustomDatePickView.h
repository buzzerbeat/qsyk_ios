//
//  CustomDatePickView.h
//  cinema
//
//  Created by subo on 15/11/4.
//  Copyright © 2015年 subo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomDatePickViewDelegate;

@interface CustomDatePickView : UIView
@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (retain, nonatomic) IBOutlet UILabel *title;
@property (assign,nonatomic) id<CustomDatePickViewDelegate> delegate;
-(void)showInView:(UIView*)superView;
+(id)loadFromXib;
@end
@protocol CustomDatePickViewDelegate <NSObject>

-(void)datePickerSelected:(NSTimeInterval)timeInterval;

@end
