//
//  QSYKBaseTableViewCell.h
//  qingsongyike
//
//  Created by 苗慧宇 on 5/16/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSYKCellDelegate.h"
#import "QSYKFavoriteResourceModel.h"

@interface QSYKBaseTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userAvatar;
@property (nonatomic, copy) NSString *pubTime;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *sid;  // resourceSid
@property (nonatomic, assign) NSInteger dig;
@property (nonatomic, assign) NSInteger bury;
@property (nonatomic, strong) QSYKImageModel *img;
@property (nonatomic, strong) QSYKVideoModel *video;
@property (nonatomic) BOOL isTopic;

@end
