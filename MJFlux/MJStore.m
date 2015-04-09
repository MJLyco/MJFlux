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
 *  key = UUID
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

- (NSString *)addChangeListener:(id)listener usingBlock:(MJBlock)block
{
    NSString *address = [[NSUUID UUID] UUIDString];
    self.listeners[address] = [block copy];
    return address;
}

- (void)removeChangeListener:(NSString *)listenerID
{
    [self.listeners removeObjectForKey:listenerID];
}

@end
