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

    _latitude = busStopDictionary[@"latitude"];

    _longitude = busStopDictionary[@"longitude"];

    _name = busStopDictionary[@"cta_stop_name"];

    _route = busStopDictionary[@"routes"];

    _intermodal = busStopDictionary[@"inter_modal"];

    _address = busStopDictionary[@"_address"];

    return self;
}

@end
