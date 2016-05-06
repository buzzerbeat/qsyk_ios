
//
//  QSYKSettingsTableViewController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/26/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKSettingsTableViewController.h"
#import "WebViewController.h"

#define CUR_NOTI_TYPES  [[UIApplication sharedApplication] currentUserNotificationSettings].types

@interface QSYKSettingsTableViewController ()
@property (nonatomic, strong) NSArray *cellTitles;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger oldType;

@end


@implementation QSYKSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    
    self.cellTitles = @[
                        @"当前版本",
                        @"评分",
                        @"清除缓存",
                        @"仅WIFI状态下自动加载图片",
                        @"推送消息",
                        @"用户协议(EULA)",
                        ];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.oldType = CUR_NOTI_TYPES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(updateUserNotificationSettings) userInfo:nil repeats:YES];
}

- (void)updateUserNotificationSettings {
    // 如果改变了是否接收通知，刷新页面显示
    if (_oldType != CUR_NOTI_TYPES) {
        _oldType = CUR_NOTI_TYPES;
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    cell.textLabel.text = _cellTitles[indexPath.row];
    
    if (indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.font = [UIFont systemFontOfSize:14.f];
        valueLabel.text = kCurrentAppVersion;
        
        [cell.contentView addSubview:valueLabel];
        [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView);
            make.right.equalTo(cell.contentView).with.offset(-10.f);
        }];
    } else if (indexPath.row == 1) {
        
    }  else if (indexPath.row == 2) {
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.font = [UIFont systemFontOfSize:14.f];
        valueLabel.text = [NSString stringWithFormat:@"%.0fM", ((float)[SDImageCache sharedImageCache].getSize / 1024 / 1024)];
        
        [cell.contentView addSubview:valueLabel];
        [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView);
            make.right.equalTo(cell.contentView);
        }];
    }  else if (indexPath.row == 3) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UISwitch *wifiSwitch = [[UISwitch alloc] init];
        wifiSwitch.on = kIsAutoLoadImgOnlyInWifi;
        [wifiSwitch addTarget:self action:@selector(wifiSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:wifiSwitch];
        [wifiSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView);
            make.right.equalTo(cell.contentView).with.offset(-10.f);
        }];
    } else if (indexPath.row == 4) {
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.font = [UIFont systemFontOfSize:14.f];

        valueLabel.text = CUR_NOTI_TYPES == 0 ? @"已关闭" : @"已开启";
        
        [cell.contentView addSubview:valueLabel];
        [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.contentView);
            make.right.equalTo(cell.contentView);
        }];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        NSString *appStoreStr = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1034156676";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreStr]];
    } else if(indexPath.row == 2) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancleAction];
        
        UIAlertAction *clearAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            SDImageCache *imageCache = [SDImageCache sharedImageCache];
            NSLog(@"缓存大小 = %luld", (unsigned long)imageCache.getSize);
            [imageCache clearMemory];
            [imageCache clearDisk];
            
            [self.tableView reloadData];
        }];
        [alert addAction:clearAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else if(indexPath.row == 4) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    } else if(indexPath.row == 5) {
        WebViewController *webView = [[WebViewController alloc] initWithTitle:@"用户协议" url:@"http://a.appcq.cn/mobile/page/pagename/qingsong"];
        webView.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:webView animated:YES];
    }
}

- (void)wifiSwitchValueChanged:(UISwitch *)aSwitch {
    NSLog(@"switch value changed --- %d !", aSwitch.isOn);
    
    [[NSUserDefaults standardUserDefaults] setBool:aSwitch.isOn forKey:kIsAutoLoadImgOnlyInWifiKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
