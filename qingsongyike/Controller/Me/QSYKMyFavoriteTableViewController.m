//
//  QSYKMyFavoriteTableViewController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 5/16/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKMyFavoriteTableViewController.h"
#import "QSYKFavoriteResourceModel.h"
#import "QSYKPictureTableViewCell.h"
#import "QSYKTopicTableViewCell.h"
#import "QSYKVideoTableViewCell.h"
#import "QSYKResourceDetailViewController.h"
#import "QSYKTagPageHeaderView.h"
#import "QSYKTagModel.h"
@import MediaPlayer;

@interface QSYKMyFavoriteTableViewController () <QSYKInnerPageDelegate, QSYKCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, strong) UILabel *noDataIndicatorLabel;
@property (nonatomic, strong) NSArray *readHistory;
@property (nonatomic, copy) NSString *sids;     // 当前显示的资源sid串
@property (nonatomic, assign) NSInteger remainingSidCount;
@property (nonatomic, strong) QSYKTagPageHeaderView *headerView;
@property (nonatomic, assign) BOOL adEnable;

@end

@implementation QSYKMyFavoriteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [tableView registerNib:[UINib nibWithNibName:@"QSYKPictureTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_pictureCell];
        [tableView registerNib:[UINib nibWithNibName:@"QSYKTopicTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_topicCell];
        [tableView registerNib:[UINib nibWithNibName:@"QSYKVideoTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_videoCell];
        [tableView registerNib:[UINib nibWithNibName:@"QSYKAdTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_adCell];
        
        if (_tag) {
            [self getTagInfo];
            if (kAdEnable) {
                self.adEnable = YES;
                [self configNativeAd];
            }
            
            [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(getTagInfo) name:kFocusedTagsChangedNotification object:nil];
        }
        
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (kIsIphone) {
                make.edges.equalTo(self.view);
            } else {
                make.top.equalTo(self.view);
                make.bottom.equalTo(self.view);
                make.left.equalTo(self.view.mas_left).offset(SCREEN_WIDTH / 6);
                make.right.equalTo(self.view.mas_right).offset(-SCREEN_WIDTH / 6);
            }
        }];
        
        if (_isReadHistory) {
            tableView.mj_footer = [QSYKRefreshFooter footerWithRefreshingBlock:^{
                [self updateSids];
                self.URLStr = [@"/resources?sid=" stringByAppendingString:_sids];
                [self loadResource];
            }];
        }
        
        tableView;
    });
    
    self.noDataIndicatorLabel = ({
        UILabel *label = [UILabel new];
        label.text = @"空空如也~";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:18.];
        label.hidden = YES;
        [self.view addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.centerY.equalTo(self.view.mas_centerY).offset(-50);
        }];
        
        label;
    });
    
    // 如果是展示浏览历史，需要先获取本地存储浏览的记录
    if (_isReadHistory) {
        self.readHistory = [NSArray arrayWithArray:[QSYKUtility readHistoryArray]];
        
        self.sids = @"";
        self.remainingSidCount = _readHistory.count - 1;
        for (int i = 0; i < 15 && _remainingSidCount >= 0; i++, _remainingSidCount--) {
            NSDictionary *dic = _readHistory[_remainingSidCount];
            NSLog(@"createTime = %@", [dic allValues][0]);
            self.sids = [self.sids stringByAppendingString:[NSString stringWithFormat:@"%@,", [dic allKeys][0]]];
        }
        
        self.URLStr = [@"/resources?sid=" stringByAppendingString:_sids];
        NSLog(@"sids = %@", _sids);
    }
    
    self.models = [NSMutableArray new];
    [self loadResource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 当页面离开屏幕时关闭视频播放
    [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (QSYKTagPageHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[NSBundle mainBundle] loadNibNamed:@"QSYKTagPageHeaderView" owner:nil options:nil][0];
    }
    return _headerView;
}

- (void)configTableHeaderView {
    self.headerView.tagModel = _tag;
    [_headerView setup];
    
    UIView *view = [[UIView alloc] init];
    view.height = _headerView.height;
    view.width = SCREEN_WIDTH;
    [view addSubview:_headerView];
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    self.tableView.tableHeaderView = view;
    [self.tableView reloadData];
}

// GDT AD 相关
- (void)configNativeAd {
    self.gdtNativeAd        = [[GDTNativeAd alloc] initWithAppkey:kQQAppId placementId:kQQPosId];
    self.gdtNativeAd.controller = self;
    self.gdtNativeAd.delegate   = self;
    
    /*
     * 拉取广告,传入参数为拉取个数。
     * 发起拉取广告请求,在获得广告数据后回调delegate
     */
    [self.gdtNativeAd loadAd:(int)kQQAdNum]; //一次拉取n条原生广告
}

#pragma mark GDTNativeAdDelegate

-(void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray
{
    NSLog(@"%s",__FUNCTION__);
    /*广告数据拉取成功，存储并展示*/
    
    // 每次刷新广告数据
    self.adData = [NSMutableArray arrayWithArray:nativeAdDataArray];
    
    NSLog(@"%lu",(unsigned long)nativeAdDataArray.count);
}

-(void)nativeAdFailToLoad:(NSError *)error
{
    NSLog(@"%s",__FUNCTION__);
    /*广告数据拉取失败*/
}

- (void)getTagInfo {
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
                                             URLString:[NSString stringWithFormat:@"/tags/%@?expand=isFocus", _tag.sid]
                                            parameters:nil
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   QSYKTagModel *tag = [[QSYKTagModel alloc] initWithDictionary:responseObject error:nil];
                                                   if (tag) {
                                                       _tag = tag;
                                                       [self configTableHeaderView];
                                                   }
                                               }
                                               failure:^(NSError *error) {
                                                   
                                               }];
}

- (void)updateSids {
    
    if (_remainingSidCount > 0) {
        _remainingSidCount++;
        
        self.sids = @"";
        for (int i = 0; i < 15 && _remainingSidCount >= 0; i++, _remainingSidCount--) {
            NSDictionary *dic = _readHistory[_remainingSidCount];
            self.sids = [self.sids stringByAppendingString:[NSString stringWithFormat:@"%@,", [dic allKeys][0]]];
        }
    } else {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

- (void)loadResource {
    NSLog(@"urlStr = %@", _URLStr);
    [SVProgressHUD show];
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
                                             URLString:_URLStr
                                            parameters:@{@"expand":@"tags"}
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   [SVProgressHUD dismiss];
                                                   
                                                   if (_isReadHistory || _tag) {
                                                       [self.tableView.mj_footer endRefreshing];
                                                       
                                                       QSYKResourceList *models = [[QSYKResourceList alloc] initWithArray:responseObject];
                                                       if (models.list.count) {
                                                           self.noDataIndicatorLabel.hidden = YES;
                                                           
                                                           [self.models addObjectsFromArray:models.list];
                                                           [self.tableView reloadData];
                                                       } else {
                                                           self.noDataIndicatorLabel.hidden = NO;
                                                       }
                                                       
                                                   } else {
                                                       QSYKFavoriteResourceList *models = [[QSYKFavoriteResourceList alloc] initWithArray:responseObject];
                                                       if (models.list.count) {
                                                           self.noDataIndicatorLabel.hidden = YES;
                                                           //                                                           self.models = [NSMutableArray arrayWithArray:models.list];
                                                           self.models = [NSMutableArray new];
                                                           for (QSYKFavoriteModel *model in models.list) {
                                                               [self.models addObject:model.resource];
                                                           }
                                                           [self.tableView reloadData];
                                                       } else {
                                                           self.noDataIndicatorLabel.hidden = NO;
                                                       }
                                                   }
                                                   
                                               } failure:^(NSError *error) {
                                                   self.noDataIndicatorLabel.hidden = YES;
                                                   [SVProgressHUD showErrorWithStatus:@"服务器开小差了~"];
                                                   NSLog(@"error = %@", error);
                                               }];
}


#pragma mark tableView delegate & dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger resourceCount = _models.count;
    if (resourceCount) {
        // 把广告cell（如果显示）考虑在内
        NSInteger numberOfRows = resourceCount + (_adEnable ? resourceCount / kAdInterval : 0);
        
        self.cellTypeArray = [NSMutableArray arrayWithCapacity:numberOfRows];
        for (int i = 0; i < numberOfRows; i++) {
            self.cellTypeArray[i] = @"Resource";
        }
        
        if (_adEnable) {
            for (int j = 1; j <= resourceCount / kAdInterval; j++) {
                self.cellTypeArray[j * (kAdInterval + 1) - 1] = @"AD";
            }
        }
        
        return numberOfRows;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cellTypeArray[indexPath.row] isEqualToString:@"Resource"]) {
        NSInteger curResourceIndex = indexPath.row - (_adEnable ? indexPath.row / (kAdInterval + 1) : 0);
        QSYKResourceModel *resource = _models[curResourceIndex];
        NSInteger cellType = resource.type;
        
        // width = content标签左右边距离屏幕左右边的距离的和
        CGFloat extraHeight = [QSYKUtility heightForMutilLineLabel:resource.desc
                                                              font:TEXT_FONT
                                                             width:SCREEN_WIDTH - TWO_SIDE_SPACES];
        
        if (cellType == 1) {
            return [QSYKTopicTableViewCell cellBaseHeight] + extraHeight;
            
        } else if (cellType == 2) {
            // 图片类型的cell的高度根据图片本事的宽高比来计算在不同屏幕宽度下的高度
            if (resource.relImage.height > 2 * resource.relImage.width && !resource.relImage.dynamic) {
                extraHeight += (SCREEN_WIDTH - TWO_SIDE_SPACES) * 1.5;
            } else {
                extraHeight += (SCREEN_WIDTH - TWO_SIDE_SPACES) * resource.relImage.height / resource.relImage.width;
            }
            
            return [QSYKPictureTableViewCell cellBaseHeight] + extraHeight;
        } else {
            // video类型同图片
            if (resource.relVideo.height > resource.relVideo.width) {
                extraHeight += (SCREEN_WIDTH - TWO_SIDE_SPACES);
            } else {
                extraHeight += (SCREEN_WIDTH - TWO_SIDE_SPACES) * resource.relVideo.height / resource.relVideo.width;
            }
            
            return [QSYKVideoTableViewCell cellBaseHeight] + extraHeight;
        }
    } else {
        if (!_adEnable) {
            return 0;
            
        } else {
            // width = content标签左右边距离屏幕左右边的距离(广告左右距离是15)的和
            //（如果是iPad，需要再减去两边的空白区域的宽度）
            CGFloat width = kIsIphone ? SCREEN_WIDTH - AD_TWO_SIDE_SPACES
            : SCREEN_WIDTH * 2 / 3 - AD_TWO_SIDE_SPACES;
            
            //            NSLog(@"%ld", kAdInterval);
            GDTNativeAdData *anAD = self.adData[indexPath.row / (kAdInterval + 1) % kQQAdNum];
            
            CGFloat extraHeight = [QSYKUtility heightForMutilLineLabel:anAD.properties[@"desc"]
                                                                  font:TEXT_FONT
                                                                 width:width];
            
            return [QSYKAdTableViewCell cellBaseHeight] + extraHeight;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cellTypeArray[indexPath.row] isEqualToString:@"Resource"]) {
        NSInteger curResourceIndex = indexPath.row - (_adEnable ? indexPath.row / (kAdInterval + 1) : 0);
        QSYKResourceModel *resource = _models[curResourceIndex];
        NSInteger cellType = resource.type;
    
        switch (cellType) {
            case 1: {
                QSYKTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_topicCell forIndexPath:indexPath];
                cell.resource = resource;
                cell.indexPath = indexPath;
                cell.delegate = self;
                
                if (_isReadHistory) {
                    cell.flag = YES;
                    cell.readTime = [self getReadTimeBySid:resource.sid];
                }
                
                return cell;
            }
                break;
            case 2: {
                QSYKPictureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_pictureCell forIndexPath:indexPath];
                cell.resource = resource;
                cell.indexPath = indexPath;
                cell.delegate = self;
                
                if (_isReadHistory) {
                    cell.flag = YES;
                    cell.readTime = [self getReadTimeBySid:resource.sid];
                }
                
                return cell;
            }
                break;
            case 3: {
                QSYKVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_videoCell forIndexPath:indexPath];
                cell.resource = resource;
                cell.indexPath = indexPath;
                cell.delegate = self;
                
                if (_isReadHistory) {
                    cell.flag = YES;
                    cell.readTime = [self getReadTimeBySid:resource.sid];
                }
                
                return cell;
            }
                break;
                
            default:
                return nil;
                break;
        }
    } else {
        QSYKAdTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_adCell forIndexPath:indexPath];
        
        GDTNativeAdData *anAD = self.adData[indexPath.row / (kAdInterval + 1) % kQQAdNum];
        [cell setupWithGDTAd:anAD];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cellTypeArray[indexPath.row] isEqualToString:@"Resource"]) {
        NSInteger curResourceIndex = indexPath.row - (_adEnable ? indexPath.row / (kAdInterval + 1) : 0);
        QSYKResourceModel *resource = _models[curResourceIndex];
        
        [self pushToInnerPageWithIndexPath:indexPath needScroll:NO];
        
        if (resource.type == 3) {
            QSYKVideoTableViewCell *curCell = [tableView cellForRowAtIndexPath:indexPath];
            [curCell resetWithAcitonType:@"o"];
        }
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        // 点击广告
        NSInteger adDataIndex = (indexPath.row / (kAdInterval + 1)) % kQQAdNum;
        
        [self.gdtNativeAd clickAd:self.adData[adDataIndex]];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cellTypeArray[indexPath.row] isEqualToString:@"AD"]) {
        /*
         * 广告数据渲染完毕，即将展示时需调用AttachAd方法。(用于统计)
         */
        NSInteger adIndex = (indexPath.row / (kAdInterval + 1)) % kQQAdNum;
        [self.gdtNativeAd attachAd:self.adData[adIndex] toView:cell];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cellTypeArray[indexPath.row] isEqualToString:@"Resource"]) {
        if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
        {
            NSInteger curResourceIndex = indexPath.row - (_adEnable ? indexPath.row / (kAdInterval + 1) : 0);
            QSYKResourceModel *resource = _models[curResourceIndex];
            if (resource.type == 3) {
                QSYKVideoTableViewCell *curCell = (QSYKVideoTableViewCell *)cell;
                [curCell resetWithAcitonType:@"d"];
            }
        }
    }
}

