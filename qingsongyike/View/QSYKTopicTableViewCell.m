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
    
    // 解决cell的contentView不随着cell高度的变化而变化（原因未找到）
    self.contentView.height = [QSYKUtility heightForMutilLineLabel:_resource.content
                                                              font:16.f
                                                             width:SCREEN_WIDTH - 8 * 4] + 140 ;
    
    [self.avatarImageView setAvatar:[QSYKUtility imgUrl:_resource.userAvatar width:200 height:200 extension:@"png"]];
    self.usernameLabe.text = _resource.username;
    self.pubTimeLabel.text = _resource.pubTime;
    self.digCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_resource.dig];
    self.buryCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_resource.bury];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:_resource.content];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:TEXT_LING_SPACING];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.length)];
    self.contentLabel.attributedText = attrString;
}

- (IBAction)digBtnClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(rateResourceWithSid:type:indexPath:)]) {
        [_delegate rateResourceWithSid:_resource.sid type:1 indexPath:_indexPath];
        [self.digBtn setSelected:YES];
        self.digCountLabel.textColor = kCoreColor;
        self.digCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_resource.dig];
        [self disableRateBtn];
    }
}

- (IBAction)buryBtnClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(rateResourceWithSid:type:indexPath:)]) {
        [_delegate rateResourceWithSid:_resource.sid type:2 indexPath:_indexPath];
        [self.buryBtn setSelected:YES];
        self.buryCountLabel.textColor = kCoreColor;
        self.buryCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_resource.bury];
        [self disableRateBtn];
    }
}

- (IBAction)commentBtnClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(commentResourceWithSid:)]) {
        [_delegate commentResourceWithSid:_resource.sid];
    }
}

- (IBAction)shareBtnClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(shareResoureWithSid:content:)]) {
        [_delegate shareResoureWithSid:_resource.sid content:_resource.content];
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
