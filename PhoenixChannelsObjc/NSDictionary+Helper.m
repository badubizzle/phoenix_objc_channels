//
//  NSDictionary+Helper.m
//  PhoenixChannelsObjc
//
//  Created by Badu on 1/26/16.
//  Copyright (c) 2016 Badu. All rights reserved.
//

#import "NSDictionary+Helper.h"

@implementation NSDictionary(Helper)


-(id)valueForKey:(NSString *)key withDefault:(id)defaultValue{
    
    id obj = [self valueForKey:key];
    if(!obj || obj==nil || [obj isKindOfClass:[NSNull class]] ){
        return defaultValue;
    }
    return obj;
}
-(id)valueForKeyOrNil:(NSString *)key {
    
    return  [self valueForKey:key withDefault:nil];
}

-(NSString*) jsonString {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)     0
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+(NSDictionary *)fromJsonString:(NSString *)json{
    NSError *e =nil;
    NSDictionary *json_data= [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:[json UTF8String] length:json.length] options: NSJSONReadingMutableContainers error: &e];
    return json_data;
}

-(NSString *)packetRef{
    return [self valueForKeyOrNil:@"ref"];
}
-(NSString* )packetStatus{
    return [self valueForKeyOrNil:@"status"];
}

-(BOOL)isOK{
    NSString *status = [self packetStatus];
    return status!=nil && [status isEqualToString:@"ok"];
}

-(NSString *)packetEvent{
    return [self valueForKeyOrNil:@"event"];
}
-(NSString *)packetTopic{
    return [self valueForKeyOrNil:@"topic"];
}

-(id)packetPayload{
    return [self valueForKeyOrNil:@"payload"];
}

@end

@implementation NSMutableDictionary(Helper)

-(void)setPacketEvent:(NSString *)event{
    [self setValue:event forKey:@"event"];
}
-(void)setPacketTopic:(NSString *)topic{
    [self setValue:topic forKey:@"topic"];
}
-(void)setPacketPayload:(id)payload{
    [self setValue:payload forKey:@"payload"];
}
-(void)setPacketRef:(NSString *)ref{
    [self setValue:ref forKey:@"ref"];
}
+(NSMutableDictionary *)packetDictWithEvent:(NSString *)event topic:(NSString *)topic payload:(id)payload ref:(NSString*)ref{
    NSMutableDictionary *packet = [NSMutableDictionary new];
    if(payload){
        [packet setPacketPayload:payload];
    }

    [packet setPacketEvent:event];
    [packet setPacketTopic:topic];
    if(ref){
        [packet setPacketRef:ref];
    }
    return packet;
}

@end