- (NSString *)getReadTimeBySid:(NSString *)sid {
    for (NSDictionary *dic in _readHistory) {
        NSString *readTime = [dic objectForKey:sid];
        if (readTime && readTime.length) {
            return readTime;
        }
    }
    return nil;
}

#pragma mark CellDelegate

- (void)shareResoureWithSid:(NSString *)sid imgSid:(NSString *)imgSid content:(NSString *)content isTopic:(BOOL)isTopic{
    [[QSYKShareManager sharedManager] showInVC:self resourceSid:sid imgSid:imgSid content:content isTopic:isTopic];
}

- (void)rateResourceWithSid:(NSString *)sid type:(NSInteger)type indexPath:(NSIndexPath *)indexPath {
    [[QSYKDataManager sharedManager] rateResourceWithSid:sid type:type];
    
    NSInteger curResourceIndex = indexPath.row - (_adEnable ? indexPath.row / (kAdInterval + 1) : 0);
    QSYKResourceModel *resource = _models[curResourceIndex];
    if (type == 1) {
        resource.dig++;
        resource.hasDigged = YES;
    } else {
        resource.bury++;
        resource.hasBuried = YES;
    }
    [self.models replaceObjectAtIndex:indexPath.row withObject:resource];
}


// 删除某个资源
- (void)deleteResourceAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger curResourceIndex = indexPath.row - (_adEnable ? indexPath.row / (kAdInterval + 1) : 0);
    QSYKResourceModel *resource = _models[curResourceIndex];
    self.deletingResourceSid = resource.sid;
    self.deletingResourceIndexPath = indexPath;
    [QSYKUtility showDeleteResourceReasonsWithSid:resource.sid delegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAndReloadAtIndexPath) name:@"deleteComplete" object:nil];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 1看不懂, 2不喜欢, 3太污了, 4重口味, 0其他
    
    NSInteger index = buttonIndex != 4 ? buttonIndex + 1 : 0;
    [[QSYKDataManager sharedManager] deleteResourceWithSid:self.deletingResourceSid type:index];
    
}

