//
//  QSYKCommentTableViewCell.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/28/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKCommentTableViewCell.h"
#import "QSYKPostModel.h"

@interface QSYKCommentTableViewCell()
@property (nonatomic, assign) int dig;
@property (nonatomic, copy) NSString *sid;

@end

@implementation QSYKCommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.bottomSeparaotrHeiCon.constant = ONE_PIX;
    self.usernameLabel.textColor =kUsernameColor;
    [self.digBtn setImage:[UIImage imageNamed:@"comment_dig_gray"] forState:UIControlStateNormal];
    [self.digBtn setImage:[UIImage imageNamed:@"comment_dig_red"] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//使cell一定成为第一响应者（menuController 配置）
- (BOOL)canBecomeFirstResponder {
    return YES;
}

//支持的方法
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}

- (void)layoutSubviews {
    if (!_post) {
        return;
    }
    
    self.dig = _post.dig;
    self.sid = _post.sid;
    
    [self.avatarImageView setAvatar:[QSYKUtility imgUrl:_post.userAvatar width:120 height:120 extension:@"png"]];
    self.usernameLabel.text = _post.userName;
    self.digCountLabel.text = [NSString stringWithFormat:@"%d", _post.dig];
    self.pubTimeLabel.text = [QSYKUtility formateTimeInterval:_post.createTime];
    
    if (_post.hasDigged) {
        self.digBtn.selected = YES;
    } else {
        self.digBtn.selected = NO;
    }
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:_post.content];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineHeightMultiple:1.5];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.length)];
    self.commentContentLabel.attributedText = attrString;
}

- (IBAction)digBtnClicked:(id)sender {
    if (self.digBtn.selected) {
        return;
    }
    
    [self.digBtn setSelected:!self.digBtn.selected];
    if (self.digBtn.selected) {
        self.dig++;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(ratePostWithSid:indexPath:)]) {
        [_delegate ratePostWithSid:self.sid indexPath:_indexPath];
    }
    
    self.digCountLabel.text = [NSString stringWithFormat:@"%d", self.dig];
}

+ (CGFloat)cellBaseHeight {
    return 55.f;
}

@end
