//
//  ViewController.h
//  StationCreator
//
//  Created by Sheehan Alam on 8/16/12.
//  Copyright (c) 2012 test. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPusherChannel.h"
#import "PTPusher.h"
#import "PTPusherDelegate.h"

@class PTPusher;
@class PTPusherConnectionMonitor;

@interface ViewController : UIViewController <UIWebViewDelegate, PTPusherDelegate>
{
    IBOutlet UIWebView *webView;
    
    NSMutableArray *connectedClients;
    NSMutableArray *clientsAwaitingConnection;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) PTPusher *pusher;
@property (nonatomic) PTPusherChannel *currentChannel;
@property (nonatomic, strong) PTPusherConnectionMonitor *connectionMonitor;

- (PTPusher *)lastConnectedClient;
- (PTPusher *)createClientWithAutomaticConnection:(BOOL)connectAutomatically;

@end
