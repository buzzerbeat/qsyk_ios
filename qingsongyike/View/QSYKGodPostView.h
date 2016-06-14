//
//  QSYKGodPostView.h
//  qingsongyike
//
//  Created by 苗慧宇 on 5/31/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSYKCellDelegate.h"
@class QSYKPostModel;

@interface QSYKGodPostView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *digBtn;
@property (weak, nonatomic) IBOutlet UILabel *digCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (nonatomic, weak) id<QSYKCellDelegate> delegate;
@property (nonatomic, strong) QSYKPostModel *post;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) NSInteger index;

+ (CGFloat)baseHeight;
+ (CGFloat)contentWidth;

@end
