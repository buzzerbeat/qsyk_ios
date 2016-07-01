//
//  QSYKAdTableViewCell.m
//  qingsongyike
//
//  Created by 苗慧宇 on 6/27/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKAdTableViewCell.h"
#import <GDTNativeAd.h>

@implementation QSYKAdTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.iconImageView.layer.cornerRadius = self.iconImageView.height / 2;
    self.iconImageView.layer.masksToBounds = YES;
    
    self.actionBtn.layer.cornerRadius = 3.f;
    self.actionBtn.layer.masksToBounds = YES;
    
    for (NSLayoutConstraint *con in self.separatorHeightCons) {
        con.constant = ONE_PIX;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithGDTAd:(GDTNativeAdData *)anAd {
    if (!anAd) {
        return;
    }
    
    NSURL *bannerImgURL = [NSURL URLWithString:anAd.properties[@"img"]];
    [self.bannerImageView sd_setImageWithURL:bannerImgURL placeholderImage:[UIImage new]];
    
    NSURL *iconURL = [NSURL URLWithString:anAd.properties[@"icon"]];
    [self.iconImageView sd_setImageWithURL:iconURL placeholderImage:[UIImage new]];
    
    self.nameLabel.text = anAd.properties[@"title"];
    self.descLabel.attributedText = [QSYKUtility attrStringWithString:anAd.properties[@"desc"]];
    [self.actionBtn setTitle:@"去看看" forState:UIControlStateNormal];
}

+ (CGFloat)cellBaseHeight {
    CGFloat width = SCREEN_WIDTH - AD_TWO_SIDE_SPACES;
    
    return 120 + width * 9 / 16;
}

@end
