//
//  Stop.h
//  GetOnThatBus
//
//  Created by Andrew Liu on 11/4/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusStop : NSObject
@property NSNumber *latitude;
@property NSNumber *longitude;
@property NSString *name;
@property NSString *route;
@property NSString *intermodal;
@property NSString *address;

- (instancetype) initWithDictionary:(NSDictionary *)busStopDictionary;

@end