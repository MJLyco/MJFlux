//
//  ThreadStore.h
//  MJFlux
//
//  Created by Michael Lyons on 11/11/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "MJStore.h"

@interface ThreadStore : MJStore

+ (ThreadStore *)store;

+ (NSDictionary *)threads;

+ (NSArray *)threadsChrono;

+ (NSString *)currentThreadID;

@end
