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
@import MediaPlayer;

@interface QSYKResourceDetailViewController () <QSYKCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendCommentBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) QSYKResourceModel *resource;
@property (nonatomic, strong) QSYKPostModel *post;

@end

@implementation QSYKResourceDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"QSYKPictureTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_pictureCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"QSYKTopicTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_topicCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"QSYKVideoTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_videoCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"QSYKCommentTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier_commentCell];
    //    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
    //        [self loadData];
    //    }];
    //    tableView.mj_footer = [QSYKRefreshFooter footerWithRefreshingBlock:^{
    //        [self loadData];
    //    }];
    
    self.sendCommentBtn.layer.cornerRadius = 3.f;
    
    [self loadResourceData];
    [self loadPostData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
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
}

- (void)keyboardWillChangeFrame:(NSNotification *)noti {
    //弹出时间
    CGFloat animaDuration = [noti.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //拿到键盘弹出的frame
    CGRect frame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.bottomConstraint.constant = SCREEN_HEIGHT - frame.origin.y;
    [UIView animateWithDuration:animaDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    //让键盘退出
    [self.view endEditing:YES];
}

- (void)loadResourceData {
    
    @weakify(self);
    [SVProgressHUD show];
    [[QSYKResourceManager sharedManager] getResourceDetailWithParameters:@{@"sid" : _sid}
                                                                 success:^(QSYKResourceModel *resource) {
                                                                     @strongify(self);
                                                                     [SVProgressHUD dismiss];
                                                                     
                                                                     self.resource = resource;
                                                                     [self.tableView reloadData];
                                                                     
                                                                 } failure:^(NSError *error) {
                                                                     [SVProgressHUD dismiss];
                                                                     [SVProgressHUD showErrorWithStatus:@"加载失败"];
                                                                     [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                                                                     NSLog(@"error = %@", error);
                                                                 }];
}

- (void)loadPostData {
    
    @weakify(self);
    [SVProgressHUD show];
    [[QSYKDataManager sharedManager] requestWithMethod:QSYKHTTPMethodGET
                                             URLString:[NSString stringWithFormat:@"post/listJsonForMobile/resSid/%@", _sid]
                                            parameters:nil
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   @strongify(self);
                                                   [SVProgressHUD dismiss];
                                                   
                                                   self.post = [[QSYKPostModel alloc] initWithDictionary:responseObject error:nil];
                                                   if (_post.hot.count || _post.list.count) {
                                                       [self.tableView reloadData];
                                                   } else {
                                                       
                                                   }
                                                   
                                               } failure:^(NSError *error) {
                                                   NSLog(@"error = %@", error);
                                               }];
}

#pragma mark tableView delegate & dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 0) {
//        return _resource ? 1 : 0;
//    } else {
//        return 10;
//    }
    return _resource ? 1 : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"最新";
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // width = content标签左右边距离屏幕左右边的距离的和
        CGFloat extraHeight = [QSYKUtility heightForMutilLineLabel:_resource.content
                                                              font:16.f
                                                             width:SCREEN_WIDTH - 8 * 4];
        
        switch (_type) {
            case 1: {
                
                return [QSYKTopicTableViewCell cellBaseHeight] + extraHeight;
            }
                break;
            case 2: {
                // 图片类型的cell的高度根据图片本事的宽高比来计算在不同屏幕宽度下的高度
                extraHeight += (SCREEN_WIDTH - 8 * 4) * _resource.img.height / _resource.img.width;
                return [QSYKPictureTableViewCell cellBaseHeight] + extraHeight;
            }
                break;
            case 3: {
                // video类型cell
                if (_resource.video.height > _resource.video.width) {
                    extraHeight += (SCREEN_WIDTH - 8 * 4);
                } else {
                    extraHeight += (SCREEN_WIDTH - 8 * 4) * _resource.video.height / _resource.video.width;
                }
                
                return [QSYKVideoTableViewCell cellBaseHeight] + extraHeight;
            }
                break;
                
            default:
                return 0;
                break;
        }
    } else {
        CGFloat extraHeight = [QSYKUtility heightForMutilLineLabel:_resource.content
                                                              font:16.f
                                                             width:SCREEN_WIDTH - 98];
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
                
                return cell;
            }
                break;
                
            default:
                return nil;
                break;
        }
    } else {
        QSYKCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_commentCell forIndexPath:indexPath];
        
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
    {
        // This indeed is an indexPath no longer visible
        // Do something to this non-visible cell...
        if (_resource.type == 3) {
            QSYKVideoTableViewCell *curCell = (QSYKVideoTableViewCell *)cell;
            [curCell reset];
        }
    }
}

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
    
}


#pragma mark Cell Delegate

- (void)shareResoureWithSid:(NSString *)sid imgSid:(NSString *)imgSid content:(NSString *)content isTopic:(BOOL)isTopic{
    [[QSYKShareManager sharedManager] showInVC:self resourceSid:sid imgSid:imgSid content:content isTopic:isTopic];
}

- (void)rateResourceWithSid:(NSString *)sid type:(NSInteger)type indexPath:(NSIndexPath *)indexPath {
    [QSYKUtility rateResourceWithSid:sid type:type];
    
    if (type == 1) {
        _resource.dig++;
    } else {
        _resource.bury++;
    }
}

- (void)commentResourceWithSid:(NSString *)sid {
    
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
