//
//  QSYKGodPostView.m
//  qingsongyike
//
//  Created by 苗慧宇 on 5/31/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKGodPostView.h"

@interface QSYKGodPostView()
@property (nonatomic, assign) int dig;

@end

@implementation QSYKGodPostView

- (void)awakeFromNib {
    [self.digBtn setImage:[UIImage imageNamed:@"comment_dig_gray"] forState:UIControlStateNormal];
    [self.digBtn setImage:[UIImage imageNamed:@"comment_dig_red"] forState:UIControlStateSelected];
    self.separatorHeightCon.constant = 1.0 / [UIScreen mainScreen].scale;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_post) {
        return;
    }
    
    self.dig = _post.dig;
    [self.avatarImageView setAvatar:[QSYKUtility imgUrl:_post.userAvatar width:200 height:200 extension:@"png"]];
    self.usernameLabel.text = _post.userName;
    self.digCountLabel.text = [NSString stringWithFormat:@"%d", _post.dig];
    
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
    self.contentLabel.attributedText = attrString;
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
        [_delegate ratePostWithSid:_post.sid indexPath:[NSIndexPath indexPathForRow:_index inSection:_indexPath.row]];
    }
    
    self.digCountLabel.text = [NSString stringWithFormat:@"%d", self.dig];
    self.digCountLabel.textColor = kCoreColor;
}

+ (CGFloat)baseHeight {
    return 46;
}

+ (CGFloat)contentWidth {
    // contentLabel leadingCon=45,traingCon=15,superView leading(10) + traing(10)
    return kIsIphone ? SCREEN_WIDTH - (45 + 15 + TWO_SIDE_SPACES) : SCREEN_WIDTH * 2 / 3 - (45 + 15 + TWO_SIDE_SPACES) ;
}

@end
