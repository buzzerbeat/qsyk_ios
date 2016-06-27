//
//  QSYKResourceInnerPageViewController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 6/16/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKResourceInnerPageViewController.h"
#import <CarbonKit.h>
#import "QSYKResourceDetailViewController.h"

@interface QSYKResourceInnerPageViewController () <CarbonTabSwipeNavigationDelegate>
@property (nonatomic, strong) CarbonTabSwipeNavigation *carbonTabSwipeNavigation;

@end

@implementation QSYKResourceInnerPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark CarbonTabSwipeNavigation Setup

- (UIViewController *)carbonTabSwipeNavigation:(CarbonTabSwipeNavigation *)carbonTabSwipeNavigation viewControllerAtIndex:(NSUInteger)index {
    QSYKResourceDetailViewController *resourceDetailVC = [[QSYKResourceDetailViewController alloc] initWithNibName:@"QSYKResourceDetailViewController" bundle:nil];
    
    
    return resourceDetailVC;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