- (void) deleteAndReloadAtIndexPath {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteComplete" object:nil];
    
    [_models removeObjectAtIndex:self.deletingResourceIndexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[self.deletingResourceIndexPath] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView reloadData];
}

// 查看某个标签类型资源
- (void)tagTappedWithInfo:(QSYKTagModel *)tag {
    QSYKMyFavoriteTableViewController *myFavoritesVC = [[QSYKMyFavoriteTableViewController alloc] init];
    myFavoritesVC.URLStr = [NSString stringWithFormat:@"resource-tags?tag=%@", tag.sid];
    myFavoritesVC.isReadHistory = YES;
    myFavoritesVC.tag = tag;
    myFavoritesVC.title = tag.name;
    myFavoritesVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myFavoritesVC animated:YES];
}

// 通过点击评论图标进入资源内页，定位到评论位置
- (void)locatePostAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger curResourceIndex = indexPath.row - (_adEnable ? indexPath.row / (kAdInterval + 1) : 0);
    QSYKResourceModel *resource = _models[curResourceIndex];
    
    [self pushToInnerPageWithIndexPath:indexPath needScroll:YES];
        
    if ([self.cellTypeArray[indexPath.row] isEqualToString:@"Resource"] && resource.type == 3) {
        QSYKVideoTableViewCell *curCell = [self.tableView cellForRowAtIndexPath:indexPath];
        [curCell resetWithAcitonType:@"o"];
    }
}

- (void)pushToInnerPageWithIndexPath:(NSIndexPath *)indexPath needScroll:(BOOL)needScroll {
    QSYKResourceInnerPageViewController *innerPage = [[QSYKResourceInnerPageViewController alloc] init];
    innerPage.delegate = self;
    innerPage.resources = _models;
    innerPage.ads = self.adData;
    innerPage.curIndex = indexPath.row;
    innerPage.needScrollToPost = needScroll;
    innerPage.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:innerPage animated:YES];
}

// 从详情页返回主页时将内页最后浏览的资源滑动到屏幕中间
- (void)tableViewScrollToIndex:(NSInteger)index {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
