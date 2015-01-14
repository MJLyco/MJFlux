//
//  MessagesStore.m
//  MJFlux iOS Example
//
//  Created by Michael Lyons on 12/2/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "MessagesStore.h"
#import "ChatDispatcher.h"
#import "ThreadStore.h"
#import "Message.h"
#import "Thread.h"
#import "ChatAPIUtil.h"

@interface MessagesStore ()

@property (nonatomic, strong) NSMutableDictionary *messages;
@property (nonatomic, strong) NSString *currentThreadID;

@end

@implementation MessagesStore

+ (void)initialize
{
    [MessagesStore store];
}

+ (instancetype)store
{
    static MessagesStore *_singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        _singleton = [[MessagesStore alloc] init];
    });
    return _singleton;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.messages = [NSMutableDictionary dictionary];

        self.dispatchToken = [[ChatDispatcher dispatcher] registerCallback:^(MJPayload *payload) {

            switch ((ChatPayloadType)payload.type)
            {
                case ChatPayloadTypeTapThread:
                    [[ChatDispatcher dispatcher] waitFor:@[[ThreadStore store].dispatchToken]];
                    [[MessagesStore store] markAllMessagesAsReadWithThreadID:[ThreadStore currentThreadID]];
                    [[MessagesStore store] emitChange];
                    break;

                case ChatPayloadTypeCreateMessage:
                    [[MessagesStore store] createNewMessageWithText:payload.info[@"text"]];
                    [[MessagesStore store] emitChange];
                    break;

                case ChatPayloadTypeReceieveMessages:
                    [[MessagesStore store] addRawMessages:payload.info[@"rawMessages"]];
                    [[ChatDispatcher dispatcher] waitFor:@[[ThreadStore store].dispatchToken]];
                    [[MessagesStore store] markAllMessagesAsReadWithThreadID:[ThreadStore currentThreadID]];
                    [[MessagesStore store] emitChange];
                    break;

                default:
                    break;
            }

        }];
    }
    return self;
}

+ (NSArray *)messagesForThread:(NSString *)threadID
{
    NSArray *tempArray = [[MessagesStore store].messages.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"threadID == %@", threadID]];
    tempArray = [tempArray sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES]]];
    return tempArray;
}

- (void)markAllMessagesAsReadWithThreadID:(NSString *)threadID
{
    NSArray *tempArray = [self.messages.allValues filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"threadID == %@", threadID]];
    tempArray = [tempArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isRead == 0"]];
    for (Message *message in tempArray)
    {
        message.isRead = YES;
    }
}

- (void)createNewMessageWithText:(NSString *)text
{
    Message *message = [[Message alloc] init];
    message.identifier = [NSUUID UUID].UUIDString;
    message.threadID = [ThreadStore currentThreadID];
    message.authorName = @"Jordan"; // current user's name
    message.text = text.copy;
    message.isRead = YES;
    message.date = [NSDate date];
    [self.messages setObject:message forKey:message.identifier.copy];
    [ChatAPIUtil sendMessage:message];
}

- (void)addRawMessages:(NSArray *)rawMessages
{
    for (NSDictionary *rawMessage in rawMessages)
    {
        if ([self.messages objectForKey:rawMessage[@"identifier"]] == nil)
        {
            Message *message = [Message convertRawMessage:rawMessage];
            [self.messages setObject:message forKey:message.identifier.copy];
        }
    }
}

@end
