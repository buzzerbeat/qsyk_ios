//
//  QSYKShareManager.m
//  qingsongyike
//
//  Created by 苗慧宇 on 4/27/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKShareManager.h"
#import "QSYKSharePopupView.h"
#import "KLCPopup.h"

@interface QSYKShareManager()
@property (strong, nonatomic) KLCPopup *popup;
@property (nonatomic, strong) QSYKSharePopupView *shareContentView;

@end

@implementation QSYKShareManager

- (instancetype)init {
    if (self = [super init]) {
        self.shareContentView = [[NSBundle mainBundle] loadNibNamed:@"QSYKSharePopupView" owner:nil options:nil][0];
        _shareContentView.width = SCREEN_WIDTH;
        
        @weakify(self);
        _shareContentView.dismissPopupBlock = ^{
            @strongify(self);
            [self.popup dismiss:YES];
        };
    }
    return self;
}

+ (QSYKShareManager *)sharedManager {
    static QSYKShareManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QSYKShareManager alloc] init];
    });
    return instance;
}

- (void)showInVC:(UIViewController *)target resourceSid:(NSString *)resourceSid content:(NSString *)content {
    _shareContentView.target = target;
    _shareContentView.shareTitle = content;
    _shareContentView.shareContent = content;
    _shareContentView.resourceSid = resourceSid;
    _shareContentView.shareURL = [NSString stringWithFormat:@"http://c.appcq.cn/share?sid=%@", resourceSid];
    
    self.popup = [KLCPopup popupWithContentView:_shareContentView
                                       showType:KLCPopupShowTypeSlideInFromBottom
                                    dismissType:KLCPopupDismissTypeSlideOutToBottom
                                       maskType:KLCPopupMaskTypeDimmed
                       dismissOnBackgroundTouch:YES
                          dismissOnContentTouch:NO
                  ];
    
    KLCPopupLayout layout = KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutBottom);
    [self.popup showWithLayout:layout];
}

@end
