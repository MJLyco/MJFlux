//
//  ChatDispatcher.h
//  MJFlux
//
//  Created by Michael Lyons on 11/11/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "MJDispatcher.h"

typedef NS_ENUM(NSUInteger, ChatPayloadType) {
    ChatPayloadTypeTapThread = 1,
    ChatPayloadTypeLeaveThread,
    ChatPayloadTypeCreateMessage,
    ChatPayloadTypeReceieveMessages,
    ChatPayloadTypeDeleteMessage,
    ChatPayloadTypeGetChats
};

@interface ChatDispatcher : MJDispatcher

+ (ChatDispatcher *)dispatcher;

@end
