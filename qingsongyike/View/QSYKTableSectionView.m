//
//  QSYKTableSectionView.m
//  qingsongyike
//
//  Created by 苗慧宇 on 6/21/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKTableSectionView.h"

@implementation QSYKTableSectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    for (NSLayoutConstraint *con in self.separatorHeightCons) {
        con.constant = ONE_PIX;
    }
}

+ (CGFloat)viewHeight {
    return 42.f;
}

@end
