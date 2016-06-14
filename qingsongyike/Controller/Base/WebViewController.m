//
//  WebViewController.m
//  quiz
//
//  Created by subo on 15/11/24.
//  Copyright © 2015年 subo. All rights reserved.
//

#import "WebViewController.h"
#import "QSYKWebViewController.h"

@interface WebViewController () <UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (nonatomic, assign) BOOL isFirstRequest;

@end

@implementation WebViewController


- (instancetype)init
{
    return [self initWithTitle:@"抽奖" url:@""];
}

- (instancetype)initWithTitle:(NSString *)title url:(NSString *)url
{
    self = [super init];
    if (self) {
        if ([url hasPrefix:@"http://"]) {
            _url = url;
        } else {
            _url = [NSString stringWithFormat:@"%@/site/login?redirect_uri=lottery&uuid=%@", kBaseURL, UUID];
        }
        _navTitle = title;
    }
    return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _navTitle;
    self.isFirstRequest = YES;
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;

    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self webViewLoadRequest];
}

- (void)webViewLoadRequest {
    NSURL *url = [NSURL URLWithString:_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
//    NSDictionary *cookieProperties = @{
//                                       NSHTTPCookieName: @"token",
//                                       NSHTTPCookieValue: kToken,
//                                       NSHTTPCookiePath: request.URL.path,
//                                       NSHTTPCookieDomain: request.URL.host,
//                                       //                                       NSHTTPCookieOriginURL: url,   // 可选，值可以为string 或 URL 类型
//                                       };
//    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
//    
//    NSHTTPCookieStorage * cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    [cookieStorage setCookies:[NSArray arrayWithObjects:cookie, nil] forURL:url mainDocumentURL:nil];
    
    [self.webView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
//    QSYKWebViewController *aPage = [[QSYKWebViewController alloc] init];
//    aPage.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:aPage animated:YES];
    
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
