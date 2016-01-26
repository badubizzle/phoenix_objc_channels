//
//  Socket.h
//  PhoenixChannelsObjc
//
//  Created by Badu on 1/25/16.
//  Copyright (c) 2016 Badu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

@class Channel;

typedef void(^SocketOpenedCallback)();
typedef void(^SocketClosedCallback)(NSString* reason, NSInteger code);
typedef void(^SocketMessageCallback)(id message);
typedef void(^SocketErrorCallback)(NSError *error);

@interface Socket : NSObject<SRWebSocketDelegate>
@property(nonatomic, strong)SRWebSocket *webSocket;
@property(nonatomic, strong)NSURL *endPointUrl;

@property(nonatomic, strong)NSMutableDictionary *channels;

@property(nonatomic, strong)NSMutableArray *sendBuffer;


-(instancetype)initWithUrlString:(NSString*)url;
-(instancetype)initWithUrl:(NSURL *)url;
-(void)close;
-(void)reconnect;
-(Channel*)chan:(NSString*)topic payload:(NSDictionary*)payload;//topic  topic: String
-(void)removeChannel:(NSString*)topic;
-(void)leave:(NSString*)topic  payload:(NSDictionary*)payload;
-(void)send:(NSDictionary*)envelop;
-(void)sendData:(NSString*)data;


-(void)connect;
-(void)disconnect;
-(unsigned long long)makeRef;
-(NSString*)refString;

-(void)onOpen:(SocketOpenedCallback)callback;
-(void)onClose:(SocketClosedCallback)callback;
-(void)onError:(SocketErrorCallback)callback;
-(void)onMessage:(SocketMessageCallback)callback;

@end
