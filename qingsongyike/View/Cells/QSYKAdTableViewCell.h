//
//  QSYKAdTableViewCell.h
//  qingsongyike
//
//  Created by 苗慧宇 on 6/27/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GDTNativeAdData;

#define kCellIdentifier_adCell @"QSYKAdTableViewCell"

@interface QSYKAdTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *separatorHeightCons;

- (void)setupWithGDTAd:(GDTNativeAdData *)anAd;

+ (CGFloat)cellBaseHeight;

@end
