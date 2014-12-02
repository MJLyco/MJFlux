//
//  UnreadThreadStore.h
//  MJFlux iOS Example
//
//  Created by Michael Lyons on 12/3/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "MJStore.h"

@interface UnreadThreadStore : MJStore

+ (UnreadThreadStore *)store;

+ (NSUInteger)count;

@end
