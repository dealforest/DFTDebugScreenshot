//
//  DFTViewController.m
//  DFTDebugScreenShotDemo
//
//  Created by Toshihiro Morimoto on 8/19/14.
//  Copyright (c) 2014 Toshihiro Morimoto. All rights reserved.
//

#import "DFTViewController.h"

@interface DFTViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation DFTViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSURL *url = [NSURL URLWithString:@"http://blog.dealforest.net"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark -
#pragma mark DFTDebugScreenShot

- (id)dft_debugObjectOfScreenshot {
    return @{
             @"data": self.data,
             @"webView": @{
                     @"title": [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"],
                     @"cookie": [self.webView stringByEvaluatingJavaScriptFromString:@"document.cookie"],
                     @"userAgent": [self.webView stringByEvaluatingJavaScriptFromString:@"window.navigator.userAgent"],
                     @"scrollOffset": @{
                             @"x": [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollLeft || document.body.scrollLeft"],
                             @"y": [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollTop || document.body.scrollTop"]
                             },
                     },
             };
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark IBAction

- (IBAction)touchedCaptureButton:(id)sender {
    [DFTDebugScreenshot capture];
}


@end
