//
//  Message.m
//  MJFlux iOS Example
//
//  Created by Michael Lyons on 12/2/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "Message.h"
#import "ThreadStore.h"

@implementation Message

+ (Message *)convertRawMessage:(NSDictionary *)rawMessage
{
    Message *message = [[Message alloc] init];
    message.identifier = rawMessage[@"identifier"];
    message.threadID = rawMessage[@"threadID"];
    message.authorName =rawMessage[@"authorName"];
    message.text = rawMessage[@"text"];
    message.isRead = ([message.threadID isEqualToString:[ThreadStore currentThreadID]]);
    message.date = rawMessage[@"date"];
    return message;
}

@end
