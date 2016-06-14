//
//  QSYKPresentNavigationController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 6/6/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKPresentNavigationController.h"

@implementation QSYKPresentNavigationController

- (void)viewDidLoad {
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(closeAction)];
    self.navigationItem.leftBarButtonItem = closeItem;
    
    
}


- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
