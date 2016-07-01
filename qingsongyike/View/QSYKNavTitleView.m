//
//  QSYKNavTitleView.m
//  qingsongyike
//
//  Created by 苗慧宇 on 6/28/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKNavTitleView.h"

@implementation QSYKNavTitleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
}

@end
