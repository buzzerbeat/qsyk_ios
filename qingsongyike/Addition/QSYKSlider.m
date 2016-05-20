//
//  QSYKSlider.m
//  qingsongyike
//
//  Created by 苗慧宇 on 5/18/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKSlider.h"

@implementation QSYKSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)trackRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height + 20);
}

@end
