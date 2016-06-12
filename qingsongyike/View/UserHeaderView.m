//
//  UserHeaderView.m
//  quiz
//
//  Created by subo on 15/11/9.
//  Copyright © 2015年 subo. All rights reserved.
//

#import "UserHeaderView.h"

@implementation UserHeaderView

+ (id)loadFromXib
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@",[self class]] owner:nil options:nil];
    if (array && [array count]) {
        return array[0];
    }else {
        return nil;
    }
}

@end
