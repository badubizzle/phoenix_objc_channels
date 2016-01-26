//
//  NSDictionary+Helper.h
//  PhoenixChannelsObjc
//
//  Created by Badu on 1/26/16.
//  Copyright (c) 2016 Badu. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NSDictionary(Helper)
-(id)valueForKeyOrNil:(NSString *)key;
-(NSString*)jsonString;
-(NSString*)packetEvent;
-(NSString*)packetTopic;
-(NSString*)packetRef;
-(NSString*)packetStatus;
-(id)packetPayload;
-(BOOL)isOK;

+(NSDictionary*)fromJsonString:(NSString*)json;

@end

@interface NSMutableDictionary(Helper)
-(void)setPacketEvent:(NSString*)event;
-(void)setPacketRef:(NSString*)ref;
-(void)setPacketTopic:(NSString*)topic;
-(void)setPacketPayload:(id)payload;
+(NSMutableDictionary*)packetDictWithEvent:(NSString*)event topic:(NSString*)topic payload:(id)payload ref:(NSString*)ref;
@end
