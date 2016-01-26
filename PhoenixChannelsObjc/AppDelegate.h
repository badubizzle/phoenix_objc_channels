//
//  AppDelegate.h
//  PhoenixChannelsObjc
//
//  Created by Badu on 1/25/16.
//  Copyright (c) 2016 Badu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Socket;
@class Channel;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, strong)Socket *socket;
-(void)sendMessage:(NSString*)message;
@property(nonatomic, strong)Channel *lobby;
@end

