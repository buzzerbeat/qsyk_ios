//
//  QSYKDropMenuTableSectionHeaderView.m
//  qingsongyike
//
//  Created by 苗慧宇 on 6/30/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKDropMenuTableSectionHeaderView.h"

@implementation QSYKDropMenuTableSectionHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    for (NSLayoutConstraint *con in self.separotorHeightCons) {
        con.constant = ONE_PIX;
    }
}

@end
