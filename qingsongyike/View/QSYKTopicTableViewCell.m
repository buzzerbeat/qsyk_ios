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
    
    [self.digBtn setImage:[UIImage imageNamed:@"mainCellDing"] forState:UIControlStateNormal];
    [self.digBtn setImage:[UIImage imageNamed:@"mainCellDingClick"] forState:UIControlStateSelected];
    [self.buryBtn setImage:[UIImage imageNamed:@"mainCellCai"] forState:UIControlStateNormal];
    [self.buryBtn setImage:[UIImage imageNamed:@"mainCellCaiClick"] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.digBtn setSelected:NO];
    [self.buryBtn setSelected:NO];
    self.buryBtn.userInteractionEnabled = YES;
    self.digBtn.userInteractionEnabled = YES;
}

- (void)layoutSubviews {
    if (!_resource) {
        return;
    }
    
    [self.avatarImageView setAvatar:[QSYKUtility imgUrl:_resource.userAvatar width:200 height:200 extension:@"png"]];
    self.usernameLabe.text = _resource.username;
    self.pubTimeLabel.text = _resource.pubTime;
    self.contentLabel.text = [NSString stringWithFormat:@"%ld赞，%ld踩", _resource.dig, _resource.bury];
    
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
        [self disableRateBtn];
    }
}

- (IBAction)buryBtnClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(rateResourceWithSid:type:indexPath:)]) {
        [_delegate rateResourceWithSid:_resource.sid type:2 indexPath:_indexPath];
        [self.buryBtn setSelected:YES];
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
    return 160.f;
}

@end
