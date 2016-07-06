//
//  QSYKCommentTableViewCell.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/28/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSYKCellDelegate.h"
@class QSYKPostModel;

#define kCellIdentifier_commentCell @"QSYKCommentTableViewCell"

@interface QSYKCommentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *digBtn;
@property (weak, nonatomic) IBOutlet UILabel *digCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSeparaotrHeiCon;
@property (weak, nonatomic) IBOutlet UIButton *operationBtn;
@property (weak, nonatomic) IBOutlet UILabel *pubTimeLabel;

@property (nonatomic, weak) id<QSYKCellDelegate> delegate;
@property (nonatomic, strong) QSYKPostModel *post;
@property (nonatomic, strong) NSIndexPath *indexPath;

+ (CGFloat)cellBaseHeight;

@end
