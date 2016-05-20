//
//  QSYKTopicTableViewCell.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/25/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKTopicTableViewCell.h"

@implementation QSYKTopicTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.separatorHeightCon.constant = 1.0 / [[UIScreen mainScreen] scale];
    [self.contentLabel setNumberOfLines:0];
    
    [self.digBtn setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateNormal];
    [self.digBtn setImage:[UIImage imageNamed:@"icon_like_pressed"] forState:UIControlStateSelected];
    [self.buryBtn setImage:[UIImage imageNamed:@"icon_dislike"] forState:UIControlStateNormal];
    [self.buryBtn setImage:[UIImage imageNamed:@"icon_dislike_pressed"] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.digBtn setSelected:NO];
    [self.buryBtn setSelected:NO];
    self.digCountLabel.textColor = [UIColor lightGrayColor];
    self.buryCountLabel.textColor = [UIColor lightGrayColor];
    self.buryBtn.userInteractionEnabled = YES;
    self.digBtn.userInteractionEnabled = YES;
}

- (void)layoutSubviews {
    if (!_resource) {
        return;
    }
    
    if ([_resource isKindOfClass:[QSYKResourceModel class]]) {
        QSYKResourceModel *res = (QSYKResourceModel *)_resource;
        
        self.userName = res.username;
        self.userAvatar = res.userAvatar;
        self.content = res.content;
        self.sid = res.sid;
        self.pubTime = res.pubTime;
        self.dig = res.dig;
        self.bury = res.bury;
        self.isTopic = (res.type == 1);
    } else {
        QSYKFavoriteResourceModel *res = (QSYKFavoriteResourceModel *)_resource;
        
        self.userName = res.userName;
        self.userAvatar = res.userAvatar;
        self.content = res.desc;
        self.sid = res.sid;
        self.pubTime = res.pubTimeElapsed;
        self.dig = res.dig;
        self.bury = res.bury;
        self.isTopic = (res.type == 1);
    }
    
    // 解决cell的contentView不随着cell高度的变化而变化（原因未找到）
    self.contentView.height = [QSYKUtility heightForMutilLineLabel:self.content
                                                              font:16.f
                                                             width:SCREEN_WIDTH - 8 * 4] + 140 ;
    
    [self.avatarImageView setAvatar:[QSYKUtility imgUrl:self.userAvatar width:200 height:200 extension:@"png"]];
    self.usernameLabe.text = self.userName;
    self.pubTimeLabel.text = self.pubTime;
    self.digCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.dig];
    self.buryCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.bury];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.content];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:TEXT_LING_SPACING];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.length)];
    self.contentLabel.attributedText = attrString;
}

- (IBAction)digBtnClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(rateResourceWithSid:type:indexPath:)]) {
        [_delegate rateResourceWithSid:self.sid type:1 indexPath:_indexPath];
        [self.digBtn setSelected:YES];
        self.digCountLabel.textColor = kCoreColor;
        self.digCountLabel.text = [NSString stringWithFormat:@"%ld", (long)++self.dig];
        [self disableRateBtn];
    }
}

- (IBAction)buryBtnClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(rateResourceWithSid:type:indexPath:)]) {
        [_delegate rateResourceWithSid:self.sid type:2 indexPath:_indexPath];
        [self.buryBtn setSelected:YES];
        self.buryCountLabel.textColor = kCoreColor;
        self.buryCountLabel.text = [NSString stringWithFormat:@"%ld", (long)++self.bury];
        [self disableRateBtn];
    }
}

- (IBAction)commentBtnClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(commentResourceWithSid:)]) {
        [_delegate commentResourceWithSid:self.sid];
    }
}

- (IBAction)shareBtnClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(shareResoureWithSid:imgSid:content:isTopic:)]) {
        [_delegate shareResoureWithSid:self.sid imgSid:nil content:self.content isTopic:self.isTopic];
    }
}

- (void)disableRateBtn {
    self.buryBtn.userInteractionEnabled = NO;
    self.digBtn.userInteractionEnabled = NO;
}

+ (CGFloat)cellBaseHeight {
    return 140.f;
}

@end
