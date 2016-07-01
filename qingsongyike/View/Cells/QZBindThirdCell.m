//
//  QZBindThirdCell.m
//  quiz
//
//  Created by 苗慧宇 on 16/1/6.
//  Copyright © 2016年 subo. All rights reserved.
//

#import "QZBindThirdCell.h"

@implementation QZBindThirdCell

- (void)awakeFromNib {
    // Initialization code
    self.separatorHeightCon.constant = ONE_PIX;
    self.nightSwitch.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)nightSwitchTapped:(id)sender {
    // 切换夜间模式
    NSLog(@"切换夜间模式");
}

@end
