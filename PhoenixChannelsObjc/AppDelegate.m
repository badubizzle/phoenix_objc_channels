//
//  AppDelegate.m
//  PhoenixChannelsObjc
//
//  Created by Badu on 1/25/16.
//  Copyright (c) 2016 Badu. All rights reserved.
//

#import "AppDelegate.h"
#import "Socket.h"
#import "Channel.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize lobby;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.socket = [[Socket alloc]initWithUrlString:@"http://localhost:5000/socket/websocket"];
    __weak AppDelegate *wSelf = self;
    [self.socket onOpen:^{
        NSLog(@"Opened from callback");
        [wSelf joinChannel];
    }];

    
    [self.socket connect];
    NSLog(@"Started");
    return YES;
}
-(void)joinChannel{
    lobby = [self.socket chan:@"rooms:lobby" payload:@{@"user":@"ios"}];
    
    [lobby onJoined:^(BOOL success, NSString *status) {
        NSLog(@"Joined room with status: %@",status);
    }];
    
    [lobby on:@"new:message" callback:^(NSDictionary * __nonnull payload) {
        NSLog(@"Received new message: %@",payload);
    }];
    
    [lobby on:@"shout" callback:^(NSDictionary * __nonnull payload) {
        NSLog(@"Received a shout: %@",payload);        
    }];
    
    [lobby join];
}
-(void)sendMessage:(NSString *)message{
    [self.lobby sendMessage:message];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
