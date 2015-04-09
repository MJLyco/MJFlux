//
//  MJStore.m
//  
//
//  Created by Michael Lyons on 11/12/14.
//
//

#import "MJStore.h"

@interface MJStore ()

/**
 *  Contains all of the event listeners
 *  key = memory address of listener
 *  value = MJBlock to call
 */
@property (nonatomic, strong) NSMutableDictionary *listeners;

@end

@implementation MJStore

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.listeners = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)emitChange
{
    [self performSelectorOnMainThread:@selector(envokeBlocks) withObject:nil waitUntilDone:YES];
}

- (void)envokeBlocks
{
    NSArray *blocks = [self.listeners allValues];
    for (MJBlock block in blocks)
    {
        block();
    }
}

- (void)addChangeListener:(id)listener usingBlock:(MJBlock)block
{
    NSString *address = [NSString stringWithFormat:@"%p", listener];
    if (self.listeners[address] == nil)
    {
        self.listeners[address] = [block copy];
    }
}

- (void)removeChangeListener:(id)listener
{
    NSString *address = [NSString stringWithFormat:@"%p", listener];
    [self.listeners removeObjectForKey:address];
}

@end
