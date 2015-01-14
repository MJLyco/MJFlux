//
//  MJPayload.m
//  MJFlux
//
//  Created by Michael Lyons on 11/11/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "MJPayload.h"

@implementation MJPayload

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.type = 0;
        self.info = @{};
    }
    return self;
}

+ (instancetype)payloadWithType:(NSUInteger)type andInfo:(NSDictionary *)info
{
    MJPayload *payload = [[MJPayload alloc] init];
    payload.type = type;
    payload.info = info;
    return payload;
}

@end
