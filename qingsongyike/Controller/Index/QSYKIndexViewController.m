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
#import "QSYKNavTitleView.h"
#import "DropDownMenu.h"
#import "QSYKDropDownMenuViewController.h"
#import "QSYKMyFavoriteTableViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface QSYKIndexViewController () <CarbonTabSwipeNavigationDelegate, DropDownMenuDelegate>
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) CarbonTabSwipeNavigation *carbonTabSwipeNavigation;
@property (nonatomic, strong) GADBannerView *bannerView;

@property (nonatomic, strong) NSArray *itemTitles;
@property (nonatomic, strong) QSYKNavTitleView *navTitleView;
@property (nonatomic, strong) NSArray *tagNames;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) QSYKTagGroupModel *tagGroups;
@property (nonatomic, strong) DropDownMenu *dropDownMenu;
@property (nonatomic, strong) QSYKDropDownMenuViewController *titleMenuVC;

@end

static const CGFloat TOOL_BAR_HEIGHT = 49;
static const CGFloat BANNER_HEIGHT = 49;

@implementation QSYKIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"首页";
    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationItem.title = @"轻松一刻";
    self.navigationItem.titleView = self.navTitleView;
    [self requestTags];
    
    
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
    
    // init container view
    self.containerView = ({
        UIView *view = [[UIView alloc] init];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        view;
    });
    
    self.carbonTabSwipeNavigation = [[CarbonTabSwipeNavigation alloc] initWithItems:_itemTitles delegate:self];
    [_carbonTabSwipeNavigation insertIntoRootViewController:self andTargetView:self.containerView];
    [self configCarbonTabNav];
    
    // google bannerView
    if (kGoogleAdEnable) {
        self.bannerView = [[GADBannerView alloc] init];
        [self.view addSubview:self.bannerView];
        [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-TOOL_BAR_HEIGHT);
            make.height.offset(49);
        }];
        
        // container view 底部预留banner view 的高度
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-(TOOL_BAR_HEIGHT + BANNER_HEIGHT));
        }];

        self.bannerView.adUnitID = kGoogleAdId;
        self.bannerView.rootViewController = self;
        [self.bannerView loadRequest:[GADRequest request]];
    } else {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-TOOL_BAR_HEIGHT);
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLotteryPage) name:@"test" object:nil];
    // 当用户关注、取消关注标签或登录、登出后，再次点击 navTitle 需要刷新数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestTags) name:kFocusedTagsChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestTags) name:kLogoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestTags) name:kLoginSuccessNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (QSYKDropDownMenuViewController *)titleMenuVC {
    if (!_titleMenuVC) {
        _titleMenuVC = [[QSYKDropDownMenuViewController alloc] init];
        _titleMenuVC.view.width = MENU_WIDTH;
        _titleMenuVC.view.height = MENU_HEIGHT;
        
        @weakify(self);
        _titleMenuVC.selectTagBlock = ^(QSYKTagModel *tag) {
            @strongify(self);
            
            // 跳转到标签页
            QSYKMyFavoriteTableViewController *myFavoritesVC = [[QSYKMyFavoriteTableViewController alloc] init];
            myFavoritesVC.URLStr = [NSString stringWithFormat:@"resource-tag?tag=%@", tag.sid];
            myFavoritesVC.tag = tag;
            myFavoritesVC.title = tag.name;
            myFavoritesVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:myFavoritesVC animated:YES];
            
            [self.dropDownMenu dismiss];
        };
    }
    return _titleMenuVC;
}

- (DropDownMenu *)dropDownMenu {
    if (!_dropDownMenu) {
        // 1.创建下拉菜单
        _dropDownMenu = [[DropDownMenu alloc] init];
        _dropDownMenu.delegate = self;
    }
    
    CGFloat menuHeight = _tagGroups.top.count * 39;
    if (_tagGroups.focus.count) {
        menuHeight += _tagGroups.focus.count * 39;
    }
    
    self.titleMenuVC.view.height = (menuHeight < MENU_HEIGHT) ? menuHeight : MENU_HEIGHT;
    
    self.titleMenuVC.dataSource = self.tagGroups;
    _dropDownMenu.contentController = self.titleMenuVC;
    
    return _dropDownMenu;
}

- (QSYKNavTitleView *)navTitleView {
    if (!_navTitleView) {
        _navTitleView = [[NSBundle mainBundle] loadNibNamed:@"QSYKNavTitleView" owner:nil options:nil][0];
        [_navTitleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navTitleClicked:)]];
    }
    return _navTitleView;
}

#pragma mark titleView clicked

- (void)navTitleClicked:(id)sender {
    // 如果分类标签个数为0 则不弹出下拉菜单
//    if (_tagNames.count == 0) {
//        return;
//    }
    
    [self.dropDownMenu showFrom:_navTitleView];
    _navTitleView.downArrowImagView.image = [UIImage imageNamed:@"ico_arrows_up"];
    
}

#pragma mark DropDownMenu delegate

- (void)menuDismiss {
    // 让指示箭头向上
    _navTitleView.downArrowImagView.image = [UIImage imageNamed:@"ico_arrows_down"];
}

// 请求标签信息
- (void)requestTags {
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
                                             URLString:@"/tag/group"
                                            parameters:nil
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   
                                                   NSError *error = nil;
                                                   QSYKTagGroupModel *tagGroups = [[QSYKTagGroupModel alloc] initWithDictionary:responseObject error:&error];
                                                   
                                                   if (!error) {
                                                       if (tagGroups) {
                                                           self.tagGroups = tagGroups;
                                                       }
                                                   }
                                               }
                                               failure:^(NSError *error) {
                                                   
                                               }];
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
