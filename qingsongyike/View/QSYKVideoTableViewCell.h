//
//  QSYKVideoTableViewCell.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/25/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKBaseTableViewCell.h"

#define kCellIdentifier_videoCell @"QSYKVideoTableViewCell"

@interface QSYKVideoTableViewCell : QSYKBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoThumbImageView;
@property (weak, nonatomic) IBOutlet UIButton *playVideoBtn;
@property (weak, nonatomic) IBOutlet UILabel *videoLengthLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightCon;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *digBtn;
@property (weak, nonatomic) IBOutlet UILabel *digCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *buryBtn;
@property (weak, nonatomic) IBOutlet UILabel *buryCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

@property (nonatomic, weak) id<QSYKCellDelegate> delegate;
//@property (nonatomic, strong) QSYKResourceModel *resource;
@property (nonatomic, strong) id resource;
@property (nonatomic, assign) BOOL flag;    // 标识是否显示在收藏、赞 页面
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)reset;
+ (CGFloat)cellBaseHeight;

@end

