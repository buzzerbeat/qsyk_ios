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

- (void)showInVC:(UIViewController *)target resourceSid:(NSString *)resourceSid imgSid:(NSString *)imgSid content:(NSString *)content isTopic:(BOOL)isTopic {
    _shareContentView.target = target;
    _shareContentView.resourceSid = resourceSid;
    _shareContentView.shareURL = [NSString stringWithFormat:@"%@/share?sid=%@", kShareBaseURL, resourceSid];
    
    if (isTopic) {
        _shareContentView.shareImage = [UIImage imageNamed:@"AppIcon_180"];
        
        
        // sina 分享字数先知小于140，需要截取文字（"轻松一刻："前缀占5个字符，还需要把URL长度算进去）
        int maxLength = 140 - 3 - 5 - (int)_shareContentView.shareURL.length;
        if (content.length > maxLength) {
            NSString *newContent = [content substringWithRange:NSMakeRange(0, maxLength)];
            _shareContentView.shareContent = [NSString stringWithFormat:@"%@...", newContent];
            
        } else {
            _shareContentView.shareContent = content;
        }
        
    } else {
        _shareContentView.shareContent = content;
        
        NSURL *imgURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@img/show/sid/%@/w/180/h/180/t/1/show.jpg", kPictureBaseURL, imgSid]];
        NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
        _shareContentView.shareImage = imgData;
    }
    
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
