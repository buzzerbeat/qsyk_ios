//
//  QSYKVideoTableViewCell.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/25/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKVideoTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "KRVideoPlayerController.h"
#import "QSYKGodPostView.h"

static CGFloat TAG_VIEW_BOTTOM_BASE_SPACE = 0;

@interface QSYKVideoTableViewCell() <UIAlertViewDelegate>
@property (nonatomic, strong) KRVideoPlayerController *videoController;

@end

@implementation QSYKVideoTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
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
    [self reset];
    
    self.digImageView.image = [UIImage imageNamed:@"resource_ico_dig_gray"];
    self.buryImageView.image = [UIImage imageNamed:@"resource_ico_bury_gray"];
    self.digCountLabel.textColor = [UIColor lightGrayColor];
    self.buryCountLabel.textColor = [UIColor lightGrayColor];
    self.digView.userInteractionEnabled = YES;
    self.buryView.userInteractionEnabled = YES;
    
    self.videoThumbImageView.image = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_resource) {
        return;
    }
    
    self.sid     = _resource.sid;
    self.dig     = _resource.dig;
    self.bury    = _resource.bury;
    self.video   = _resource.relVideo;
    self.content = _resource.desc;
    self.isTopic = (_resource.type == 1);
    
    if (_resource.hasDigged) {
        [self disableDigAction];
    }
    
    if (_resource.hasBuried) {
        [self disableBuryAction];
    }
    
    if (_flag) {
        self.readTimeLabel.hidden = NO;
        self.readTimeLabel.text = [QSYKUtility formateTimeInterval:_readTime];
    }
    
    [self.avatarImageView setAvatar:[QSYKUtility imgUrl:_resource.userAvatar width:200 height:200 extension:@"png"]];
    self.usernameLabel.text  = _resource.userName;
    self.digCountLabel.text  = [NSString stringWithFormat:@"%ld", (long)self.dig];
    self.buryCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.bury];
    self.postCountLabel.text = [NSString stringWithFormat:@"%d", _resource.post];
    
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
    
 
    double videoLength = [self.video.length doubleValue];
    double minutes = floor(videoLength / 60.0);;
    double seconds = floor(fmod(videoLength, 60.0));;
    NSString *time = [NSString stringWithFormat:@"%02.0f:%02.0f", minutes, seconds];
    self.videoLengthLabel.text = [NSString stringWithFormat:@" %@ ", time];
    self.contentLabel.attributedText = [QSYKUtility attrStringWithString:self.content];
    
    
    NSURL *URL = [NSURL URLWithString:[QSYKUtility imgUrl:self.video.thumb
                                                    width:self.video.width
                                                   height:self.video.height
                                                extension:@"jpg"]];
    
    [self.videoThumbImageView sd_setImageWithURL:URL placeholderImage:[UIImage new]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVideoViewFrame:) name:kVideoViewShrinkedNotification object:nil];
    
    for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
    }
    
    
    self.tagViewBottomCon.constant = 0;
    self.firstGodPostHeight = self.secondGodPostHeight = self.thirdGodPostHeight = 0;
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
        self.tagViewBottomCon.constant += self.firstGodPostHeight + self.secondGodPostHeight + self.thirdGodPostHeight;
        
    } else {
        self.containerView.hidden = YES;
    }

}

- (IBAction)playVideoBtnClicked:(id)sender {
    if (!kIsNetworkViaWiFi && kIsAutoLoadImgOnlyInWifi) {
        if (SYSTEM_VERSION >= 8.0) {
            UIAlertController *alert =
                [QSYKUtility alertControllerWithTitle:nil
                                              message:@"当前使用数据流量，是否继续？" cancleActionTitle:@"取消"
                                        goActionTitle:@"继续"
                                       preferredStyle:UIAlertControllerStyleAlert
                                              handler:^(UIAlertAction * _Nonnull action) {
                                                  [self playVideoWithURL:[NSURL URLWithString:self.video.url]];
                                                  [self.backView addSubview:self.videoController.view];
                                              }];
            
            [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"当前使用数据流量，是否继续？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
            [alertView show];
        }
        
    } else {
        [self playVideoWithURL:[NSURL URLWithString:self.video.url]];
        [self.backView addSubview:self.videoController.view];
//        if (!kIsIphone) {
//            [self.videoController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.edges.equalTo(self.videoThumbImageView);
//            }];
//        }
    }
}

#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self playVideoWithURL:[NSURL URLWithString:self.video.url]];
        [self.backView addSubview:self.videoController.view];
//        if (!kIsIphone) {
//            [self.videoController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.edges.equalTo(self.videoThumbImageView);
//            }];
//        }
    }
}

- (void)playVideoWithURL:(NSURL *)url {
    if (!self.videoController) {
        self.videoController = [[KRVideoPlayerController alloc] initWithFrame:self.videoThumbImageView.frame];
        @weakify(self);
        [self.videoController setDimissCompleteBlock:^{
            @strongify(self);
            self.videoController = nil;
        }];
    }
    self.videoController.contentURL = url;
}

//停止视频的播放
- (void)reset {
    [self.videoController dismiss];
    self.videoController = nil;
}

- (void)updateVideoViewFrame:(NSNotification *)noti {
//    if (!self.videoController.videoControl.isFullscreen) {
        self.videoController.frame = self.videoThumbImageView.frame;
        [self.backView layoutSubviews];
        
//    }
}

- (void)removeConstraintForVideo {
    if (!(kIsIphone)) {
        [self.videoController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        }];
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
    return 158.f;
}

@end
