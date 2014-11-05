//
//  Stop.h
//  GetOnThatBus
//
//  Created by Andrew Liu on 11/4/14.
//  Copyright (c) 2014 Andrew Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusStop : NSObject

@property (readonly) NSNumber *latitude;
@property (readonly) NSNumber *longitude;
@property (readonly) NSString *name;
@property (readonly) NSString *route;
@property (readonly) NSString *intermodal;
@property (readonly) NSString *address;

- (instancetype) initWithDictionary:(NSDictionary *)busStopDictionary;

@end