//
//  QSYKUserBriefInfoCell.h
//  qingsongyike
//
//  Created by 苗慧宇 on 6/8/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellIdentifier_userBrief @"QSYKUserBriefInfoCell"

@interface QSYKUserBriefInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (nonatomic, strong) QSYKUserModel *user;

@end
