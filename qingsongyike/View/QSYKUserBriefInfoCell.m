//
//  QSYKUserBriefInfoCell.m
//  qingsongyike
//
//  Created by 苗慧宇 on 6/8/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKUserBriefInfoCell.h"

@implementation QSYKUserBriefInfoCell

- (void)awakeFromNib {
    
    self.avatarImageView.layer.borderColor   = kSeparatorLightGrayColor.CGColor;
    self.avatarImageView.layer.borderWidth   = 1.0 / [UIScreen mainScreen].scale;
    self.avatarImageView.layer.cornerRadius  = 5;
    self.avatarImageView.layer.masksToBounds = YES;
    
    self.loginBtn.layer.cornerRadius  = 5;
    self.loginBtn.layer.borderWidth   = 1.0 / [UIScreen mainScreen].scale;
    self.loginBtn.layer.borderColor   = [UIColor lightGrayColor].CGColor;
    self.loginBtn.layer.masksToBounds = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_user) {
        self.avatarImageView.hidden = YES;
        self.usernameLabel.hidden   = YES;
        self.descLabel.hidden       = YES;
        self.loginBtn.hidden        = NO;

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else {
        self.avatarImageView.hidden = NO;
        self.usernameLabel.hidden   = NO;
        self.descLabel.hidden       = NO;
        self.loginBtn.hidden        = YES;
        
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[QSYKUtility imgUrl:_user.userAvatar width:200 height:200 extension:@"png"]] placeholderImage:[UIImage imageNamed:@"icon_avatar"]];
        self.usernameLabel.text = _user.userName;
        self.descLabel.text = _user.userBrief;
    }
}


@end
