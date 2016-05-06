//
//  WebViewController.m
//  quiz
//
//  Created by subo on 15/11/24.
//  Copyright © 2015年 subo. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (assign) BOOL isFirstStart;

@end

@implementation WebViewController


- (instancetype)init
{
    return [self initWithTitle:@"轻松一刻" url:@""];
}

- (instancetype)initWithTitle:(NSString *)title url:(NSString *)url
{
    self = [super init];
    if (self) {
        if ([url hasPrefix:@"http://"]) {
            _url = url;
        } else {
            _url = [NSString stringWithFormat:@"%@%@", @"http://a.appcq.cn/", url];
        }
        _navTitle = title;
    }
    return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _navTitle;
    self.isFirstStart = YES;
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self webViewLoadRequest];
}

- (void)webViewLoadRequest {
    NSURL *url = [NSURL URLWithString:_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[QSYKUtility UAString] forHTTPHeaderField:@"User-Agent"];
    
    [self.webView loadRequest:request];
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
