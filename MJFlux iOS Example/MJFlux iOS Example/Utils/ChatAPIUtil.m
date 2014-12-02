//
//  ChatAPIUtil.m
//  MJFlux iOS Example
//
//  Created by Michael Lyons on 11/14/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "ChatAPIUtil.h"
#import "ChatDispatcher.h"

static BOOL isRefreshing = NO;

@implementation ChatAPIUtil

+ (BOOL)isRefreshing
{
    return isRefreshing;
}

+ (void)simulateRealTime
{
    NSInteger seconds = arc4random() % 8;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSMutableArray *messages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"messages"] mutableCopy];
        if (messages == nil)
        {
            messages = [NSMutableArray array];
        }
        NSDictionary *message = @{@"identifier": [NSUUID UUID].UUIDString,
                                  @"threadID": @"ABCDE",
                                  @"authorName": @"John",
                                  @"text": [[NSUUID UUID].UUIDString substringToIndex:3],
                                  @"date": [NSDate date],
                                  @"isRead": @(NO)};
        [messages addObject:message];

        [[NSUserDefaults standardUserDefaults] setObject:messages forKey:@"messages"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        isRefreshing = NO;

        MJPayload *payload = [[MJPayload alloc] init];
        payload.type = ChatPayloadTypeReceieveMessages;
        payload.info = @{@"rawMessages": @[message]};
        [[ChatDispatcher dispatcher] dispatch:payload];

        [ChatAPIUtil simulateRealTime];
    });
}

+ (void)getAllMessages
{
    if (isRefreshing)
    {
        return;
    }

    isRefreshing = YES;
    // simulate API
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSMutableArray *messages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"messages"] mutableCopy];
        if (messages == nil)
        {
            messages = [NSMutableArray array];
        }
        [messages addObject:@{@"identifier": [NSUUID UUID].UUIDString,
                              @"threadID": @"ABCDE",
                              @"authorName": @"John",
                              @"text": [[NSUUID UUID].UUIDString substringToIndex:3],
                              @"date": [NSDate date],
                              @"isRead": @(NO)}];

        [[NSUserDefaults standardUserDefaults] setObject:messages forKey:@"messages"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        isRefreshing = NO;

        MJPayload *payload = [[MJPayload alloc] init];
        payload.type = ChatPayloadTypeReceieveMessages;
        payload.info = @{@"rawMessages": messages};
        [[ChatDispatcher dispatcher] dispatch:payload];

    });
}

+ (void)sendMessage:(Message *)message
{
    // simulate API
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSMutableArray *messages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"messages"] mutableCopy];
        if (messages == nil)
        {
            messages = [NSMutableArray array];
        }
        [messages addObject:@{@"identifier": message.identifier,
                              @"threadID": message.threadID,
                              @"authorName": message.authorName,
                              @"text": message.text,
                              @"date": message.date,
                              @"isRead": @(message.isRead)}];

        [[NSUserDefaults standardUserDefaults] setObject:messages forKey:@"messages"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    });
}


@end
