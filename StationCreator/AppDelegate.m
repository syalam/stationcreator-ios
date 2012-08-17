//
//  AppDelegate.m
//  StationCreator
//
//  Created by Sheehan Alam on 8/16/12.
//  Copyright (c) 2012 test. All rights reserved.
//

#import "AppDelegate.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"
#import "NSMutableURLRequest+BasicAuth.h"

// All events will be logged
#define kLOG_ALL_EVENTS

// change this to switch between secure/non-secure connections
#define kUSE_ENCRYPTED_CHANNELS NO

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    connectedClients = [[NSMutableArray alloc] init];
    clientsAwaitingConnection = [[NSMutableArray alloc] init];
        
    // create our primary Pusher client instance
    self.pusher = [self createClientWithAutomaticConnection:YES];
    
    // we want the connection to automatically reconnect if it dies
    self.pusher.reconnectAutomatically = YES;
    
    [self subscribeToChannel:@"4f99134a9c78441eba000111"];
    
    // log all events received, regardless of which channel they come from
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePusherEvent:) name:PTPusherEventReceivedNotification object:self.pusher];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:PTPusherEventReceivedNotification object:self.pusher];
}

#pragma mark - Event notifications

- (void)handlePusherEvent:(NSNotification *)note
{
#ifdef kLOG_ALL_EVENTS
    PTPusherEvent *event = [note.userInfo objectForKey:PTPusherEventUserInfoKey];
    NSLog(@"[pusher] Received event %@", event);
#endif
}

#pragma mark - Subscribing

- (void)subscribeToChannel:(NSString *)channelName
{
    self.currentChannel = [self.pusher subscribeToChannelNamed:channelName];
    
    [self.currentChannel bindToEventNamed:@"new_content" handleWithBlock:^(PTPusherEvent *event) {
        NSLog(@"[channel event] %@",event);
    }];
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
