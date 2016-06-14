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
    [self.digBtn setImage:[UIImage imageNamed:@"commentLikeButton"] forState:UIControlStateNormal];
    [self.digBtn setImage:[UIImage imageNamed:@"commentLikeButtonClick"] forState:UIControlStateSelected];
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
    [style setLineSpacing:TEXT_LING_SPACING];
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
}

+ (CGFloat)baseHeight {
    return 58;
}

+ (CGFloat)contentWidth {
    // contentLabel leadingCon=43,traingCon=40,superView leading(8+8) + traing(8+8) 
    return SCREEN_WIDTH - (43 + 40 + 8 * 4);
}

@end
