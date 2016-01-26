//
//  Channel.h
//  PhoenixChannelsObjc
//
//  Created by Badu on 1/25/16.
//  Copyright (c) 2016 Badu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ChannelCallback)(NSString *__nonnull event, NSDictionary *__nonnull payload);

typedef void(^ChannelMessageCallback)(NSDictionary *__nonnull payload);
typedef void(^ChannelJoinedCallback)(BOOL success, NSString *status);

@class Socket;
@interface Channel : NSObject
@property(nonatomic, strong)NSString * __nonnull topic;
@property(nonatomic, strong)NSDictionary *__nullable payload;
@property(nonatomic, weak)Socket * __nonnull socket;
@property(nonatomic, strong)NSMutableDictionary *bindings;

-(void)reset;
-(instancetype)initWithTopic:(NSString* __nonnull)topic;
-(instancetype)initWithTopic:(NSString* __nonnull)topic payload:(NSDictionary*__nullable)payload socket:(Socket*__nonnull)socket;
-(BOOL)isMember:(NSString*__nonnull)topic;
-(void)trigger:(NSString * __nonnull)event payload:(NSDictionary*__nonnull)payload;
-(void)join;
-(void)leave;
-(void)sendMessage:(NSString*)message;
-(void)on:(NSString *)event callback:(ChannelMessageCallback)callback;
-(void)onJoined:(ChannelJoinedCallback)callback;
@end
