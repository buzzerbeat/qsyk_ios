//
//  QSYKVideoModel.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface QSYKVideoModel : JSONModel
@property (nonatomic, copy  ) NSString *sid;
@property (nonatomic, copy  ) NSString *thumb;// 视频缩略图
@property (nonatomic, copy  ) NSString *length;// 视频长度，例：2分13秒
@property (nonatomic, copy  ) NSString *url;
@property (nonatomic, assign) int      width;
@property (nonatomic, assign) int      height;

@end
