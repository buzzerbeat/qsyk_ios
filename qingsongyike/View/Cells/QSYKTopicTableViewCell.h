//
//  QSYKTopicTableViewCell.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/25/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKBaseTableViewCell.h"
@class QSYKResourceModel;

#define kCellIdentifier_topicCell @"QSYKTopicTableViewCell"


@interface QSYKTopicTableViewCell : QSYKBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *digView;
@property (weak, nonatomic) IBOutlet UIImageView *digImageView;
@property (weak, nonatomic) IBOutlet UILabel *digCountLabel;
@property (weak, nonatomic) IBOutlet UIView *buryView;
@property (weak, nonatomic) IBOutlet UIImageView *buryImageView;
@property (weak, nonatomic) IBOutlet UILabel *buryCountLabel;
@property (weak, nonatomic) IBOutlet UIView *deleteView;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *separatorHeightCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagContainerViewBottomCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagContainerViewTopCon;
@property (weak, nonatomic) IBOutlet UIView *tagContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *tagImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstTagLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondTagLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdTagLabel;
@property (weak, nonatomic) IBOutlet UILabel *postCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UIView *postCoverView;
@property (weak, nonatomic) IBOutlet UIImageView *deleteImageView;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commentImageView;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *readTimeLabel;

@property (nonatomic, weak) id<QSYKCellDelegate> delegate;
@property (nonatomic, strong) QSYKResourceModel *resource;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic) BOOL flag;    // 标识是否显示在最近浏览页面
@property (nonatomic, copy) NSString *readTime;

+ (CGFloat)cellBaseHeight;

@end
