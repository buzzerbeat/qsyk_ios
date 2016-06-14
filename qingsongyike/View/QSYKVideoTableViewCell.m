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

@interface QSYKVideoTableViewCell() <UIAlertViewDelegate>
@property (nonatomic, strong) KRVideoPlayerController *videoController;

@end

@implementation QSYKVideoTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.separatorHeightCon.constant = 1.0 / [[UIScreen mainScreen] scale];
    
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
    [self reset];
    
    [self.digBtn setSelected:NO];
    [self.buryBtn setSelected:NO];
    self.digCountLabel.textColor = [UIColor lightGrayColor];
    self.buryCountLabel.textColor = [UIColor lightGrayColor];
    self.buryBtn.userInteractionEnabled = YES;
    self.digBtn.userInteractionEnabled = YES;
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
    
    [self.avatarImageView setAvatar:[QSYKUtility imgUrl:_resource.userAvatar width:200 height:200 extension:@"png"]];
    self.usernameLabel.text  = _resource.userName;
    self.digCountLabel.text  = [NSString stringWithFormat:@"%ld", (long)self.dig];
    self.buryCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.bury];

    double videoLength = [self.video.length doubleValue];
    double minutes = floor(videoLength / 60.0);;
    double seconds = floor(fmod(videoLength, 60.0));;
    NSString *time = [NSString stringWithFormat:@"%02.0f:%02.0f", minutes, seconds];
    self.videoLengthLabel.text = [NSString stringWithFormat:@" %@ ", time];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.content];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:TEXT_LING_SPACING];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.length)];
    self.contentLabel.attributedText = attrString;
    
    NSURL *URL = [NSURL URLWithString:[QSYKUtility imgUrl:self.video.thumb
                                                    width:self.video.width
                                                   height:self.video.height
                                                extension:@"jpg"]];
    [[SDWebImageManager sharedManager] downloadImageWithURL:URL
                                                    options:0
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      if (!error && image) {
                                                          self.videoThumbImageView.image = image;
                                                      } else {
                                                          NSLog(@"error = %@", error);
                                                      }
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVideoViewFrame:) name:kVideoViewShrinkedNotification object:nil];
    
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
        self.videoThumbBottomCon.constant = 63 + self.firstGodPostHeight + self.secondGodPostHeight + self.thirdGodPostHeight;
        
    } else {
        self.containerView.hidden = YES;
        self.videoThumbBottomCon.constant = 63;
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
        [_delegate shareResoureWithSid:self.sid imgSid:self.video.thumb content:self.content isTopic:self.isTopic];
    }
}

- (void)disableRateBtn {
    self.buryBtn.userInteractionEnabled = NO;
    self.digBtn.userInteractionEnabled = NO;
}

+ (CGFloat)cellBaseHeight {
    return 157.f;
}

@end
