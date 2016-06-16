//
//  QSYKWebViewController.m
//  qingsongyike
//
//  Created by 苗慧宇 on 6/1/16.
//  Copyright © 2016 subo. All rights reserved.
//

#import "QSYKWebViewController.h"
#import "WebViewController.h"
//#import <UINavigationController+FDFullscreenPopGesture.h>
#import <NJKWebViewProgressView.h>
#import <NJKWebViewProgress.h>

@interface QSYKWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *closeButton;
@property (nonatomic, assign) BOOL isFirstRequest;

@end

@implementation QSYKWebViewController

- (instancetype)init
{
    return [self initWithTitle:@"抽奖" url:@""];
}

- (instancetype)initWithTitle:(NSString *)title url:(NSString *)url
{
    self = [super init];
    if ([url hasPrefix:@"http://"]) {
        _url = url;
    } else {
        _url = [NSString stringWithFormat:@"%@/site/login?redirect_uri=lottery&uuid=%@", kBaseURL, UUID];
    }
    _navTitle = title;
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = _navTitle;
    self.isFirstRequest = YES;
    
    _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _backButton.frame = CGRectMake(0, 0, 45, 30);
    _backButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [_backButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [_backButton setTitle:@"返回" forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:_backButton];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _closeButton.frame = CGRectMake(0, 0, 30, 30);
//    _closeButton.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 15);
//    [_closeButton setImage:[UIImage imageNamed:@"result_error"] forState:UIControlStateNormal];
    [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeWebView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithCustomView:_closeButton];
    _closeButton.hidden = YES;
    
    self.navigationItem.leftBarButtonItems = @[backItem, closeItem];
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
//    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
//    self.progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
//    _webView.delegate = _progressProxy;
//    _progressProxy.webViewProxyDelegate = self;
//    _progressProxy.progressDelegate = self;
//    
//    self.progressView = [[NJKWebViewProgressView alloc] initWithFrame:CGRectMake(0, self.view.y, self.view.width, 2)];
//    [self.view addSubview:_progressView];
//    [self.view bringSubviewToFront:_progressView];
    
    [self webViewLoadRequestWithURL:_url];
}

- (void)webViewLoadRequestWithURL:(NSString *)aURL {
    NSURL *url = [NSURL URLWithString:aURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [self.webView loadRequest:request];
}

/*
- (void)setCookie{
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"uid" forKey:NSHTTPCookieName];
    [cookieProperties setObject:[UserManager shardManager].user.userId forKey:NSHTTPCookieValue];
    [cookieProperties setObject:kWebUrl forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:kWebUrl forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    
    // set expiration to one month from now or any NSDate of your choosing
    // this makes the cookie sessionless and it will persist across web sessions and app launches
    /// if you want the cookie to be destroyed when your app exits, don't set this
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}
*/

- (void)backAction {
    if (self.webView.canGoBack) {
        self.closeButton.hidden = NO;
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)closeWebView {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    NSLog(@"%f", progress);
    [_progressView setProgress:progress animated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
//    [self webViewLoadRequestWithURL:request.URL.absoluteString];
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:@"加载失败"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
