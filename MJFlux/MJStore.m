//
//  MJStore.m
//  
//
//  Created by Michael Lyons on 11/12/14.
//
//

#import "MJStore.h"

@interface MJStore ()

@property (nonatomic, strong) NSMutableArray *listeners;

@end

@implementation MJStore

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.listeners = [NSMutableArray array];
    }
    return self;
}

- (void)emitChange
{
    [self performSelectorOnMainThread:@selector(envokeBlocks) withObject:nil waitUntilDone:YES];
}

- (void)envokeBlocks
{
    NSArray *blocks = [self.listeners valueForKey:@"block"];
    for (MJBlock block in blocks)
    {
        block();
    }
}

- (void)addChangeListener:(id)listener usingBlock:(MJBlock)block
{
    NSString *address = [NSString stringWithFormat:@"%p", listener];
    if (![[self.listeners valueForKey:@"listener"] containsObject:address])
    {
        [self.listeners addObject:@{@"listener": address,
                                    @"block": block}];
    }
}

- (void)removeChangeListener:(id)listener
{
    NSString *address = [NSString stringWithFormat:@"%p", listener];
    NSUInteger index = [[self.listeners valueForKey:@"listener"] indexOfObject:address];
    if (index != NSNotFound)
    {
        [self.listeners removeObjectAtIndex:index];
    }
}

@end
