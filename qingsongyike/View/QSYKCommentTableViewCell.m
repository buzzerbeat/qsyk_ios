//
//  QSYKCommentTableViewCell.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/28/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKCommentTableViewCell.h"

@implementation QSYKCommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.height / 2;
    [self.digBtn setImage:[UIImage imageNamed:@"commentLikeButton"] forState:UIControlStateNormal];
    [self.digBtn setImage:[UIImage imageNamed:@"commentLikeButtonClick"] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//使cell一定成为第一响应者
- (BOOL)canBecomeFirstResponder {
    return YES;
}

//支持的方法
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.digBtn setSelected:NO];
}

- (void)layoutSubviews {
    
}

- (IBAction)digBtnClicked:(id)sender {
    [self.digBtn setSelected:!self.digBtn.selected];
    if (self.digBtn.selected) {
        
    }
}

+ (CGFloat)cellBaseHeight {
    return 57.f;
}

@end
