//
//  ProfileTableViewCell.h
//  quiz
//
//  Created by subo on 15/11/9.
//  Copyright © 2015年 subo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellIdentifier_Profile @"ProfileTableViewCell"

@interface ProfileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;    //显示该Label时不显示右侧箭头
@property (weak, nonatomic) IBOutlet UILabel *logoutLabel;


@end
