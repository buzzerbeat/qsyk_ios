//
//  QSYKPictureTableViewCell.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKBaseTableViewCell.h"
@class FLAnimatedImageView;
@class QSYKResourceModel;
@class DALabeledCircularProgressView;

#define kCellIdentifier_pictureCell @"QSYKPictureTableViewCell"

@interface QSYKPictureTableViewCell : QSYKBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UIButton *digBtn;
@property (weak, nonatomic) IBOutlet UILabel *digCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *buryBtn;
@property (weak, nonatomic) IBOutlet UILabel *buryCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightCon;
@property (weak, nonatomic) IBOutlet UIButton *showBigPicBtn;
@property (weak, nonatomic) IBOutlet DALabeledCircularProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *tapToDownloadIndicatorLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBottomCon;

@property (nonatomic, weak) id<QSYKCellDelegate> delegate;
@property (nonatomic, strong) QSYKResourceModel *resource;
@property (nonatomic) BOOL flag;
@property (nonatomic, strong) NSIndexPath *indexPath;

+ (CGFloat)cellBaseHeight;

@end
