//
//  KRVideoPlayerController.h
//  KRKit
//
//  Created by aidenluo on 5/23/15.
//  Copyright (c) 2015 36kr. All rights reserved.
//

@import MediaPlayer;
#import "KRVideoPlayerControlView.h"

@interface KRVideoPlayerController : MPMoviePlayerController

@property (nonatomic, copy)void(^dimissCompleteBlock)(void);
@property (nonatomic, assign) CGRect frame;
//@property (nonatomic, strong) KRVideoPlayerControlView *videoControl;

@property (copy) void (^pauseBlock) (void);
@property (copy) void (^finishBlock) (void);

- (instancetype)initWithFrame:(CGRect)frame;
- (void)showInWindow;
- (void)dismiss;

@end