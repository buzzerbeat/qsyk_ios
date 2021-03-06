//
//  KRVideoPlayerController.m
//  KRKit
//
//  Created by aidenluo on 5/23/15.
//  Copyright (c) 2015 36kr. All rights reserved.
//

#import "KRVideoPlayerController.h"
#import "KRVideoPlayerControlView.h"

static const CGFloat kVideoPlayerControllerAnimationTimeinterval = 0.3f;

@interface KRVideoPlayerController ()

@property (nonatomic, strong) KRVideoPlayerControlView *videoControl;
@property (nonatomic, strong) UIView *movieBackgroundView;
@property (nonatomic, assign) BOOL isFullscreenMode;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, strong) UIView *originView;

@property (nonatomic, assign) float x;     // 开始滑动时手指的x坐标
@property (nonatomic, assign) float sliderValue;   //开始滑动时slider的value
@property (nonatomic, assign) CGFloat sliderWidth;

@end

@implementation KRVideoPlayerController

- (void)dealloc
{
    [self cancelObserver];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor blackColor];
        self.controlStyle = MPMovieControlStyleNone;
        [self.view addSubview:self.videoControl];
        self.videoControl.frame = self.view.bounds;
        [self configObserver];
        [self configControlAction];
    }
    return self;
}

#pragma mark - Override Method

- (void)setContentURL:(NSURL *)contentURL
{
    [self stop];
    [super setContentURL:contentURL];
    [self play];
    self.videoControl.pauseButton.hidden = YES;
    self.videoControl.playButton.hidden = YES;
    [self.videoControl.indicatorView startAnimating];
}

#pragma mark - Publick Method

- (void)showInWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (!keyWindow) {
        keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    [keyWindow addSubview:self.view];
    self.view.alpha = 0.0;
    [UIView animateWithDuration:kVideoPlayerControllerAnimationTimeinterval animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)dismiss
{
    [self stop];
    [self stopDurationTimer];
    [UIView animateWithDuration:kVideoPlayerControllerAnimationTimeinterval animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        if (self.dimissCompleteBlock) {
            self.dimissCompleteBlock();
        }
    }];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Private Method

- (void)configObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerLoadStateDidChangeNotification) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerReadyForDisplayDidChangeNotification) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMovieDurationAvailableNotification) name:MPMovieDurationAvailableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackDidFinishNotification) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFrame:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)cancelObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configControlAction
{
    [self.videoControl.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
    
    
    UIPanGestureRecognizer *swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeBegin:)];
    [self.videoControl.bottomBar addGestureRecognizer:swipeGesture];
    self.sliderWidth = self.videoControl.progressSlider.frame.size.width;
    
    [self setProgressSliderMaxMinValues];
    [self monitorVideoPlayback];
}

- (void)onMPMoviePlayerPlaybackStateDidChangeNotification
{
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        self.videoControl.pauseButton.hidden = NO;
        self.videoControl.playButton.hidden = YES;
        self.videoControl.backButton.hidden = YES;
        [self startDurationTimer];
        [self.videoControl autoFadeOutControlBar];
    } else {
        self.videoControl.pauseButton.hidden = YES;
        self.videoControl.playButton.hidden = NO;
        self.videoControl.backButton.hidden = YES;
        [self stopDurationTimer];
        if (self.playbackState == MPMoviePlaybackStatePaused) {
            [self.videoControl animateShow];
        }
    }
}

- (void)onMPMoviePlayerLoadStateDidChangeNotification
{
//    if (self.loadState == MPMovieLoadStatePlayable) {
//        [self.videoControl.indicatorView startAnimating];
//    }
}

- (void)onMPMoviePlayerReadyForDisplayDidChangeNotification
{
    
}

- (void)onMPMovieDurationAvailableNotification
{
    [self.videoControl animateHide];    // 开始播放时隐藏视频状态栏
    [self.videoControl.indicatorView stopAnimating];
    [self setProgressSliderMaxMinValues];
}

- (void)onMPMoviePlayerPlaybackDidFinishNotification {
    [self pause];
    self.videoControl.playButton.hidden = NO;
    self.videoControl.pauseButton.hidden = YES;
    
    if (self.duration == self.currentPlaybackTime && self.finishBlock) {
        self.finishBlock();
    }
    
    // 播放结束后退出全屏
    [self shrinkScreenButtonClick];
}

- (void)playButtonClick
{
    [self play];
    self.videoControl.playButton.hidden = YES;
    self.videoControl.pauseButton.hidden = NO;
}

- (void)pauseButtonClick
{
    [self pause];
    self.videoControl.playButton.hidden = NO;
    self.videoControl.pauseButton.hidden = YES;
    
    if (self.pauseBlock) {
        self.pauseBlock();
    }
}

- (void)backButtonClick
{
//    [self dismiss];
    [self shrinkScreenButtonClick];
}

