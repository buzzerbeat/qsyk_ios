//
//  WebViewController.h
//  quiz
//
//  Created by subo on 15/11/24.
//  Copyright © 2015年 subo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (copy, nonatomic) NSString *navTitle;
@property (copy, nonatomic) NSString *url;

- (instancetype)initWithTitle:(NSString *)title url:(NSString *)url;

@end
