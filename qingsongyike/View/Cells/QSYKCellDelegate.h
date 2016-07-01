//
//  QSYKCellDelegate.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/28/16.
//  Copyright © 2016 subo. All rights reserved.
//

#ifndef QSYKCellDelegate_h
#define QSYKCellDelegate_h
@class QSYKTagModel;

@protocol QSYKCellDelegate <NSObject>

- (void)rateResourceWithSid:(NSString *)sid type:(NSInteger)type indexPath:(NSIndexPath *)indexPath;
- (void)shareResoureWithSid:(NSString *)sid imgSid:(NSString *)imgSid content:(NSString *)content isTopic:(BOOL)isTopic;

@optional
- (void)deleteResourceAtIndexPath:(NSIndexPath *)indexPath;
- (void)tagTappedWithInfo:(QSYKTagModel *)tag;
- (void)locatePostAtIndexPath:(NSIndexPath *)indexPath;
- (void)ratePostWithSid:(NSString *)sid indexPath:(NSIndexPath *)indexPath;
- (void)playBtnClicked;

@end

#endif /* QSYKCellDelegate_h */
