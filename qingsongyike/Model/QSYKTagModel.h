//
//  QSYKTagModel.h
//  qingsongyike
//
//  Created by 苗慧宇 on 6/24/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol QSYKTagModel
@end

@interface QSYKTagModel : JSONModel

/*
 name: "内涵段子",
 keyword: "",
 desc: "最内涵的段子，你懂的。",
 is_show: 1,
 sid: "JmZAbOrbx8L",
 logoSid: "u0x1Zg0Mwg0",
 focusCount: "2"
 */

@property (nonatomic) BOOL isShow;
@property (nonatomic) BOOL isFocus;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *sid;
@property (nonatomic, copy) NSString *logoSid;
@property (nonatomic, copy) NSString *focusCount;

@end