- (void)fullScreenButtonClick
{
    if (self.isFullscreenMode) {
        return;
    }
    
    [QSYKUtility hideTopWindow];
    
    self.originFrame = self.view.frame;
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = frame = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? CGRectMake((width - height) / 2, (height - width) / 2, height, width) : CGRectMake(0, 0, width, height);
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (!keyWindow) {
        keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    self.originView = self.view.superview;
    [keyWindow addSubview:self.view];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = frame;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        }
    } completion:^(BOOL finished) {
        self.isFullscreenMode = YES;
        self.videoControl.backButton.hidden = NO;
        self.videoControl.fullScreenButton.hidden = YES;
        self.videoControl.shrinkScreenButton.hidden = NO;
    }];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)shrinkScreenButtonClick
{
    if (!self.isFullscreenMode) {
        return;
    }
    
    [QSYKUtility hideTopWindow];
    
    [self.originView addSubview:self.view];
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setTransform:CGAffineTransformIdentity];
        self.frame = self.originFrame;
    } completion:^(BOOL finished) {
        self.isFullscreenMode = NO;
        self.videoControl.backButton.hidden = YES;
        self.videoControl.fullScreenButton.hidden = NO;
        self.videoControl.shrinkScreenButton.hidden = YES;
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoViewShrinkedNotification" object:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)updateFrame:(NSNotification *)noti {
    if (self.isFullscreenMode) {
        CGFloat height = [[UIScreen mainScreen] bounds].size.width;
        CGFloat width = [[UIScreen mainScreen] bounds].size.height;
        CGRect frame = CGRectMake(0, 0, height, width);
        [UIView animateWithDuration:0.3f animations:^{
            self.frame = frame;
        } completion:^(BOOL finished) {
            self.isFullscreenMode = YES;
            self.videoControl.backButton.hidden = NO;
            self.videoControl.fullScreenButton.hidden = YES;
            self.videoControl.shrinkScreenButton.hidden = NO;
        }];
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoViewShrinkedNotification" object:nil];
    }
}

- (void)swipeBegin:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:pan.view];
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.x = point.x;
        [self pause];
        self.sliderValue = self.videoControl.progressSlider.value;
        [self.videoControl cancelAutoFadeOutControlBar];
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        float curValue = self.sliderValue + ((point.x - self.x) / 1.5 * self.duration / self.sliderWidth);
        self.videoControl.progressSlider.value = curValue;
        
        double currentTime = floor(self.videoControl.progressSlider.value);
        double totalTime = floor(self.duration);
        [self setTimeLabelValues:currentTime totalTime:totalTime];
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        [self setCurrentPlaybackTime:floor(self.videoControl.progressSlider.value)];
        [self play];
        [self.videoControl autoFadeOutControlBar];
    }
}

- (void)setProgressSliderMaxMinValues {
    CGFloat duration = self.duration;
    self.videoControl.progressSlider.minimumValue = 0.f;
    self.videoControl.progressSlider.maximumValue = floor(duration);
}

- (void)progressSliderTouchBegan:(UISlider *)slider {
    [self pause];
    [self.videoControl cancelAutoFadeOutControlBar];
}

- (void)progressSliderTouchEnded:(UISlider *)slider {
    [self setCurrentPlaybackTime:floor(slider.value)];
    [self play];
    [self.videoControl autoFadeOutControlBar];
}

- (void)progressSliderValueChanged:(UISlider *)slider {
    double currentTime = floor(slider.value);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
}

- (void)monitorVideoPlayback
{
    double currentTime = (self.currentPlaybackTime);
    double totalTime = floor(self.duration);
    
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    self.videoControl.progressSlider.value = floor(currentTime);
}

- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
    
    double minutesRemaining = floor(totalTime / 60.0);;
    double secondsRemaining = floor(fmod(totalTime, 60.0));;
    NSString *timeRmainingString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesRemaining, secondsRemaining];
    self.videoControl.timeLabel.text = timeRmainingString;
//    self.videoControl.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeElapsedString,timeRmainingString];

    
    self.videoControl.timeElapsedLabel.text = timeElapsedString;
}

- (void)startDurationTimer
{
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopDurationTimer
{
    [self.durationTimer invalidate];
}

- (void)fadeDismissControl
{
    [self.videoControl animateHide];
}

#pragma mark - Property

- (KRVideoPlayerControlView *)videoControl
{
    if (!_videoControl) {
        _videoControl = [[KRVideoPlayerControlView alloc] init];
    }
    return _videoControl;
}

- (UIView *)movieBackgroundView
{
    if (!_movieBackgroundView) {
        _movieBackgroundView = [UIView new];
        _movieBackgroundView.alpha = 0.0;
        _movieBackgroundView.backgroundColor = [UIColor blackColor];
    }
    return _movieBackgroundView;
}

- (void)setFrame:(CGRect)frame
{
    [self.view setFrame:frame];
    [self.videoControl setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.videoControl setNeedsLayout];
    [self.videoControl layoutIfNeeded];
}


@end
