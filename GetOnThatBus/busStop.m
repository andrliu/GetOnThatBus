//
//  Stop.m
//  GetOnThatBus
//
//  Created by Andrew Liu on 11/4/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import "BusStop.h"

@implementation BusStop

- (instancetype) initWithDictionary:(NSDictionary *)busStopDictionary
{
    self = [super init];

    self.latitude = busStopDictionary[@"latitude"];

    self.longitude = busStopDictionary[@"longitude"];

    self.name = busStopDictionary[@"cta_stop_name"];

    self.route = busStopDictionary[@"routes"];

    self.intermodal = busStopDictionary[@"inter_modal"];

    self.address = busStopDictionary[@"_address"];

    return self;
}

@end
