//
//  QSYKTagPageHeaderView.h
//  qingsongyike
//
//  Created by 苗慧宇 on 6/23/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QSYKTagModel;

@interface QSYKTagPageHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *attentionBtn;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightCon;

@property (nonatomic, strong) QSYKTagModel *tagModel;

- (void)setup;
+ (CGFloat)viewBaseHeight;

@end
