//
//  QSYKRootTabBarController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 5/16/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKRootTabBarController.h"
#import "QSYKBaseNavigationController.h"
#import "QSYKMyPageViewController.h"
#import "QSYKIndexViewController.h"
#import "WebViewController.h"

@interface QSYKRootTabBarController ()
@property (nonatomic, strong) NSArray *tabBarItemTitles;
@property (nonatomic, strong) NSArray *tabBarItemImages;
@property (nonatomic, assign) NSInteger selectedItemIndex;

@end

@implementation QSYKRootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (kLotteryEnable) {
        self.tabBarItemTitles = @[@"首页", @"抽奖", @"我的"];
        self.tabBarItemImages = @[@"ic_home", @"ic_lottery", @"ic_profile"];
    } else {
        self.tabBarItemTitles = @[@"首页", @"我的"];
        self.tabBarItemImages = @[@"ic_home", @"ic_profile"];
    }
    
    self.selectedItemIndex = 0;
    [self setupViewControllers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupViewControllers {
    QSYKIndexViewController *indexVC = [[QSYKIndexViewController alloc] init];
    QSYKBaseNavigationController *indexNav = [[QSYKBaseNavigationController alloc] initWithRootViewController:indexVC];
    
    WebViewController *webView = [[WebViewController alloc] initWithTitle:@"抽奖" url:@""];
    QSYKBaseNavigationController *webViewNav = [[QSYKBaseNavigationController alloc] initWithRootViewController:webView];
    
    QSYKMyPageViewController *myPageVC = [[QSYKMyPageViewController alloc]  init];
    QSYKBaseNavigationController *myPageNav = [[QSYKBaseNavigationController alloc] initWithRootViewController:myPageVC];
    
    NSInteger index = 0;
    [indexVC setTabBarItem:[self configureItemAtIndex:index++]];
    
    if (kLotteryEnable) {
//        [webView setTabBarItem:[self configureItemAtIndex:index++]];
        index++;
    }
    
    [myPageVC setTabBarItem:[self configureItemAtIndex:index++]];
    
    if (kLotteryEnable) {
        [self setViewControllers:@[indexNav, webViewNav, myPageNav]];
    } else {
        [self setViewControllers:@[indexNav, myPageNav]];
    }
    
}

- (UITabBarItem *)configureItemAtIndex:(NSInteger)index {
    UIImage *unselectedImage = [self formatImageWithName:[NSString stringWithFormat:@"%@", [_tabBarItemImages objectAtIndex:index]]];
    UIImage *selectedImage   = [self formatImageWithName:[NSString stringWithFormat:@"%@_pressed", [_tabBarItemImages objectAtIndex:index]]];
    
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:_tabBarItemTitles[index] image:unselectedImage selectedImage:selectedImage];
    item.tag = index;
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : kCoreColor} forState:UIControlStateSelected];
    
    return item;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    // 如果某个item已被选择再点击则刷新这个 item 对应的 viewContrller
    if (item.tag == self.selectedItemIndex) {
        // send notification to refresh
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshIndexPageNotification object:nil];
    }
    
    self.selectedItemIndex = item.tag;
    NSLog(@"点击了第%ld个item", (long)item.tag);
}

- (UIImage *)formatImageWithName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    return image;
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
