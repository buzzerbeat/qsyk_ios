//
//  QSYKTopicTableViewCell.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/25/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSYKCellDelegate.h"

#define kCellIdentifier_topicCell @"QSYKTopicTableViewCell"


@interface QSYKTopicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabe;
@property (weak, nonatomic) IBOutlet UILabel *pubTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightCon;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *digBtn;
@property (weak, nonatomic) IBOutlet UIButton *buryBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

@property (nonatomic, weak) id<QSYKCellDelegate> delegate;
@property (nonatomic, strong) QSYKResourceModel *resource;
@property (nonatomic, strong) NSIndexPath *indexPath;

+ (CGFloat)cellBaseHeight;

@end
