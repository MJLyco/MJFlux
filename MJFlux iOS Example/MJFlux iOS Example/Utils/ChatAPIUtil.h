//
//  ChatAPIUtil.h
//  MJFlux iOS Example
//
//  Created by Michael Lyons on 11/14/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "Message.h"

@interface ChatAPIUtil : NSObject

+ (BOOL)isRefreshing;

+ (void)simulateRealTime;

+ (void)getAllMessages;

+ (void)sendMessage:(Message *)message;

@end
