//
//  KRVideoPlayerControlView.m
//  KRKit
//
//  Created by aidenluo on 5/23/15.
//  Copyright (c) 2015 36kr. All rights reserved.
//

#import "KRVideoPlayerControlView.h"

static const CGFloat kVideoControlBarHeight = 40.0;
static const CGFloat kVideoControlAnimationTimeinterval = 0.3;
static const CGFloat kVideoControlTimeLabelFontSize = 12.0;
static const CGFloat kVideoControlBarAutoFadeOutTimeinterval = 3.0;

@interface KRVideoPlayerControlView ()

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic, strong) UIButton *shrinkScreenButton;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *timeElapsedLabel;
@property (nonatomic, assign) BOOL isBarShowing;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation KRVideoPlayerControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.topBar];
        [self addSubview:self.playButton];
        [self addSubview:self.pauseButton];
        self.playButton.hidden = YES;
        self.pauseButton.hidden = YES;
        [self.topBar addSubview:self.backButton];
        self.backButton.hidden = YES;
        [self addSubview:self.bottomBar];
        [self.bottomBar addSubview:self.fullScreenButton];
        [self.bottomBar addSubview:self.shrinkScreenButton];
        self.shrinkScreenButton.hidden = YES;
        [self.bottomBar addSubview:self.progressSlider];
        [self.bottomBar addSubview:self.timeLabel];
        [self.bottomBar addSubview:self.timeElapsedLabel];
        [self addSubview:self.indicatorView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.topBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), kVideoControlBarHeight);
    self.backButton.frame = CGRectMake(5, 5, CGRectGetWidth(self.backButton.bounds), CGRectGetHeight(self.backButton.bounds));
    self.bottomBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetHeight(self.bounds) - kVideoControlBarHeight, CGRectGetWidth(self.bounds), kVideoControlBarHeight);
//    self.playButton.frame = CGRectMake(CGRectGetMinX(self.bottomBar.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.playButton.bounds)/2, CGRectGetWidth(self.playButton.bounds), CGRectGetHeight(self.playButton.bounds));
    self.playButton.frame = self.bounds;
    self.pauseButton.frame = CGRectMake(0, 0, 50, 50);
    self.pauseButton.center = CGPointMake(CGRectGetMidX(self.playButton.frame), CGRectGetMidY(self.playButton.frame));
    self.timeElapsedLabel.frame = CGRectMake(CGRectGetMinX(self.bottomBar.bounds) + 4, CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.timeElapsedLabel.bounds)/2, CGRectGetWidth(self.timeElapsedLabel.bounds), CGRectGetHeight(self.timeElapsedLabel.bounds));
    self.fullScreenButton.frame = CGRectMake(CGRectGetWidth(self.bottomBar.bounds) - CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.fullScreenButton.bounds)/2, CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.fullScreenButton.bounds));
    self.shrinkScreenButton.frame = self.fullScreenButton.frame;
    self.progressSlider.frame = CGRectMake(CGRectGetMaxX(self.timeElapsedLabel.frame), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.progressSlider.bounds)/2, CGRectGetMinX(self.fullScreenButton.frame) - CGRectGetMaxX(self.timeElapsedLabel.frame) * 2, CGRectGetHeight(self.progressSlider.bounds));
    self.timeLabel.frame = CGRectMake(CGRectGetMaxX(self.progressSlider.frame), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.timeElapsedLabel.bounds)/2, CGRectGetWidth(self.timeElapsedLabel.bounds), CGRectGetHeight(self.timeElapsedLabel.bounds));
    self.indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    self.isBarShowing = YES;
}

- (void)animateHide
{
    if (!self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:kVideoControlAnimationTimeinterval animations:^{
        self.topBar.alpha = 0.0;
        self.bottomBar.alpha = 0.0;
        self.pauseButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = NO;
    }];
}

- (void)animateShow
{
    if (self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:kVideoControlAnimationTimeinterval animations:^{
        self.topBar.alpha = 1.0;
        self.bottomBar.alpha = 1.0;
        self.pauseButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = YES;
        [self autoFadeOutControlBar];
    }];
}

- (void)autoFadeOutControlBar
{
    if (!self.isBarShowing) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
    [self performSelector:@selector(animateHide) withObject:nil afterDelay:kVideoControlBarAutoFadeOutTimeinterval];
}

- (void)cancelAutoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
}

- (void)onTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.isBarShowing) {
            [self animateHide];
        } else {
            [self animateShow];
        }
    }
}

#pragma mark - Property

- (UIView *)topBar
{
    if (!_topBar) {
        _topBar = [UIView new];
        _topBar.backgroundColor = [UIColor clearColor];
    }
    return _topBar;
}

- (UIView *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [UIView new];
        _bottomBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _bottomBar;
}

- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
        _playButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
    }
    return _playButton;
}

- (UIButton *)pauseButton
{
    if (!_pauseButton) {
        _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        _pauseButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
    }
    return _pauseButton;
}

- (UIButton *)fullScreenButton
{
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-fullscreen"]] forState:UIControlStateNormal];
        _fullScreenButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
    }
    return _fullScreenButton;
}

- (UIButton *)shrinkScreenButton
{
    if (!_shrinkScreenButton) {
        _shrinkScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shrinkScreenButton setImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-shrinkscreen"]] forState:UIControlStateNormal];
        _shrinkScreenButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
    }
    return _shrinkScreenButton;
}

- (UISlider *)progressSlider
{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] init];
        [_progressSlider setThumbImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-point"]] forState:UIControlStateNormal];
        
        [_progressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
        [_progressSlider setMaximumTrackTintColor:[UIColor lightGrayColor]];
        _progressSlider.value = 0.f;
        _progressSlider.continuous = YES;
    }
    return _progressSlider;
}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"show_image_back_icon"] forState:UIControlStateNormal];
        _backButton.bounds = CGRectMake(0, 0, 30, 30);
    }
    return _backButton;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:kVideoControlTimeLabelFontSize];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.text = @"00:00";
        _timeLabel.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
    }
    return _timeLabel;
}

- (UILabel *)timeElapsedLabel {
    if (!_timeElapsedLabel) {
        _timeElapsedLabel = [UILabel new];
        _timeElapsedLabel.backgroundColor = [UIColor clearColor];
        _timeElapsedLabel.font = [UIFont systemFontOfSize:kVideoControlTimeLabelFontSize];
        _timeElapsedLabel.textColor = [UIColor whiteColor];
        _timeElapsedLabel.textAlignment = NSTextAlignmentLeft;
        _timeElapsedLabel.text = @"00:00";
        _timeElapsedLabel.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
    }
    return _timeElapsedLabel;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_indicatorView stopAnimating];
    }
    return _indicatorView;
}

#pragma mark - Private Method

- (NSString *)videoImageName:(NSString *)name
{
    if (name) {
        NSString *path = [NSString stringWithFormat:@"KRVideoPlayer.bundle/%@",name];
        return path;
    }
    return nil;
}

@end
