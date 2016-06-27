//
//  QSYKIndexViewController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKIndexViewController.h"
#import <CarbonKit.h>
#import "QSYKRecommendPageViewController.h"
#import "QSYKVideoPageViewController.h"
#import "QSYKPicturePageViewController.h"
#import "QSYKTopicPageViewController.h"
#import "QSYKSettingsTableViewController.h"
#import "QSYKWebViewController.h"

@interface QSYKIndexViewController () <CarbonTabSwipeNavigationDelegate>
@property (nonatomic, strong) CarbonTabSwipeNavigation *carbonTabSwipeNavigation;
@property (nonatomic, strong) NSArray *itemTitles;

@end

@implementation QSYKIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"首页";
    self.navigationItem.title = @"轻松一刻";
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (kBeautyEnable) {
        self.itemTitles = @[
                            @"推荐",
                            @"视频",
                            @"动图",
                            @"图片",
                            @"段子",
                            @"美女",
                            ];
    } else {
        self.itemTitles = @[
                            @"推荐",
                            @"视频",
                            @"动图",
                            @"图片",
                            @"段子",
                            ];
    }
    
    
    self.carbonTabSwipeNavigation = [[CarbonTabSwipeNavigation alloc] initWithItems:_itemTitles delegate:self];
    [_carbonTabSwipeNavigation insertIntoRootViewController:self];
    [self configCarbonTabNav];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLotteryPage) name:@"test" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadLotteryPage {
    if ([self isVisible]) {
        QSYKWebViewController *aPage = [[QSYKWebViewController alloc] init];
        aPage.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:aPage animated:YES];
    }
}

- (void)configCarbonTabNav {
    [_carbonTabSwipeNavigation setTabBarHeight:40];
    [_carbonTabSwipeNavigation setIndicatorColor:kCoreColor];
    [_carbonTabSwipeNavigation setIndicatorHeight:2];

//    [_carbonTabSwipeNavigation setTabExtraWidth:10];
    
    for (int i = 0; i < _itemTitles.count; i++) {
        [_carbonTabSwipeNavigation.carbonSegmentedControl setWidth:SCREEN_WIDTH / _itemTitles.count forSegmentAtIndex:i];
    }
    
    // Custimize segmented control
    [_carbonTabSwipeNavigation setNormalColor:kTextGrayColor
                                         font:[UIFont systemFontOfSize:16]];
    [_carbonTabSwipeNavigation setSelectedColor:kCoreColor
                                           font:[UIFont boldSystemFontOfSize:16]];
}


#pragma mark CarbonTabSwipeNavigation Setup

- (UIViewController *)carbonTabSwipeNavigation:(CarbonTabSwipeNavigation *)carbonTabSwipeNavigation viewControllerAtIndex:(NSUInteger)index {
    
    switch (index) {
        case 0:
        case 5: {
            QSYKRecommendPageViewController *recommendVC = [[QSYKRecommendPageViewController alloc] init];
            if (index == 5) {
                recommendVC.isBeautyTag = YES;
            }
            
            return recommendVC;
        }
            break;
        case 1: {
            QSYKVideoPageViewController *videoVC = [[QSYKVideoPageViewController alloc] init];
            
            return videoVC;
        }
            break;
        case 2: {
            QSYKPicturePageViewController *pictureVC = [[QSYKPicturePageViewController alloc] init];
            pictureVC.isDynamic = index == 2 ? 1 : 0;
            
            return pictureVC;
        }
            break;
            
        case 3: {
            QSYKPicturePageViewController *pictureVC = [[QSYKPicturePageViewController alloc] init];
            pictureVC.isDynamic = index == 2 ? 1 : 0;
            
            return pictureVC;
        }
            break;
        case 4: {
            QSYKTopicPageViewController *topicVC =[[QSYKTopicPageViewController alloc] init];
            
            return topicVC;
        }
            break;
            
        default:
            break;
    }
    
    return nil;
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
