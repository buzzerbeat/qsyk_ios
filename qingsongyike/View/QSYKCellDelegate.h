//
//  QSYKCellDelegate.h
//  qingsongyike
//
//  Created by 苗慧宇 on 4/28/16.
//  Copyright © 2016 subo. All rights reserved.
//

#ifndef QSYKCellDelegate_h
#define QSYKCellDelegate_h

@protocol QSYKCellDelegate <NSObject>

- (void)rateResourceWithSid:(NSString *)sid type:(NSInteger)type indexPath:(NSIndexPath *)indexPath;
- (void)shareResoureWithSid:(NSString *)sid imgSid:(NSString *)imgSid content:(NSString *)content isTopic:(BOOL)isTopic;

@optional
- (void)commentResourceWithSid:(NSString *)sid;
- (void)ratePostWithSid:(NSString *)sid indexPath:(NSIndexPath *)indexPath;
- (void)playBtnClicked;

@end

#endif /* QSYKCellDelegate_h */
