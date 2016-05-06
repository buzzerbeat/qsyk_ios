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
- (void)commentResourceWithSid:(NSString *)sid;
- (void)shareResoureWithSid:(NSString *)sid content:(NSString *)content;

@optional
- (void)playBtnClicked;

@end

#endif /* QSYKCellDelegate_h */
