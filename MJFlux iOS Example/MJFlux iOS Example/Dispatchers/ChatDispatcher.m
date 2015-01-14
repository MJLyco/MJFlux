//
//  ChatDispatcher.m
//  MJFlux
//
//  Created by Michael Lyons on 11/11/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "ChatDispatcher.h"

@implementation ChatDispatcher

+ (instancetype)dispatcher
{
    static ChatDispatcher *_singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        _singleton = [[ChatDispatcher alloc] init];
    });
    return _singleton;
}

@end
