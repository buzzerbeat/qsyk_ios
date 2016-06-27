//
//  QSYKResourceDetailViewController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/25/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKResourceDetailViewController.h"
#import "QSYKPictureTableViewCell.h"
#import "QSYKTopicTableViewCell.h"
#import "QSYKVideoTableViewCell.h"
#import "QSYKCommentTableViewCell.h"
#import "QSYKPostModel.h"
#import "QSYKGodPostView.h"
#import "QZRegisterViewController.h"
#import "QSYKBaseNavigationController.h"
#import "QSYKTableSectionView.h"
#import "QSYKMyFavoriteTableViewController.h"
//#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
@import MediaPlayer;

static int POST_CONTENT_SIDE_WIDTH = 56;

@interface QSYKResourceDetailViewController () <QSYKCellDelegate>
//@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendCommentBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightCon;
@property (nonatomic, strong) QSYKResourceModel *resource;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) QSYKPostModel *post;
@property (nonatomic, copy) NSString *reply;    //回复评论的sid
@property (nonatomic, strong) QSYKUserModel *user;

@end

@implementation QSYKResourceDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.user = [QSYKUserManager sharedManager].user;
    
    self.separatorHeightCon.constant = ONE_PIX;
    self.sendCommentBtn.layer.cornerRadius = 3.f;
    self.sendCommentBtn.backgroundColor = kCoreColor;
    [self.view addGestureRecognizer:self.tableView.panGestureRecognizer];
    self.view.backgroundColor = self.tableView.backgroundColor;
    
    
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"QSYKPictureTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_pictureCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"QSYKTopicTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_topicCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"QSYKVideoTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_videoCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"QSYKCommentTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_commentCell];
    if (kIsIphone) {
        self.tableViewWidthCon.constant = SCREEN_WIDTH;
    } else {
        self.tableViewWidthCon.constant = SCREEN_WIDTH * 2/3;
    }
    
    [self loadResourceData];
    
    // 监听用户点击推送消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRemoteNotiResource:) name:kLoadFromRemotePushNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:kLoginSuccessNotification object:nil];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(SCREEN_WIDTH / 6);
        make.right.equalTo(self.view.mas_right).offset(-SCREEN_WIDTH / 6);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_resource.type == 3) {
        QSYKVideoTableViewCell *curCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [curCell reset];
    }
    
    // 当页面消失时注销对消息的监听
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)showRemoteNotiResource:(NSNotification *)noti {
    NSLog(@"noti = %@", noti.userInfo);
    
    self.sid = noti.userInfo[@"resourceSid"];
    [self loadResourceData];
}

