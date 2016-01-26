//
//  Socket.m
//  PhoenixChannelsObjc
//
//  Created by Badu on 1/25/16.
//  Copyright (c) 2016 Badu. All rights reserved.
//

#import "Socket.h"
#import "Channel.h"
#import "NSDictionary+Helper.h"

@interface Socket()
@property(nonatomic)unsigned long long messageRef;
-(void)initWs;

@property(nonatomic, strong)NSTimer *heartBeatTimer;
@property(nonatomic, strong)NSTimer *reconnectTimer;

@property(nonatomic)NSInteger heartBeatInterval;
@property(nonatomic)NSInteger reconnectionInterval;
@property(nonatomic, copy)SocketOpenedCallback openCallback;
@property(nonatomic, copy)SocketClosedCallback closeCallback;
@property(nonatomic, copy)SocketMessageCallback messageCallback;
@property(nonatomic, copy)SocketErrorCallback errorCallback;
@end

@implementation Socket

-(instancetype)initWithUrlString:(NSString *)url{
    self = [super init];
    if(self){
        self.endPointUrl = [NSURL URLWithString:url];
        [self commonInit];
    }
    return self;
    
}

-(instancetype)initWithUrl:(NSURL *)url{
    self = [super init];
    if(self){
        self.endPointUrl=url;
        [self commonInit];
    }
    return self;
}
-(void)commonInit{
    self.heartBeatInterval = 30;
    self.channels=[NSMutableDictionary new];
    self.reconnectionInterval=5;
    [self initWs];
}

-(void)close{
    [self disconnect];
}
-(void)connect{
    [self.webSocket open];
}
-(void)disconnect{
    [self.webSocket close];
    self.webSocket=nil;
}

-(void)reconnect{
    NSLog(@"Reconnecting...");
    [self initWs];
    [self connect];
}

-(void)initWs{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.endPointUrl];
    self.webSocket = [[SRWebSocket alloc]initWithURLRequest:request];
    self.webSocket.delegate=self;
}

-(unsigned long long)makeRef{
    unsigned long long newRef = (self.messageRef + 1);
    
    if(self.messageRef == UINT64_MAX){
        self.messageRef = 0;
    }else{
        self.messageRef=newRef;
    }
    return newRef;
}

-(NSString*)refString{
    return [@([self makeRef]) stringValue];
}

-(BOOL)isConnected{
    return self.webSocket && self.webSocket.readyState == SR_OPEN;
}

-(void)doSendBuffer:(NSDictionary*)data{
    
    NSString *json = [data jsonString];
    NSLog(@"Sending: %@",json);
    [self.webSocket send:json];    
}

-(void)send:(NSDictionary *)envelop{
    
    if ([self isConnected]) {
        [self doSendBuffer:envelop];
    } else {
        [self.sendBuffer addObject:envelop];
    }
}
-(void)sendData:(NSString *)data{
    if([self isConnected]){
         NSLog(@"Sending: %@",data);
        [self.webSocket send:data];
    }
}
-(void)removeChannel:(NSString *)topic{
    [self.channels removeObjectForKey:topic];
}

-(Channel*)chan:(NSString *)topic payload:(NSDictionary *)payload {
    
    Channel *chan = [self.channels valueForKey:topic];
    if(!chan){
        chan = [[Channel alloc]initWithTopic:topic payload:payload socket:self];
        [self.channels setValue:chan forKey:topic];
    }
    return chan;
}

-(void)sendHeartBeat{
    NSMutableDictionary *packet = [NSMutableDictionary packetDictWithEvent:@"heartbeat" topic:@"phoenix" payload:@{@"sucject":@"status", @"body":@"heartbeat"} ref:[self refString]];
    [self sendData:[packet jsonString]];
}


-(void)onOpen:(SocketOpenedCallback)callback{
    self.openCallback=callback;
}
-(void)onClose:(SocketClosedCallback)callback{
    self.closeCallback=callback;
}
-(void)onError:(SocketErrorCallback)callback{
    self.errorCallback=callback;
}
-(void)onMessage:(SocketMessageCallback)callback{
    self.messageCallback=callback;
}

#pragma mark SOCKET CALLBACKS
-(void)handleOpened{
    if(self.openCallback){
        self.openCallback();
    }
    if(self.heartBeatTimer){
        [self.heartBeatTimer invalidate];
    }
    if(self.reconnectTimer){
        [self.reconnectTimer invalidate];
    }
    
    //self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:self.heartBeatInterval target:self selector:@selector(sendHeartBeat) userInfo:nil repeats:YES];
    
    NSLog(@"Socket opened");
}

-(void)handleClose:(NSString *)reason code:(NSInteger)code{
    if(self.heartBeatTimer){
        [self.heartBeatTimer invalidate];
    }
    if(self.reconnectTimer){
        [self.reconnectTimer invalidate];
    }
    self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:self.reconnectionInterval target:self selector:@selector(reconnect) userInfo:nil repeats:YES];
    
    NSLog(@"Socket closed: %@ code: %ld",reason, (long)code);
}
-(void)handleMessage:(NSDictionary *)payload{
    NSLog(@"Received: %@",[payload jsonString]);

    NSString *event = [payload packetEvent];
    NSString *topic = [payload packetTopic];
    
    if(self.channels){
        [self.channels enumerateKeysAndObjectsUsingBlock:^(NSString *channelTopic, Channel *channel, BOOL *stop) {
            if([channel isMember:topic]){
                [channel trigger:event payload:payload];
            }
        }];
    }        
}
-(void)handleError:(NSError*)error{
    if(self.heartBeatTimer){
        [self.heartBeatTimer invalidate];
    }
    if(self.reconnectTimer){
        [self.reconnectTimer invalidate];
    }
    self.reconnectTimer = [NSTimer timerWithTimeInterval:self.reconnectionInterval target:self selector:@selector(reconnect) userInfo:nil repeats:YES];
    
    if(self.errorCallback){
        self.errorCallback(error);
    }
}
#pragma mark END


#pragma mark WS DELEGATE
-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    [self handleClose:reason code:code];
    if(self.closeCallback){
        self.closeCallback(reason, code);
    }
}

-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    [self handleError:error];
    
}
-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSLog(@"Received: %@",message);
    
    NSDictionary *envelop=[NSDictionary fromJsonString:message];
    
    [self handleMessage:envelop];
    if(self.messageCallback){
        self.messageCallback(message);
    }
}
-(void)webSocketDidOpen:(SRWebSocket *)webSocket{
    [self handleOpened];
    
}

#pragma mark END
@end
