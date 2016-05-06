//
//  QSYKImageModel.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface QSYKImageModel : JSONModel
@property (nonatomic, copy  ) NSString  *sid;
@property (nonatomic, copy  ) NSString  *mine;// 例：image/gif
@property (nonatomic, copy  ) NSString  *extension;// 图片后缀，例：gif
@property (nonatomic, assign) int       width;
@property (nonatomic, assign) int       height;
@property (nonatomic, assign) int       size;
@property (nonatomic, assign) BOOL      dynamic;// 是否动图

@end
