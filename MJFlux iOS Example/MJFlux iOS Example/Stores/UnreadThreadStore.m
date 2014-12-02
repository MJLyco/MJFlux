//
//  UnreadThreadStore.m
//  MJFlux iOS Example
//
//  Created by Michael Lyons on 12/3/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "UnreadThreadStore.h"
#import "ChatDispatcher.h"
#import "ThreadStore.h"
#import "MessagesStore.h"

@implementation UnreadThreadStore

+ (void)initialize
{
    [UnreadThreadStore store];
}

+ (UnreadThreadStore *)store
{
    static UnreadThreadStore *_singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        _singleton = [[UnreadThreadStore alloc] init];
    });
    return _singleton;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.dispatchToken = [[ChatDispatcher dispatcher] registerCallback:^(MJPayload *payload) {

            [[ChatDispatcher dispatcher] waitFor:@[[ThreadStore store].dispatchToken,
                                                   [MessagesStore store].dispatchToken]];

            switch ((ChatPayloadType)payload.type)
            {
                case ChatPayloadTypeTapThread:
                    [[UnreadThreadStore store] emitChange];
                    break;

                case ChatPayloadTypeReceieveMessages:
                    [[UnreadThreadStore store] emitChange];
                    break;

                default:
                    break;
            }
            
        }];
    }
    return self;
}

+ (NSUInteger)count
{
    NSArray *array = [[ThreadStore threads].allValues filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastMessage.isRead == 0"]];
    return array.count;
}

@end
