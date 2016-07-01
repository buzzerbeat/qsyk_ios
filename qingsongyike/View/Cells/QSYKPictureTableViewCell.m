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
#import <FLAnimatedImage.h>
#import "QSYKGodPostView.h"

static CGFloat IMAGE_BOTTOM_BASE_SPACE = 0;

@interface QSYKPictureTableViewCell()
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) UIImage *image;

@end

@implementation QSYKPictureTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.postCountLabel.textColor = kTextGrayColor;
    self.usernameLabel.textColor = kUsernameColor;
    
    for (NSLayoutConstraint *con in self.separatorHeightCons) {
        con.constant = ONE_PIX;
    }
    
    // 底部四个操作功能相关
    [self.digView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(digViewTapped)]];
    [self.buryView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buryViewTapped)]];
    [self.deleteView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteViewTapped)]];
    [self.shareView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareViewTapped)]];
    
    // 图片显示、全屏及非wifi点击加载功能相关
    self.myImageView.backgroundColor = [UIColor lightGrayColor];
    self.myImageView.userInteractionEnabled = YES;
    [self.myImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPicture)]];
    
    self.tapToDownloadIndicatorLabel.userInteractionEnabled = YES;
    [self.tapToDownloadIndicatorLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTODownload)]];
    
    
    // 标签功能相关
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
    
    self.progressView.hidden = YES;
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
    self.usernameLabel.text = _resource.userName;
    self.digCountLabel.text = [NSString stringWithFormat:@"%d", _resource.dig];
    self.buryCountLabel.text = [NSString stringWithFormat:@"%d", _resource.bury];
    self.contentLabel.attributedText = [QSYKUtility attrStringWithString:self.content];
    
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
    
    
    // 神评论相关
    for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
        self.firstGodPostHeight = self.secondGodPostHeight = self.thirdGodPostHeight = 0;
    }
    
    self.tagContainerViewBottomCon.constant = 0;
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
                self.secondGodPostHeight = [QSYKGodPostView baseHeight] +  [QSYKUtility heightForMutilLineLabel:post.content font:TEXT_FONT width:[QSYKGodPostView contentWidth]];
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
        self.tagContainerViewBottomCon.constant = self.firstGodPostHeight + self.secondGodPostHeight + self.thirdGodPostHeight;
        
    } else {
        self.containerView.hidden = YES;
    }
    
    
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
    @weakify(self);
    [self.myImageView sd_setImageWithURL:URL placeholderImage:nil options:0
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    @strongify(self);
                                    self.showBigPicBtn.hidden = YES;
                                    
                                    CGFloat progress = 1.0 * receivedSize / expectedSize;
                                    self.progressView.hidden = NO;
                                    self.progressView.progressLabel.textColor = [UIColor whiteColor];
                                    self.progressView.roundedCorners = 2;
                                    self.progressView.progressLabel.text =
                                    [NSString stringWithFormat:@"%.1f%%",  (progress > 0 ? progress : -1 * progress)*100];
                                    [self.progressView setProgress:progress animated:YES];
                                
                                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    @strongify(self);
                                    
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
                                        } else {//if (self.img.dynamic) {
                                            self.myImageView.contentMode = UIViewContentModeScaleToFill;
                                            self.myImageView.image = image;
                                            self.showBigPicBtn.hidden = YES;
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                self.progressView.hidden = YES;
                                                self.showBigPicBtn.hidden = YES;
                                            });
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
            } else if (CGRectContainsPoint(self.containerView.frame, p)) {
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
    return 160.f;
}

@end
