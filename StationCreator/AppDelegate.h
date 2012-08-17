//
//  AppDelegate.h
//  StationCreator
//
//  Created by Sheehan Alam on 8/16/12.
//  Copyright (c) 2012 test. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPusherDelegate.h"

@class PTPusher;
@class PTPusherConnectionMonitor;

@interface AppDelegate : UIResponder <UIApplicationDelegate, PTPusherDelegate>
{
    NSMutableArray *connectedClients;
    NSMutableArray *clientsAwaitingConnection;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) PTPusher *pusher;
@property (nonatomic, strong) PTPusherConnectionMonitor *connectionMonitor;
@property (nonatomic) PTPusherChannel *currentChannel;

- (PTPusher *)lastConnectedClient;
- (PTPusher *)createClientWithAutomaticConnection:(BOOL)connectAutomatically;

@end