- (void)keyboardWillChangeFrame:(NSNotification *)noti {
    CGRect frame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 先判断用户是否登录
    if (!_user.isLogin) {
        [self.textField endEditing:YES];
        [self loginAction];
    } else {
        //弹出时间
        CGFloat animaDuration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        //拿到键盘弹出的frame
//        CGRect frame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        self.bottomConstraint.constant = SCREEN_HEIGHT - frame.origin.y;
        [UIView animateWithDuration:animaDuration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    //让键盘退出
    [self.view endEditing:YES];
}

- (void)loginAction {
    QZRegisterViewController *registerView = [[QZRegisterViewController alloc] initWithNibName:@"QZRegisterViewController" bundle:nil];
    QSYKBaseNavigationController *nav = [[QSYKBaseNavigationController alloc] initWithRootViewController:registerView];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)loginSuccess {
    _user = [QSYKUserManager sharedManager].user;
}

- (void)loadResourceData {
    
    @weakify(self);
    [SVProgressHUD show];
    [[QSYKResourceManager sharedManager] getResourceDetailWithParameters:@{@"sid" : _sid}
                                                                 success:^(QSYKResourceModel *resource) {
                                                                     @strongify(self);
                                                                     [SVProgressHUD dismiss];
                                                                     
                                                                     self.resource = resource;
                                                                     self.type = self.resource.type;
                                                                     [self.tableView reloadData];
                                                                     if (_needScrollToPost) {
                                                                         [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                                                     }
                                                                     
                                                                 } failure:^(NSError *error) {
                                                                     [SVProgressHUD dismiss];
                                                                     [SVProgressHUD showErrorWithStatus:@"加载失败"];
                                                                     [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                                                                     NSLog(@"error = %@", error);
                                                                 }];
}

#pragma mark tableView delegate & dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int numberOfSections = 0;
    if (_resource) {
        numberOfSections++;
        if (_resource.hotPosts.count) {
            numberOfSections++;
        }
        if (_resource.posts.count) {
            numberOfSections++;
        }
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_resource) {
        if (section == 0) {
            return 1;
        } else if (section == 1) {
            if (_resource.hotPosts.count) {
                return _resource.hotPosts.count;
            } else {
                return _resource.posts.count;
            }
        } else if (section == 2) {
            return _resource.posts.count;
        } else {
            return 0;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    } else {
        return [QSYKTableSectionView viewHeight];
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    if (section != [tableView numberOfSections] - 1) {
//        return 10;
//    } else {
//        return 0;
//    }
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    QSYKTableSectionView *view = [[NSBundle mainBundle] loadNibNamed:@"QSYKTableSectionView" owner:nil options:nil][0];
    
    if (section == 1) {
        if (_resource.hotPosts.count) {
            view.titleLabel.text = @"最热评论";
            view.imageView.image = [UIImage imageNamed:@"comment_hot_red"];
        } else {
            view.titleLabel.text = @"最近评论";
            view.imageView.image = [UIImage imageNamed:@"comment_recently_red"];
        }
    } else if (section == 2) {
        view.titleLabel.text = @"最近评论";
        view.topSeparatorView.hidden = NO;
        view.imageView.image = [UIImage imageNamed:@"comment_recently_red"];
    } else {
        view = nil;
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {

        // width = content标签左右边距离屏幕左右边的距离的和（如果是iPad，需要再减去两边的空白区域的宽度）
        CGFloat width = kIsIphone ? SCREEN_WIDTH - TWO_SIDE_SPACES : SCREEN_WIDTH * 2 / 3 - TWO_SIDE_SPACES;
        
        CGFloat extraHeight = [QSYKUtility heightForMutilLineLabel:_resource.desc
                                                              font:TEXT_FONT
                                                             width:width];
        
        switch (_type) {
            case 1: {
                
                return [QSYKTopicTableViewCell cellBaseHeight] + extraHeight;
            }
                break;
            case 2: {
                // 图片类型的cell的高度根据图片本事的宽高比来计算在不同屏幕宽度下的高度
                extraHeight += width * _resource.relImage.height / _resource.relImage.width;
                return [QSYKPictureTableViewCell cellBaseHeight] + extraHeight;
            }
                break;
            case 3: {
                // video类型cell
                if (_resource.relVideo.height > _resource.relVideo.width) {
                    extraHeight += width;
                } else {
                    extraHeight += width * _resource.relVideo.height / _resource.relVideo.width;
                }
                
                return [QSYKVideoTableViewCell cellBaseHeight] + extraHeight;
            }
                break;
                
            default:
                return 0;
                break;
        }
    } else {
        QSYKPostModel *post = nil;
        if(indexPath.section == 1) {
            if (_resource.hotPosts.count) {
                post  = _resource.hotPosts[indexPath.row];
            } else {
                post  = _resource.posts[indexPath.row];
            }
        } else {
            post = _resource.posts[indexPath.row];
        }
        
        CGFloat extraHeight = [QSYKUtility heightForMutilLineLabel:post.content
                                                              font:TEXT_FONT
                                                             width:SCREEN_WIDTH - POST_CONTENT_SIDE_WIDTH];
        return [QSYKCommentTableViewCell cellBaseHeight] + extraHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        switch (_type) {
            case 1: {
                QSYKTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_topicCell forIndexPath:indexPath];
                cell.resource = _resource;
                cell.indexPath = indexPath;
                cell.delegate = self;
                cell.isInnerPage = YES;
                
                return cell;
            }
                break;
            case 2: {
                QSYKPictureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_pictureCell forIndexPath:indexPath];
                cell.resource = _resource;
                cell.indexPath = indexPath;
                cell.isInnerPage = YES;
                cell.delegate = self;
                
                return cell;
            }
                break;
            case 3: {
                QSYKVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_videoCell forIndexPath:indexPath];
                cell.resource = _resource;
                cell.indexPath = indexPath;
                cell.delegate = self;
                cell.isInnerPage = YES;
                
                return cell;
            }
                break;
                
            default:
                return nil;
                break;
        }
    } else if(indexPath.section == 1) {
        QSYKCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_commentCell forIndexPath:indexPath];
        if (_resource.hotPosts.count) {
            cell.post = _resource.hotPosts[indexPath.row];
        } else {
            cell.post = _resource.posts[indexPath.row];
        }
        
        cell.delegate = self;
        cell.indexPath = indexPath;
        
        return cell;
    } else {
        QSYKCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_commentCell forIndexPath:indexPath];
        cell.post = _resource.posts[indexPath.row];
        cell.delegate = self;
        cell.indexPath = indexPath;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
    {
        // This indeed is an indexPath no longer visible
        // Do something to this non-visible cell...
        if (_resource.type == 3 && indexPath.section == 0) {
            QSYKVideoTableViewCell *curCell = (QSYKVideoTableViewCell *)cell;
            [curCell reset];
        }
    }
}

/*
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        //创建menu菜单
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if (menu.isMenuVisible) {
            [menu setMenuVisible:NO animated:YES];
        }else {
            //取出点的那一行
            QSYKCommentTableViewCell *cell = (QSYKCommentTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            //成为第一响应者
            if ([cell canBecomeFirstResponder]) {
                [cell becomeFirstResponder];
            }
            
            UIMenuItem *ding = [[UIMenuItem alloc]initWithTitle:@"顶" action:@selector(ding:)];
            UIMenuItem *replay = [[UIMenuItem alloc]initWithTitle:@"回复" action:@selector(replay:)];
            menu.menuItems = @[ding,replay];
            
            CGRect cellRect = CGRectMake(0, cell.height / 2, cell.width, cell.height / 2);
            [menu setTargetRect:cellRect inView:cell];
            [menu setMenuVisible:YES animated:YES];
        }
    }
    
}
*/

#pragma mark - MenuItem处理
- (void)ding:(UIMenuController *)menu {//顶
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSLog(@"%s %@", __func__, indexPath);
}

- (void)replay:(UIMenuController *)menu {//回复
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSLog(@"%s %@", __func__, indexPath);
}

- (void)report:(UIMenuController *)menu {//举报
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSLog(@"%s %@", __func__, indexPath);
}


- (IBAction)sendComment:(id)sender {
    if (!_user.isLogin) {
        [self loginAction];
        
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"content": self.textField.text,
                                 @"sid": _sid,
//                                 @"reply": self.textField.text,
                                 };
    
    [SVProgressHUD show];
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                             URLString:@"/post/send"
                                            parameters:parameters
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   self.textField.text = nil;
                                                   [self.textField endEditing:YES];
                                                   [self loadResourceData];
                                                   
                                                   NSError *error = nil;
                                                   QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:&error];
                                                   if (!error) {
                                                       if (result && !result.status) {
                                                          [SVProgressHUD showSuccessWithStatus:@"评论成功"];
                                                           // 跳转到最新评论
                                                           NSInteger numberOfSections = [self.tableView numberOfSections];
                                                           [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:numberOfSections - 1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                                           
                                                       } else {
                                                           [SVProgressHUD showErrorWithStatus:result.message];
                                                       }
                                                   } else {
                                                       NSLog(@"QSYKResultModel 生成失败：%@", error);
                                                   }
                                               } failure:^(NSError *error) {
                                                   NSLog(@"error ：%@", error);
                                                   [SVProgressHUD showErrorWithStatus:@"评论失败"];
                                               }];
}


#pragma mark Cell Delegate

- (void)shareResoureWithSid:(NSString *)sid imgSid:(NSString *)imgSid content:(NSString *)content isTopic:(BOOL)isTopic{
    [[QSYKShareManager sharedManager] showInVC:self resourceSid:sid imgSid:imgSid content:content isTopic:isTopic];
}

- (void)rateResourceWithSid:(NSString *)sid type:(NSInteger)type indexPath:(NSIndexPath *)indexPath {
    [[QSYKDataManager sharedManager] rateResourceWithSid:sid type:type];
    
    if (type == 1) {
        _resource.dig++;
        _resource.hasDigged = YES;
    } else {
        _resource.bury++;
        _resource.hasBuried = YES;
    }
}

- (void)ratePostWithSid:(NSString *)sid indexPath:(NSIndexPath *)indexPath {
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodPOST
                                             URLString:[NSString stringWithFormat:@"/post/like?sid=%@", sid]
                                            parameters:nil
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   QSYKResultModel *result = [[QSYKResultModel alloc] initWithDictionary:responseObject error:nil];
                                                   
                                                   if (result && !result.status) {
                                                       NSLog(@"评价成功");
                                                   }
                                                   
                                               } failure:^(NSError *error) {
                                                   NSLog(@"评价失败  %@", error);
                                               }];
    
    QSYKPostModel *post = nil;
    if (indexPath.section == 1 && _resource.hotPosts.count) {
        post = (QSYKPostModel *)_resource.hotPosts[indexPath.row];
        post.dig++;
        post.hasDigged = YES;
        [_resource.hotPosts replaceObjectAtIndex:indexPath.row withObject:post];
    } else {
         post = (QSYKPostModel *)_resource.posts[indexPath.row];
        post.dig++;
        post.hasDigged = YES;
        [_resource.posts replaceObjectAtIndex:indexPath.row withObject:post];
    }
    
    
}

// 查看某个标签类型资源
- (void)tagTappedWithInfo:(QSYKTagModel *)tag {
    QSYKMyFavoriteTableViewController *myFavoritesVC = [[QSYKMyFavoriteTableViewController alloc] init];
    myFavoritesVC.URLStr = [NSString stringWithFormat:@"resource-tags?tag=%@", tag.sid];
    myFavoritesVC.tag = tag;
    myFavoritesVC.title = tag.name;
    myFavoritesVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myFavoritesVC animated:YES];
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
