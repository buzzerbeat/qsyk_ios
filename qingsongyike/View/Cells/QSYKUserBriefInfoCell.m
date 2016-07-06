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
    self.avatarImageView.layer.borderWidth   = ONE_PIX;
    self.avatarImageView.layer.cornerRadius  = 5;
    self.avatarImageView.layer.masksToBounds = YES;
    
    self.loginBtn.layer.cornerRadius  = 5;
    self.loginBtn.layer.borderWidth   = ONE_PIX;
    self.loginBtn.layer.borderColor   = [UIColor clearColor].CGColor;
    self.loginBtn.layer.masksToBounds = YES;
    
    for (NSLayoutConstraint *con in self.separatorHeightCons) {
        con.constant = ONE_PIX;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_user) {
        [self setSubViewVisibility:YES];
        self.contentView.backgroundColor = kCoreColor;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else {
        [self setSubViewVisibility:NO];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[QSYKUtility imgUrl:_user.userAvatar width:120 height:120 extension:@"jpg"]] placeholderImage:[UIImage imageNamed:@"icon_avatar"]];
        self.usernameLabel.text = _user.userName;
        self.descLabel.text = _user.userBrief;
    }
}

- (void)setSubViewVisibility:(BOOL)b {
    self.avatarImageView.hidden = b;
    self.arrowImageView.hidden  = b;
    self.usernameLabel.hidden   = b;
    self.topSeparator.hidden    = b;
    self.descLabel.hidden       = b;
    self.loginBtn.hidden        = !b;
}


@end
