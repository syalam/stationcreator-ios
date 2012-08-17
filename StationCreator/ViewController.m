//
//  ViewController.m
//  StationCreator
//
//  Created by Sheehan Alam on 8/16/12.
//  Copyright (c) 2012 test. All rights reserved.
//

#import "ViewController.h"
#import "PTPusherChannel.h"
#import "PTPusherEvent.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"
#import "NSMutableURLRequest+BasicAuth.h"

// All events will be logged
#define kLOG_ALL_EVENTS

// change this to switch between secure/non-secure connections
#define kUSE_ENCRYPTED_CHANNELS NO
@interface ViewController ()

@end

@implementation ViewController

#pragma mark - Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
//
//    // Do any additional setup after loading the view, typically from a nib.
//    webView.mediaPlaybackRequiresUserAction = NO;
//    webView.mediaPlaybackAllowsAirPlay = YES;
//    webView.allowsInlineMediaPlayback = YES;
//    webView.delegate = self;
//    
//    /*
//     NSURL* url = [NSURL URLWithString:@"http://www.stationcreator.com"];
//     NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url];
//     
//     [webView loadHTMLString:embedHTML baseURL:nil];
//     [webView loadRequest:request];
//     */
//    
//    
//    [self embedYouTube:@"http://www.youtube.com/watch?v=Dl56Dd0g1Yg&feature=g-all-u" frame:[[UIScreen mainScreen] applicationFrame]];
//    [NSTimer scheduledTimerWithTimeInterval:161 target:self selector:@selector(loopVideo:) userInfo:nil repeats:YES];
//    //[self playVideo:@"http://www.youtube.com/watch?v=O__suqFB6XU&feature=g-user-u" frame:[[UIScreen mainScreen] applicationFrame]];
    
    connectedClients = [[NSMutableArray alloc] init];
    clientsAwaitingConnection = [[NSMutableArray alloc] init];
    
    // create our primary Pusher client instance
    self.pusher = [self createClientWithAutomaticConnection:YES];
    
    // we want the connection to automatically reconnect if it dies
    self.pusher.reconnectAutomatically = YES;
    
    [self subscribeToChannel:@"502c2e3e9c784452cc000023"];
    
    // log all events received, regardless of which channel they come from
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePusherEvent:) name:PTPusherEventReceivedNotification object:self.pusher];
}

- (void)viewDidUnload
{
    webView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:PTPusherEventReceivedNotification object:self.pusher];
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

#pragma mark - Pusher Channel Methods
#pragma mark - Subscribing

- (void)subscribeToChannel:(NSString *)channelName
{
    self.currentChannel = [self.pusher subscribeToChannelNamed:channelName];
    
    [self.currentChannel bindToEventNamed:@"new_content" handleWithBlock:^(PTPusherEvent *event) {
        NSLog(@"[channel event] %@",event);
        NSString* media = [event.data valueForKey:@"media"];
        
        NSLog(@"MEDIA: %@",media);
    }];
}

#pragma mark - Event notifications

- (void)handlePusherEvent:(NSNotification *)note
{
#ifdef kLOG_ALL_EVENTS
    PTPusherEvent *event = [note.userInfo objectForKey:PTPusherEventUserInfoKey];
    NSLog(@"[pusher] Received event %@", event);
#endif
}

#pragma mark - Client management

- (PTPusher *)lastConnectedClient
{
    return [connectedClients lastObject];
}

- (PTPusher *)createClientWithAutomaticConnection:(BOOL)connectAutomatically
{
    PTPusher *client = [PTPusher pusherWithKey:@"4855ecf7ba2664c81c40" connectAutomatically:NO encrypted:kUSE_ENCRYPTED_CHANNELS];
    client.delegate = self;
    [clientsAwaitingConnection addObject:client];
    if (connectAutomatically) {
        [client connect];
    }
    return client;
}

#pragma mark - PTPusherDelegate methods

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
    NSLog(@"[pusher-%@] Pusher client connected", connection.socketID);
    
    [connectedClients addObject:pusher];
    [clientsAwaitingConnection removeObject:pusher];
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
    NSLog(@"[pusher-%@] Pusher Connection failed, error: %@", pusher.connection.socketID, error);
    [clientsAwaitingConnection removeObject:pusher];
}

- (void)pusher:(PTPusher *)pusher connectionWillReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay
{
    NSLog(@"[pusher-%@] Reconnecting after %d seconds...", pusher.connection.socketID, (int)delay);
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel
{
    NSLog(@"[pusher-%@] Subscribed to channel %@", pusher.connection.socketID, channel);
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error
{
    NSLog(@"[pusher-%@] Authorization failed for channel %@", pusher.connection.socketID, channel);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authorization Failed" message:[NSString stringWithFormat:@"Client with socket ID %@ could not be authorized to join channel %@", pusher.connection.socketID, channel.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    if (pusher != self.pusher) {
        [pusher disconnect];
    }
}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent
{
    NSLog(@"[pusher-%@] Received error event %@", pusher.connection.socketID, errorEvent);
}

/* The sample app uses HTTP basic authentication.
 
 This demonstrates how we can intercept the authorization request to configure it for our app's
 authentication/authorisation needs.
 */
- (void)pusher:(PTPusher *)pusher willAuthorizeChannelWithRequest:(NSMutableURLRequest *)request
{
    NSLog(@"[pusher-%@] Authorizing channel access...", pusher.connection.socketID);
    [request setHTTPBasicAuthUsername:@"sheehan@stationcreator.com" password:@"wasabi1178"];
}


@end
