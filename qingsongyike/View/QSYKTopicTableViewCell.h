//
//  QSYKTopicTableViewCell.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/25/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKBaseTableViewCell.h"

#define kCellIdentifier_topicCell @"QSYKTopicTableViewCell"


@interface QSYKTopicTableViewCell : QSYKBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabe;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightCon;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *digBtn;
@property (weak, nonatomic) IBOutlet UILabel *digCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *buryBtn;
@property (weak, nonatomic) IBOutlet UILabel *buryCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

@property (nonatomic, weak) id<QSYKCellDelegate> delegate;
@property (nonatomic, strong) id resource;
@property (nonatomic) BOOL flag;
@property (nonatomic, strong) NSIndexPath *indexPath;

+ (CGFloat)cellBaseHeight;

@end
