//
//  QZBindThirdCell.h
//  quiz
//
//  Created by 苗慧宇 on 16/1/6.
//  Copyright © 2016年 subo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellIdentifier_BindThird @"BindThirdTableViewCell"

@interface QZBindThirdCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *thirdTypeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bindStateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thirdTypeImageView;

@end
