//
//  UserHeaderView.h
//  quiz
//
//  Created by subo on 15/11/9.
//  Copyright © 2015年 subo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightCons;

+ (id)loadFromXib;
@end
