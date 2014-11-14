//
//  ChatStore.m
//  MJFlux
//
//  Created by Michael Lyons on 11/11/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "ChatStore.h"
@import AudioToolbox;

@interface ChatStore ()

@property (nonatomic, assign) BOOL gettingMessages;
@property (nonatomic, strong) NSMutableArray *messages;

@end

@implementation ChatStore

+ (void)initialize
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"messages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [ChatStore store];
}

+ (ChatStore *)store
{
    static ChatStore *_singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        _singleton = [[ChatStore alloc] init];
    });
    return _singleton;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.messages = [NSMutableArray array];

        self.dispatchToken = [[ChatDispatcher dispatcher] registerCallback:^(MJPayload *payload) {

            switch ((ChatPayloadType)payload.type)
            {
                case ChatPayloadTypeReceieveMessages:
                    [ChatStore receivedMessages:payload.info[@"messages"]];
                    break;

                case ChatPayloadTypeGetChats:
                    [ChatStore getMessages];
                    break;

                case ChatPayloadTypeNewMessage:
                    [ChatStore sendMessage:payload.info];
                    break;

                case ChatPayloadTypeDeleteMessage:
                    [ChatStore deleteMessage:payload.info];
                    break;

                case ChatPayloadTypeClickThread:
                    [ChatStore sawMessages];
                    break;
            }

        }];
    }
    return self;
}

+ (void)receivedMessages:(NSArray *)messages
{
    [ChatStore store].messages = [NSMutableArray arrayWithArray:messages];
    [[ChatStore store].messages sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES]]];
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@%lu", NSStringFromClass([ChatStore class]), (unsigned long)ChatPayloadTypeReceieveMessages] object:nil];
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (void)sawMessages
{
    // simulate API
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSMutableArray *oldMessages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"messages"] mutableCopy];
        NSMutableArray *messages = [NSMutableArray arrayWithCapacity:oldMessages.count];
        if (messages == nil)
        {
            messages = [NSMutableArray array];
        }
        for (NSDictionary *message in oldMessages)
        {
            if (![message[@"seen"] boolValue])
            {
                NSMutableDictionary *temp = [message mutableCopy];
                [temp setObject:@(YES) forKey:@"seen"];
                [messages addObject:temp];
            }
            else
            {
                [messages addObject:message];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:messages forKey:@"messages"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        MJPayload *payload = [[MJPayload alloc] init];
        payload.type = ChatPayloadTypeReceieveMessages;
        payload.info = @{@"messages": messages};
        [[ChatDispatcher dispatcher] dispatch:payload];
    });
}

+ (void)deleteMessage:(NSDictionary *)message
{
    // simulate API
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSMutableArray *messages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"messages"] mutableCopy];
        if (messages == nil)
        {
            messages = [NSMutableArray array];
        }
        [messages removeObject:message];
        [[NSUserDefaults standardUserDefaults] setObject:messages forKey:@"messages"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        if ([ChatStore store].gettingMessages)
        {
            NSLog(@"Already getting messages");
        }
        else
        {
            MJPayload *payload = [[MJPayload alloc] init];
            payload.type = ChatPayloadTypeReceieveMessages;
            payload.info = @{@"messages": messages};
            [[ChatDispatcher dispatcher] dispatch:payload];
        }
    });
}

+ (void)sendMessage:(NSDictionary *)message
{
    // simulate API
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSMutableArray *messages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"messages"] mutableCopy];
        if (messages == nil)
        {
            messages = [NSMutableArray array];
        }
        [messages addObject:message];
        [[NSUserDefaults standardUserDefaults] setObject:messages forKey:@"messages"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        if ([ChatStore store].gettingMessages)
        {
            NSLog(@"Already getting messages");
        }
        else
        {
            MJPayload *payload = [[MJPayload alloc] init];
            payload.type = ChatPayloadTypeReceieveMessages;
            payload.info = @{@"messages": messages};
            [[ChatDispatcher dispatcher] dispatch:payload];

            [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@%lu", NSStringFromClass([ChatStore class]), (unsigned long)ChatPayloadTypeNewMessage] object:nil];
        }
    });
}

+ (void)getMessages
{
    // simulate API
    if ([ChatStore store].gettingMessages)
    {
        NSLog(@"Already getting messages");
    }
    else
    {
        [ChatStore store].gettingMessages = YES;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            NSMutableArray *messages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"messages"] mutableCopy];
            if (messages == nil)
            {
                messages = [NSMutableArray array];
            }
            [messages addObject:[ChatStore newMessage:[[NSUUID UUID].UUIDString substringToIndex:3]]];
            [[NSUserDefaults standardUserDefaults] setObject:messages forKey:@"messages"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [ChatStore store].gettingMessages = NO;

            MJPayload *payload = [[MJPayload alloc] init];
            payload.type = ChatPayloadTypeReceieveMessages;
            payload.info = @{@"messages": messages};
            [[ChatDispatcher dispatcher] dispatch:payload];

            [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@%lu", NSStringFromClass([ChatStore class]), (unsigned long)ChatPayloadTypeGetChats] object:nil];
        });
    }
}

+ (NSMutableArray *)messages
{
    return [ChatStore store].messages;
}

+ (NSUInteger)newMessageCount
{
    return [[[ChatStore store].messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"seen == 0"]] count];
}

+ (NSDictionary *)newMessage:(NSString *)text
{
    return @{@"date": [NSDate date], @"text": text, @"seen": @(NO)};
}

@end
