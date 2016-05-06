//
//  QSYKCommentTableViewCell.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/28/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellIdentifier_commentCell @"QSYKCommentTableViewCell"

@interface QSYKCommentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *digBtn;
@property (weak, nonatomic) IBOutlet UILabel *digCountLabel;


+ (CGFloat)cellBaseHeight;

@end
