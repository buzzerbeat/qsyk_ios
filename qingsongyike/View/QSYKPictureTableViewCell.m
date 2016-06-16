//
//  QSYKPictureTableViewCell.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKPictureTableViewCell.h"
#import "QSYKResourceModel.h"
#import "QSYKDetailPicutreViewController.h"
#import <DALabeledCircularProgressView.h>
#import "QSYKGodPostView.h"

@interface QSYKPictureTableViewCell()
@property (nonatomic, strong) NSURL *URL;

@end

@implementation QSYKPictureTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.separatorHeightCon.constant = 1.0 / [[UIScreen mainScreen] scale];
    
    self.myImageView.backgroundColor = [UIColor lightGrayColor];
    self.myImageView.userInteractionEnabled = YES;
    [self.myImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPicture)]];
    
    [self.digBtn setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateNormal];
    [self.digBtn setImage:[UIImage imageNamed:@"icon_like_pressed"] forState:UIControlStateSelected];
    [self.buryBtn setImage:[UIImage imageNamed:@"icon_dislike"] forState:UIControlStateNormal];
    [self.buryBtn setImage:[UIImage imageNamed:@"icon_dislike_pressed"] forState:UIControlStateSelected];
    
    self.tapToDownloadIndicatorLabel.userInteractionEnabled = YES;
    [self.tapToDownloadIndicatorLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTODownload)]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.myImageView.image = nil;
    self.avatarImageView.image = nil;
    self.progressView.hidden = YES;
    self.showBigPicBtn.hidden = YES;
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
    self.img     = _resource.relImage;
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
    
    self.progressView.hidden = YES;
    [self.avatarImageView setAvatar:[QSYKUtility imgUrl:_resource.userAvatar width:200 height:200 extension:@"png"]];
    self.usernameLabel.text = _resource.userName;
    self.digCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_resource.dig];
    self.buryCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_resource.bury];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.content];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:TEXT_LING_SPACING];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.length)];
    self.contentLabel.attributedText = attrString;
    
    // 神评论相关
    for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
        self.firstGodPostHeight = self.secondGodPostHeight = self.thirdGodPostHeight = 0;
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
                self.secondGodPostHeight = [QSYKGodPostView baseHeight] +  [QSYKUtility heightForMutilLineLabel:post.content font:14 width:[QSYKGodPostView contentWidth]];
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
        self.imageViewBottomCon.constant = 63 + self.firstGodPostHeight + self.secondGodPostHeight + self.thirdGodPostHeight;
        
    } else {
        self.containerView.hidden = YES;
        self.imageViewBottomCon.constant = 63;
    }
    
//    [self layoutIfNeeded];
    
    self.URL = [NSURL URLWithString:[QSYKUtility imgUrl:self.img.sid
                                                  width:self.img.width
                                                 height:self.img.height
                                              extension:self.img.extension]];
    
    if (!kIsNetworkViaWiFi && kIsAutoLoadImgOnlyInWifi) {
        self.tapToDownloadIndicatorLabel.hidden = NO;
        
    } else {
        self.tapToDownloadIndicatorLabel.hidden = YES;
        [self downloadWithURL:_URL];
    }
}

- (void)tapTODownload {
    self.tapToDownloadIndicatorLabel.hidden = YES;
    [self downloadWithURL:_URL];
}

- (void)downloadWithURL:(NSURL *)URL {
    [self.myImageView sd_setImageWithURL:URL placeholderImage:nil options:0
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    self.showBigPicBtn.hidden = YES;
                                    CGFloat progress = 1.0 * receivedSize / expectedSize;
                                    self.progressView.hidden = NO;
                                    self.progressView.progressLabel.textColor = [UIColor whiteColor];
                                    self.progressView.roundedCorners = 2;
                                    self.progressView.progressLabel.text =
                                    [NSString stringWithFormat:@"%.1f%%",  (progress > 0 ? progress : -1 * progress)*100];
                                    [self.progressView setProgress:progress animated:YES];
                                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    self.progressView.hidden = YES;
                                    if (!error) {
                                        //判断是不是大图（暂时定为高 > 宽 * 2 时为大图）
                                        if (self.img.height > self.img.width * 2 && !self.img.dynamic && !self.isInnerPage) {
                                            //如果是的话，则截出图片的最上方铺满imageView
                                            // 开启图形上下文
                                            //                                            UIGraphicsBeginImageContextWithOptions(self.myImageView.size, YES, 0.0);
                                            UIGraphicsBeginImageContext(self.myImageView.size);
                                            // 将下载完的image对象绘制到图形上下文
                                            CGFloat width = self.myImageView.width;
                                            CGFloat height = width * image.size.height / image.size.width;
                                            [image drawInRect:CGRectMake(0, 0, width, height)];
                                            // 获得图片
                                            self.myImageView.image = UIGraphicsGetImageFromCurrentImageContext();
                                            // 结束图形上下文
                                            UIGraphicsEndImageContext();
                                            self.showBigPicBtn.hidden = NO;
                                        } else {
                                            self.myImageView.contentMode = UIViewContentModeScaleToFill;
                                            self.showBigPicBtn.hidden = YES;
                                        }
                                    } else {
                                        NSLog(@"error = %@", error);
                                    }
                                }];
}


- (IBAction)showBigPicBtnClicked:(id)sender {
    [self showPicture];
}

-(void)showPicture {
    
    QSYKDetailPicutreViewController *showPicVc = [[QSYKDetailPicutreViewController alloc]init];
    showPicVc.resource = _resource;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:showPicVc animated:YES completion:nil];
    
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
        [_delegate shareResoureWithSid:self.sid imgSid:self.img.sid content:self.content isTopic:self.isTopic];
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
