//
//  MessagesStore.h
//  MJFlux iOS Example
//
//  Created by Michael Lyons on 12/2/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "MJStore.h"

@interface MessagesStore : MJStore

+ (instancetype)store;

+ (NSArray *)messagesForThread:(NSString *)thread;

@end
