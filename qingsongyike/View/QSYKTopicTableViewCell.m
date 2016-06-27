//
//  QSYKTopicTableViewCell.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/25/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKTopicTableViewCell.h"
#import "QSYKGodPostView.h"

static CGFloat TEXT_BOTTOM_BASE_SPACE = 0;

@implementation QSYKTopicTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentLabel setNumberOfLines:0];
    self.postCountLabel.textColor = kTextGrayColor;
    self.usernameLabel.textColor = kUsernameColor;
    
    for (NSLayoutConstraint *con in self.separatorHeightCons) {
        con.constant = ONE_PIX;
    }
    
    [self.digView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(digViewTapped)]];
    [self.buryView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buryViewTapped)]];
    [self.deleteView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteViewTapped)]];
    [self.shareView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareViewTapped)]];

    [self.tagContainerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagViewTapped:)]];
    
    // 点击神评论进入详情页时定位到评论位置
    [self.containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(godPostViewTapped:)]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.digImageView.image = [UIImage imageNamed:@"resource_ico_dig_gray"];
    self.buryImageView.image = [UIImage imageNamed:@"resource_ico_bury_gray"];
    self.digCountLabel.textColor = [UIColor lightGrayColor];
    self.buryCountLabel.textColor = [UIColor lightGrayColor];
    self.digView.userInteractionEnabled = YES;
    self.buryView.userInteractionEnabled = YES;
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
        [self disableDigAction];
    }
    
    if (_resource.hasBuried) {
        [self disableBuryAction];
    }
    
    // 最近浏览 模块需要展示阅读时间
    if (_flag) {
        self.readTimeLabel.hidden = NO;
        self.readTimeLabel.text = [QSYKUtility formateTimeInterval:_readTime];
    }
    
    // width = content标签左右边距离屏幕左右边的距离(10)的和（如果是iPad，需要再减去两边的空白区域的宽度）
    CGFloat width = kIsIphone ? SCREEN_WIDTH - TWO_SIDE_SPACES : SCREEN_WIDTH * 2 / 3 - TWO_SIDE_SPACES;
    
    // 解决cell的contentView不随着cell高度的变化而变化（原因未找到）
    CGFloat contentViewHeight = [QSYKUtility heightForMutilLineLabel:self.content
                                                                font:TEXT_FONT
                                                               width:width] + [QSYKTopicTableViewCell cellBaseHeight];
    
    if (_resource.godPosts.count && !self.isInnerPage) {
        NSUInteger postCount = _resource.godPosts.count;
        CGFloat postHeight = [QSYKGodPostView baseHeight] * postCount;
        if (postCount) {
            for (int i = 0; i < postCount; i++) {
                QSYKPostModel *post = _resource.godPosts[i];
                postHeight += [QSYKUtility heightForMutilLineLabel:post.content font:TEXT_FONT width:[QSYKGodPostView contentWidth]];
            }
        }
        contentViewHeight += postHeight;
    }
    self.contentView.height = contentViewHeight;
    
    if (self.isInnerPage) {
        self.postImageView.hidden = YES;
        self.postCountLabel.hidden = YES;
        self.deleteImageView.hidden = YES;
        self.commentImageView.hidden = NO;
        self.commentCountLabel.hidden = NO;
        self.commentCountLabel.text = [NSString stringWithFormat:@"%d", _resource.post];
    } else {
        self.postImageView.hidden = NO;
        self.postCountLabel.hidden = NO;
        self.deleteImageView.hidden = NO;
        self.commentImageView.hidden = YES;
        self.commentCountLabel.hidden = YES;
    }
    
    
    [self.avatarImageView setAvatar:[QSYKUtility imgUrl:_resource.userAvatar width:200 height:200 extension:@"png"]];
    self.usernameLabel.text = _resource.userName;
    self.digCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.dig];
    self.buryCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.bury];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.content];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:TEXT_LING_SPACING];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.length)];
    self.contentLabel.attributedText = attrString;
    self.postCountLabel.text = [NSString stringWithFormat:@"%d", _resource.post];
    
    // 标签相关
    self.firstTagLabel.text = nil;
    self.secondTagLabel.text = nil;
    self.thirdTagLabel.text = nil;
    
    NSArray *tags = _resource.tags;
    if (tags && tags.count) {
        self.tagImageView.hidden = NO;
        
        for (int i = 0; i < tags.count; i++) {
            QSYKTagModel *tag = _resource.tags[i];
            NSString *tagName = tag.name;
            
            if (i == 0) {
                self.firstTagLabel.text = tagName;
            } else if (i == 1) {
                self.secondTagLabel.text = tagName;
            } else if (i == 2) {
                self.thirdTagLabel.text = tagName;
            }
        }
        
    } else {
        self.tagImageView.hidden = YES;
    }
    
    
    for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
    }
    
    self.tagContainerViewBottomCon.constant = 0;
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
                self.firstGodPostHeight = [QSYKGodPostView baseHeight] + [QSYKUtility heightForMutilLineLabel:post.content font:TEXT_FONT width:[QSYKGodPostView contentWidth]];
            } else if (i == 1) {
                self.secondGodPostHeight = [QSYKGodPostView baseHeight] + [QSYKUtility heightForMutilLineLabel:post.content font:TEXT_FONT width:[QSYKGodPostView contentWidth]];
                height = self.firstGodPostHeight;
                
            } else if (i == 2) {
                self.thirdGodPostHeight = [QSYKGodPostView baseHeight] + [QSYKUtility heightForMutilLineLabel:post.content font:TEXT_FONT width:[QSYKGodPostView contentWidth]];
                
                height = self.firstGodPostHeight + self.secondGodPostHeight;
            }
            
            [self.containerView addSubview:postView];
            [postView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.containerView.mas_left);
                make.right.equalTo(self.containerView.mas_right);
                make.top.equalTo(self.containerView).offset(height);
                make.height.offset([QSYKGodPostView baseHeight] + [QSYKUtility heightForMutilLineLabel:post.content font:TEXT_FONT width:[QSYKGodPostView contentWidth]]);
            }];
        }
        
        self.containerView.hidden = NO;
        self.tagContainerViewBottomCon.constant += self.firstGodPostHeight + self.secondGodPostHeight + self.thirdGodPostHeight;
    } else {
        self.containerView.hidden = YES;
    }

}


