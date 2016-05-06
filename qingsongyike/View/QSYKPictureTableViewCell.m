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

@interface QSYKPictureTableViewCell()
@property (nonatomic, strong) NSURL *URL;

@end

@implementation QSYKPictureTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.separatorHeightCon.constant = 1.0 / [[UIScreen mainScreen] scale];
    
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height / 2;
    self.avatarImageView.layer.masksToBounds = YES;
    
    self.myImageView.backgroundColor = [UIColor lightGrayColor];
    self.myImageView.userInteractionEnabled = YES;
    [self.myImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPicture)]];
    
    [self.digBtn setImage:[UIImage imageNamed:@"mainCellDing"] forState:UIControlStateNormal];
    [self.digBtn setImage:[UIImage imageNamed:@"mainCellDingClick"] forState:UIControlStateSelected];
    [self.buryBtn setImage:[UIImage imageNamed:@"mainCellCai"] forState:UIControlStateNormal];
    [self.buryBtn setImage:[UIImage imageNamed:@"mainCellCaiClick"] forState:UIControlStateSelected];
    
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
    self.progressView.hidden = NO;
    self.showBigPicBtn.hidden = YES;
    [self.digBtn setSelected:NO];
    [self.buryBtn setSelected:NO];
    self.buryBtn.userInteractionEnabled = YES;
    self.digBtn.userInteractionEnabled = YES;
    
//    if (!kIsNetworkViaWiFi && kIsAutoLoadImgOnlyInWifi) {
//        self.tapToDownloadIndicatorLabel.hidden = NO;
//    } else {
//        self.tapToDownloadIndicatorLabel.hidden = YES;
//    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_resource) {
        return;
    }
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[QSYKUtility imgUrl:_resource.userAvatar width:200 height:200 extension:@"png"]] placeholderImage:[UIImage imageNamed:@"icon_avatar"]];
    self.usernameLabel.text = _resource.username;
    self.pubTimeLabel.text = _resource.pubTime;
    self.contentLabel.text = [NSString stringWithFormat:@"%ld赞，%ld踩", _resource.dig, _resource.bury];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:_resource.content];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:TEXT_LING_SPACING];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrString.length)];
    self.contentLabel.attributedText = attrString;
    
    self.URL = [NSURL URLWithString:[QSYKUtility imgUrl:_resource.img.sid
                                                        width:_resource.img.width
                                                       height:_resource.img.height
                                                    extension:_resource.img.extension]];
    
    if (!kIsNetworkViaWiFi && kIsAutoLoadImgOnlyInWifi) {
        self.tapToDownloadIndicatorLabel.hidden = NO;
        
    } else {
        self.tapToDownloadIndicatorLabel.hidden = YES;
        [self downloadWithURL:_URL];
    }
    
//    [self downloadWithURL:URL];
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
                                        //判断是不是大图（暂时定为高 > 宽 * 1.6 时为大图）
                                        if (_resource.img.height > _resource.img.width * 1.6 && !_resource.img.dynamic) {
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
