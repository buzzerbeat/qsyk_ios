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

@interface QSYKIndexViewController () <CarbonTabSwipeNavigationDelegate>
@property (nonatomic, strong) CarbonTabSwipeNavigation *carbonTabSwipeNavigation;
@property (nonatomic, strong) NSArray *itemTitles;

@end

@implementation QSYKIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"轻松一刻";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.itemTitles = @[
                        @"推荐",
                        @"视频",
                        @"动图",
                        @"图片",
                        @"段子",
                        @"美女",
                        ];
    
    self.carbonTabSwipeNavigation = [[CarbonTabSwipeNavigation alloc] initWithItems:_itemTitles delegate:self];
    [_carbonTabSwipeNavigation insertIntoRootViewController:self];
    [self configCarbonTabNav];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(pushToSettingsPage:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushToSettingsPage:(id)sender {
    QSYKSettingsTableViewController *settingsVC = [[QSYKSettingsTableViewController alloc] init];
    
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)configCarbonTabNav {
    [_carbonTabSwipeNavigation setIndicatorColor:[UIColor clearColor]];
    [_carbonTabSwipeNavigation setTabExtraWidth:30];
    _carbonTabSwipeNavigation.carbonTabSwipeScrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    for (int i = 0; i < _itemTitles.count; i++) {
        [_carbonTabSwipeNavigation.carbonSegmentedControl setWidth:SCREEN_WIDTH / _itemTitles.count forSegmentAtIndex:i];
    }
    
    // Custimize segmented control
    [_carbonTabSwipeNavigation setNormalColor:[UIColor lightGrayColor]
                                         font:[UIFont boldSystemFontOfSize:14]];
    [_carbonTabSwipeNavigation setSelectedColor:kCoreColor
                                           font:[UIFont boldSystemFontOfSize:16]];
}


#pragma mark CarbonTabSwipeNavigation Setup

- (UIViewController *)carbonTabSwipeNavigation:(CarbonTabSwipeNavigation *)carbonTabSwipeNavigation viewControllerAtIndex:(NSUInteger)index {
    
    switch (index) {
        case 0:{
            QSYKRecommendPageViewController *recommendVC = [[QSYKRecommendPageViewController alloc] init];
            if (index == 5) {
                recommendVC.isBeautyTag = YES;
            }
            
            return recommendVC;
        }
            break;
        case 5:{
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
