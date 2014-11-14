//
//  ChatStore.h
//  MJFlux
//
//  Created by Michael Lyons on 11/11/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "MJStore.h"
#import "ChatDispatcher.h"

@interface ChatStore : MJStore

+ (ChatStore *)store;

+ (NSUInteger)newMessageCount;

+ (NSMutableArray *)messages;

+ (NSDictionary *)newMessage:(NSString *)text;

@end
