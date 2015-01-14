//
//  ChatDispatcher.m
//  MJFlux
//
//  Created by Michael Lyons on 11/11/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "ChatDispatcher.h"

@implementation ChatDispatcher

+ (ChatDispatcher *)dispatcher
{
    static MJDispatcher *_singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        _singleton = [[MJDispatcher alloc] init];
    });
    return _singleton;
}

@end
