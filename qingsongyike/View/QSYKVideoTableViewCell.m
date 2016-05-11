//
//  QSYKVideoTableViewCell.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/25/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKVideoTableViewCell.h"
#import "KRVideoPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import <KRVideoPlayerController.h>

@interface QSYKVideoTableViewCell() <UIAlertViewDelegate>
@property (nonatomic, strong) KRVideoPlayerController *videoController;

@end

@implementation QSYKVideoTableViewCell

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
    [self reset];
    
    [self.digBtn setSelected:NO];
    [self.buryBtn setSelected:NO];
    self.buryBtn.userInteractionEnabled = YES;
    self.digBtn.userInteractionEnabled = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_resource) {
        return;
    }
    
    [self.avatarImageView setAvatar:[QSYKUtility imgUrl:_resource.userAvatar width:200 height:200 extension:@"png"]];
    self.usernameLabel.text    = _resource.username;
    self.pubTimeLabel.text     = _resource.pubTime;
    self.videoLengthLabel.text = _resource.video.length;
    self.contentLabel.text = [NSString stringWithFormat:@"%ld赞，%ld踩", _resource.dig, _resource.bury];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:_resource.content];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:TEXT_LING_SPACING];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.length)];
    self.contentLabel.attributedText = attrString;
    
    NSURL *URL = [NSURL URLWithString:[QSYKUtility imgUrl:_resource.video.thumb
                                                    width:_resource.video.width
                                                   height:_resource.video.height
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
                                                  [self playVideoWithURL:[NSURL URLWithString:_resource.video.url]];
                                                  [self.backView addSubview:self.videoController.view];
                                              }];
            
            [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"当前使用数据流量，是否继续？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
            [alertView show];
        }
        
    } else {
        [self playVideoWithURL:[NSURL URLWithString:_resource.video.url]];
        [self.backView addSubview:self.videoController.view];
    }
}

#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self playVideoWithURL:[NSURL URLWithString:_resource.video.url]];
        [self.backView addSubview:self.videoController.view];
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
    return 172.f;
}

@end
