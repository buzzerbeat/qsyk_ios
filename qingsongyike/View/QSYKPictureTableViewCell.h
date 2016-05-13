//
//  QSYKPictureTableViewCell.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSYKCellDelegate.h"
@class FLAnimatedImageView;
@class QSYKResourceModel;
@class DALabeledCircularProgressView;

#define kCellIdentifier_pictureCell @"QSYKPictureTableViewCell"

//@protocol QSYKPictureCellDelegate <NSObject>
//
//- (void)rateResourceWithSid:(NSString *)sid type:(NSInteger)type;
//- (void)commentResource;
//- (void)shareResoure;
//
//@end

@interface QSYKPictureTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pubTimeLabel;
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

@property (nonatomic, weak) id<QSYKCellDelegate> delegate;
@property (nonatomic, strong) QSYKResourceModel *resource;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic) BOOL isInnerPage;

+ (CGFloat)cellBaseHeight;

@end
