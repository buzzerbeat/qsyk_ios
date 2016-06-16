//
//  QSYKTopicTableViewCell.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/25/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKTopicTableViewCell.h"
#import "QSYKGodPostView.h"

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
    
    self.sid     = _resource.sid;
    self.dig     = _resource.dig;
    self.bury    = _resource.bury;
    self.content = _resource.desc;
    self.isTopic = (_resource.type == 1);
    
    if (_resource.hasDigged) {
        self.digBtn.selected = YES;
        self.digCountLabel.textColor = kCoreColor;
        [self disableRateBtn];
    } else {
        self.digBtn.selected = NO;
        self.digCountLabel.textColor = [UIColor lightGrayColor];
    }
    if (_resource.hasBuried) {
        self.buryBtn.selected = YES;
        self.buryCountLabel.textColor = kCoreColor;
        [self disableRateBtn];
    } else {
        self.buryBtn.selected = NO;
        self.buryCountLabel.textColor = [UIColor lightGrayColor];
    }
    
    if (_flag) {
        self.readTimeLabel.hidden = NO;
        self.readTimeLabel.text = [QSYKUtility formateTimeInterval:_readTime];
    }
    
    // width = content标签左右边距离屏幕左右边的距离的和（如果是iPad，需要再减去两边的空白区域的宽度）
    CGFloat width = kIsIphone ? SCREEN_WIDTH - 8 * 4 : SCREEN_WIDTH * 2 / 3 - 8 * 4;
    
    // 解决cell的contentView不随着cell高度的变化而变化（原因未找到）
    CGFloat contentViewHeight = [QSYKUtility heightForMutilLineLabel:self.content
                                                              font:16.f
                                                             width:width] + 140 ;
    if (_resource.godPosts.count && !self.isInnerPage) {
        NSUInteger postCount = _resource.godPosts.count;
        CGFloat postHeight = [QSYKGodPostView baseHeight] * postCount;
        if (postCount) {
            for (int i = 0; i < postCount; i++) {
                QSYKPostModel *post = _resource.godPosts[i];
                postHeight += [QSYKUtility heightForMutilLineLabel:post.content font:14 width:[QSYKGodPostView contentWidth]];
            }
        }
        contentViewHeight += postHeight;
    }
    self.contentView.height = contentViewHeight;
    
    [self.avatarImageView setAvatar:[QSYKUtility imgUrl:_resource.userAvatar width:200 height:200 extension:@"png"]];
    self.usernameLabe.text = _resource.userName;
    self.digCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.dig];
    self.buryCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.bury];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.content];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:TEXT_LING_SPACING];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.length)];
    self.contentLabel.attributedText = attrString;
    
    for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
    }
    
    if (_resource.godPosts.count && !self.isInnerPage) {
        for (int i = 0; i < _resource.godPosts.count; i++) {
            QSYKGodPostView *postView = [[NSBundle mainBundle] loadNibNamed:@"QSYKGodPostView" owner:nil options:nil][0];
            QSYKPostModel *post = (QSYKPostModel *)_resource.godPosts[i];
            postView.post = post;
            postView.delegate = _delegate;
            postView.indexPath = _indexPath;
            postView.index = i;
            
            CGFloat height = 0;
            if (i == 0) {
                self.firstGodPostHeight = [QSYKGodPostView baseHeight] + [QSYKUtility heightForMutilLineLabel:post.content font:14 width:[QSYKGodPostView contentWidth]];
            } else if (i == 1) {
                self.secondGodPostHeight = [QSYKUtility heightForMutilLineLabel:post.content font:14 width:[QSYKGodPostView contentWidth]];
                height = self.firstGodPostHeight;
                
            } else if (i == 2) {
                self.thirdGodPostHeight = [QSYKGodPostView baseHeight] + [QSYKUtility heightForMutilLineLabel:post.content font:14 width:[QSYKGodPostView contentWidth]];
                
                height = self.firstGodPostHeight + self.secondGodPostHeight;
            }
            
            [self.containerView addSubview:postView];
            [postView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.containerView.mas_left);
                make.right.equalTo(self.containerView.mas_right);
                make.top.equalTo(self.containerView).offset(height);
                make.height.offset([QSYKGodPostView baseHeight] + [QSYKUtility heightForMutilLineLabel:post.content font:14 width:[QSYKGodPostView contentWidth]]);
            }];
        }
        
        self.containerView.hidden = NO;
        
    } else {
        self.containerView.hidden = YES;
    }

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
