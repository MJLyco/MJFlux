//
//  ThreadStore.m
//  MJFlux
//
//  Created by Michael Lyons on 11/11/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "ThreadStore.h"
#import "ChatDispatcher.h"
#import "Thread.h"

@interface ThreadStore ()

@property (nonatomic, strong) NSMutableDictionary *threads;
@property (nonatomic, strong) NSString *currentThreadID;

@end

@implementation ThreadStore

+ (void)initialize
{
    [ThreadStore store];
}

+ (ThreadStore *)store
{
    static ThreadStore *_singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        _singleton = [[ThreadStore alloc] init];
    });
    return _singleton;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.threads = [NSMutableDictionary dictionary];

        self.dispatchToken = [[ChatDispatcher dispatcher] registerCallback:^(MJPayload *payload) {

            switch ((ChatPayloadType)payload.type)
            {
                case ChatPayloadTypeTapThread:
                    [[ThreadStore store] setCurrentThreadID:payload.info[@"threadID"]];
                    [[ThreadStore store] setCurrentLastMessageAsRead];
                    [[ThreadStore store] emitChange];
                    break;

                case ChatPayloadTypeLeaveThread:
                    [[ThreadStore store] setCurrentThreadID:nil];
                    [[ThreadStore store] emitChange];
                    break;

                case ChatPayloadTypeReceieveMessages:
                    [[ThreadStore store] addRawMessages:payload.info[@"rawMessages"]];
                    [[ThreadStore store] emitChange];
                    break;

                default:
                    break;
            }

        }];
    }
    return self;
}

- (void)setCurrentLastMessageAsRead
{
    Thread *thread = [[ThreadStore store].threads objectForKey:[ThreadStore currentThreadID]];
    thread.lastMessage.isRead = YES;
}

- (void)addRawMessages:(NSArray *)rawMessages
{
    for (NSDictionary *rawMessage in rawMessages)
    {
        NSDate *date = rawMessage[@"date"];
        NSString *threadID = rawMessage[@"threadID"];
        Thread *thread = [ThreadStore store].threads[threadID];

        if (thread == nil || [thread.lastMessage.date compare:date] == NSOrderedAscending) //?????
        {
            if (thread == nil)
            {
                thread = [[Thread alloc] init];
                thread.identifier = threadID;
                thread.name = rawMessage[@"threadName"];
            }

            Message *message = [Message convertRawMessage:rawMessage];

            thread.lastMessage = message;

            [[ThreadStore store].threads setObject:thread forKey:threadID];
        }
    }
}

+ (NSString *)currentThreadID
{
    return [ThreadStore store].currentThreadID;
}

+ (NSDictionary *)threads
{
    return [ThreadStore store].threads;
}

+ (NSArray *)threadsChrono
{
    return [[ThreadStore store].threads.allValues sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"lastMessage.date" ascending:YES]]];
}

@end