- (void)digViewTapped {
    if (_resource.hasBuried || _resource.hasDigged) {
        return;
    }
    
    self.digImageView.image = [UIImage imageNamed:@"resource_ico_ding_red"];
    self.digCountLabel.textColor = kCoreColor;
    self.digCountLabel.text = [NSString stringWithFormat:@"%ld", (long)++self.dig];
    
    if (_delegate && [_delegate respondsToSelector:@selector(rateResourceWithSid:type:indexPath:)]) {
        [_delegate rateResourceWithSid:self.sid type:1 indexPath:_indexPath];
    }
}

- (void)buryViewTapped {
    if (_resource.hasBuried || _resource.hasDigged) {
        return;
    }
    
    self.buryImageView.image = [UIImage imageNamed:@"resource_ico_bury_red"];
    self.buryCountLabel.textColor = kCoreColor;
    self.buryCountLabel.text = [NSString stringWithFormat:@"%ld", (long)++self.bury];
    
    if (_delegate && [_delegate respondsToSelector:@selector(rateResourceWithSid:type:indexPath:)]) {
        [_delegate rateResourceWithSid:self.sid type:2 indexPath:_indexPath];
    }
}

- (void)shareViewTapped {
    if (_delegate && [_delegate respondsToSelector:@selector(shareResoureWithSid:imgSid:content:isTopic:)]) {
        [_delegate shareResoureWithSid:self.sid imgSid:nil content:self.content isTopic:self.isTopic];
    }
}

- (void)deleteViewTapped {
    if (_delegate && [_delegate respondsToSelector:@selector(deleteResourceAtIndexPath:)]) {
        [_delegate deleteResourceAtIndexPath:_indexPath];
    }
}

- (void)disableDigAction {
    self.digCountLabel.textColor = kCoreColor;
    self.digImageView.image = [UIImage imageNamed:@"resource_ico_ding_red"];
}

- (void)disableBuryAction {
    self.buryCountLabel.textColor = kCoreColor;
    self.buryImageView.image = [UIImage imageNamed:@"resource_ico_bury_red"];
}

- (void)tagViewTapped:(UITapGestureRecognizer *)gest {
    if (_delegate) {
        CGPoint p = [gest locationInView:self.tagContainerView];
        
        if ([_delegate respondsToSelector:@selector(tagTappedWithInfo:)]) {
            if (CGRectContainsPoint(self.firstTagLabel.frame, p)) {
                [_delegate tagTappedWithInfo:_resource.tags[0]];
                return;
            } else if (CGRectContainsPoint(self.secondTagLabel.frame, p)) {
                [_delegate tagTappedWithInfo:_resource.tags[1]];
                return;
            } else if (CGRectContainsPoint(self.thirdTagLabel.frame, p)) {
                [_delegate tagTappedWithInfo:_resource.tags[2]];
                return;
            }
        }
        
        if ([_delegate respondsToSelector:@selector(locatePostAtIndexPath:)]) {
            if (CGRectContainsPoint(self.postCoverView.frame, p)) {
                [_delegate locatePostAtIndexPath:_indexPath];
            }
        }
    }
}

- (void)godPostViewTapped:(UITapGestureRecognizer *)gest {
    if (_delegate && [_delegate respondsToSelector:@selector(locatePostAtIndexPath:)]) {
        [_delegate locatePostAtIndexPath:_indexPath];
    }
}


+ (CGFloat)cellBaseHeight {
    return 140.f;
}

@end
