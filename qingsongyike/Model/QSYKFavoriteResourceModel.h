//
//  QSYKFavoriteResourceModel.h
//  qingsongyike
//
//  Created by 苗慧宇 on 5/16/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "QSYKImageModel.h"
#import "QSYKVideoModel.h"

@interface QSYKFavoriteResourceModel : JSONModel
@property (nonatomic, assign) int type;
@property (nonatomic, assign) int dig;
@property (nonatomic, assign) int bury;
@property (nonatomic, assign) int share;
@property (nonatomic, assign) int post;
@property (nonatomic, assign) int favorite;
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *sid;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userAvatar;
@property (nonatomic, copy) NSString *pubTimeElapsed;
@property (nonatomic, strong) QSYKImageModel *relImage;
@property (nonatomic, strong) QSYKVideoModel *relVideo;

@end

@interface QSYKFavoriteModel : JSONModel
@property (nonatomic, strong) QSYKFavoriteResourceModel *resource;
@property (nonatomic, copy) NSString *timeElapsed;

@end

@interface QSYKFavoriteResourceList : NSObject
@property (nonatomic, strong) NSArray *list;

- (instancetype)initWithArray:(NSArray *)array;

@end
