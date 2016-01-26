//
//  Channel.m
//  PhoenixChannelsObjc
//
//  Created by Badu on 1/25/16.
//  Copyright (c) 2016 Badu. All rights reserved.
//

#import "Channel.h"
#import "Socket.h"
#import "NSDictionary+Helper.h"

#define PHOENIX_JOIN @"phx_join"
#define PHOENIX_CLOSE @"phx_close"
#define PHOENIX_ERROR @"phx_error"
#define PHOENIX_LEAVE @"phx_leave"
#define PHOENIX_REPLY @"phx_reply"

#define PHEONIX_EVENTS @[PHOENIX_JOIN, PHOENIX_CLOSE, PHOENIX_ERROR, PHOENIX_LEAVE, PHOENIX_REPLY]

@implementation Channel

-(instancetype)initWithTopic:(NSString * __nonnull)topic payload:(NSDictionary *)payload socket:(Socket *)socket{
    self= [super init];
    if(self){
        self.bindings=[NSMutableDictionary new];
        self.topic=topic;
        self.payload= payload;
        self.socket = socket;
        
    }
    return self;
}
-(instancetype)initWithTopic:(NSString * __nonnull)topic {
    self = [super init];
    if(self){
        self.bindings = [NSMutableDictionary new];
        self.topic = topic;
    }
    return self;
}
-(void)join{
    NSMutableDictionary *packet = [NSMutableDictionary packetDictWithEvent:PHOENIX_JOIN topic:self.topic payload:self.payload ref:[@([self.socket makeRef]) stringValue]];
    [self.socket sendData:[packet jsonString]];
}
-(void)leave{
    NSMutableDictionary *packet = [NSMutableDictionary packetDictWithEvent:@"leave" topic:self.topic payload:@{@"subject":@"status", @"body":@"goodbye"} ref:[self.socket refString]];
    [self.socket sendData:[packet jsonString]];    
}
-(void)sendMessage:(NSString *)message{
    NSMutableDictionary *packet = [NSMutableDictionary packetDictWithEvent:@"new:msg" topic:self.topic payload:@{@"message":message, @"ref":self.socket.refString} ref:[self.socket refString]];
    [self.socket sendData:[packet jsonString]];
}
-(BOOL)isMember:(NSString *)topic{
    return [self.topic isEqualToString:topic];
}
-(void)trigger:(NSString * __nonnull)event payload:(NSDictionary*__nonnull)payload{
    if(self.bindings){
        [self.bindings enumerateKeysAndObjectsUsingBlock:^(NSString *onEvent, ChannelMessageCallback callback, BOOL *stop) {
            if([event isEqualToString:onEvent]){
                callback(payload);
                *stop=YES;
            }
        }];
    }
}
-(void)on:(NSString *)event callback:(ChannelMessageCallback)callback{
    
    if([event isEqualToString:PHOENIX_REPLY]){
        return;
    }
    
    if(callback && event){
        [self.bindings setValue:callback forKey:event];
    }
    
}

-(void)onJoined:(ChannelJoinedCallback)joinedCallback{
    
    __block ChannelJoinedCallback cb = joinedCallback;
    ChannelMessageCallback callback = ^(NSDictionary * __nonnull payload) {
        if(payload){
            NSDictionary *body = [payload packetPayload];
            if(body){
                NSString *status = [body packetStatus];
                if([status isEqualToString:@"ok"]){
                    cb(YES, status);
                }else{
                    cb(NO, status);
                }
            }
        }
    };
    [self.bindings setValue:callback forKey:PHOENIX_REPLY];
    
}

@end
