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
#import "QSYKAdTableViewCell.h"

@interface QSYKResourceInnerPageViewController () <CarbonTabSwipeNavigationDelegate>
@property (nonatomic, strong) CarbonTabSwipeNavigation *carbonTabSwipeNavigation;
@property (nonatomic, strong) NSMutableArray *itemTypes;

@end

@implementation QSYKResourceInnerPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the
    self.title = @"详情";
    self.view.backgroundColor = kBackgroundColor;
    
    [self configItemTypes];
    
    self.carbonTabSwipeNavigation = [[CarbonTabSwipeNavigation alloc] initWithItems:_itemTypes delegate:self];
    [_carbonTabSwipeNavigation setTabBarHeight:0];
    [_carbonTabSwipeNavigation setCurrentTabIndex:_curIndex];
    [_carbonTabSwipeNavigation insertIntoRootViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSInteger index = [_carbonTabSwipeNavigation currentTabIndex];
    if (_delegate && [_delegate respondsToSelector:@selector(tableViewScrollToIndex:)]) {
        [_delegate tableViewScrollToIndex:index];
    }
}

- (void)configItemTypes {
    NSUInteger itemsCount = _resources.count + (kAdEnable ? _resources.count / kAdInterval : 0);
    self.itemTypes = [NSMutableArray arrayWithCapacity:(itemsCount)];
    for (int i = 0; i < itemsCount; i++) {
        [_itemTypes addObject:@"Resource"];
    }
    
    if (kAdEnable) {
        for (int j = 1; j <= _resources.count / kAdInterval; j++) {
            _itemTypes[j * (kAdInterval + 1) - 1] = @"AD";
        }
    }
}

#pragma mark CarbonTabSwipeNavigation Setup

- (UIViewController *)carbonTabSwipeNavigation:(CarbonTabSwipeNavigation *)carbonTabSwipeNavigation viewControllerAtIndex:(NSUInteger)index {
    
    QSYKResourceDetailViewController *resourceDetailVC = [[QSYKResourceDetailViewController alloc] initWithNibName:@"QSYKResourceDetailViewController" bundle:nil];
    
    if ([_itemTypes[index] isEqualToString:@"Resource"]) {
        NSInteger curResourceIndex = index - (kAdEnable ? index / (kAdInterval + 1) : 0);
        QSYKResourceModel *resource = _resources[curResourceIndex];
        resourceDetailVC.needScrollToPost = _needScrollToPost;
        resourceDetailVC.sid = resource.sid;
        
    } else {
        NSInteger curAdIndex = (index / (kAdInterval + 1)) % kQQAdNum;
        resourceDetailVC.ad = _ads[curAdIndex];
    }
    
    if (index == _curIndex) {
        _needScrollToPost = NO;
    }
    
    return resourceDetailVC;
}

- (void)carbonTabSwipeNavigation:(CarbonTabSwipeNavigation *)carbonTabSwipeNavigation didMoveAtIndex:(NSUInteger)index {
    NSInteger curResourceIndex = index - (kAdEnable ? index / (kAdInterval + 1) : 0);
    QSYKResourceModel *resource = _resources[curResourceIndex];
    [QSYKUtility saveResourceSidIntoDBWithSid:resource.sid];
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
