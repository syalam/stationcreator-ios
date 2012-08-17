//
//  ViewController.m
//  StationCreator
//
//  Created by Sheehan Alam on 8/16/12.
//  Copyright (c) 2012 test. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    webView.mediaPlaybackRequiresUserAction = NO;
    webView.mediaPlaybackAllowsAirPlay = YES;
    webView.allowsInlineMediaPlayback = YES;
    webView.delegate = self;
    
    /*
     NSURL* url = [NSURL URLWithString:@"http://www.stationcreator.com"];
     NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
     
     [webView loadHTMLString:embedHTML baseURL:nil];
     [webView loadRequest:request];
     */
    
    
    [self embedYouTube:@"http://www.youtube.com/watch?v=Dl56Dd0g1Yg&feature=g-all-u" frame:[[UIScreen mainScreen] applicationFrame]];
    [NSTimer scheduledTimerWithTimeInterval:161 target:self selector:@selector(loopVideo:) userInfo:nil repeats:YES];
    //[self playVideo:@"http://www.youtube.com/watch?v=O__suqFB6XU&feature=g-user-u" frame:[[UIScreen mainScreen] applicationFrame]];
    
    
}

- (void)viewDidUnload
{
    webView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - YouTube Methods
-(void)loopVideo:(id)sender
{
    NSLog(@"loop called");
    [self embedYouTube:@"http://www.youtube.com/watch?v=Dl56Dd0g1Yg&feature=g-all-u" frame:[[UIScreen mainScreen] applicationFrame]];
}

- (void)embedYouTube:(NSString*)url frame:(CGRect)frame {
    NSString* embedHTML = @"\
    <html><head>\
    <style type=\"text/css\">\
    body {\
    background-color: transparent;\
    color: white;\
    }\
    </style>\
    </head><body style=\"margin:0\">\
    <embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
    width=\"%0.0f\" height=\"%0.0f\"></embed>\
    </body></html>";
    NSString* html = [NSString stringWithFormat:embedHTML, url, frame.size.width, frame.size.height];
    if(webView == nil) {
        webView = [[UIWebView alloc] initWithFrame:frame];
        [self.view addSubview:webView];
    }
    [webView loadHTMLString:html baseURL:nil];
}


 //This only works if you have the video source
- (void)playVideo:(NSString *)urlString frame:(CGRect)frame {
    NSString *embedHTML = @"\
    <html><head>\
    <style type=\"text/css\">\
    body {\
    background-color: transparent;\
    color: white;\
    }\
    </style>\
    <script>\
    function load(){document.getElementById(\"yt\").play();}\
    </script>\
    </head><body onload=\"load()\"style=\"margin:0\">\
    <video id=\"yt\" src=\"%@\" \
    width=\"%0.0f\" height=\"%0.0f\" autoplay controls></video>\
    </body></html>";
    NSString *html = [NSString stringWithFormat:embedHTML, urlString, frame.size.width, frame.size.height];
    webView = [[UIWebView alloc] initWithFrame:frame];
    [webView loadHTMLString:html baseURL:nil];
    [self.view addSubview:webView];
    NSLog(@"%@",html);
}

#pragma mark - WebView Delegate Methods
- (void)webViewDidFinishLoad:(UIWebView *)_webView {
    UIButton *b = [self findButtonInView:_webView];
    [b sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (UIButton *)findButtonInView:(UIView *)view {
    UIButton *button = nil;
    
    if ([view isMemberOfClass:[UIButton class]]) {
        return (UIButton *)view;
    }
    
    if (view.subviews && [view.subviews count] > 0) {
        for (UIView *subview in view.subviews) {
            button = [self findButtonInView:subview];
            if (button) return button;
        }
    }
    return button;
}

@end
