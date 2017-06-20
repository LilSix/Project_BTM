//
//  MoreDetailViewController.m
//  Project_BTM
//


#pragma mark - .h Files

#import "MoreDetailViewController.h"


#pragma mark - Frameworks

@import WebKit;


#pragma mark -

@interface MoreDetailViewController ()<WKNavigationDelegate>

@end


#pragma mark -

@implementation MoreDetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSLog(@"_stringLWithURLForWeb = %@", _stringLWithURLForWeb);
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:[self view].bounds];
    [[self view] addSubview:webView];
    [webView setNavigationDelegate:self];
    
    
    NSURL *URL = [NSURL URLWithString:_stringLWithURLForWeb];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    [webView loadRequest:request];
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
