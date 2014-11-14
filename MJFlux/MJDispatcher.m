//
//  MJDispatcher.m
//  MJFlux
//
//  Created by Michael Lyons on 11/11/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "MJDispatcher.h"

@interface MJCallback : NSObject

@property (nonatomic, copy) MJCallbackBlock block;
@property (nonatomic, assign) BOOL isPending;
@property (nonatomic, assign) BOOL isHandled;

@end

@implementation MJCallback
@end

@interface MJDispatcher ()

@property (nonatomic, assign) BOOL isDispatching;
@property (nonatomic, strong) NSMutableDictionary *callbacks;
@property (nonatomic, strong) MJPayload *pendingPayload;

@end

@implementation MJDispatcher

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.isDispatching = NO;
        self.callbacks = [NSMutableDictionary dictionary];
        self.pendingPayload = nil;
    }
    return self;
}

- (NSString *)registerCallback:(MJCallbackBlock)callback
{
    MJCallback *callbackObject = [[MJCallback alloc] init];
    callbackObject.block = callback;

    NSString *identifier = [[NSUUID UUID] UUIDString];
    [self.callbacks setObject:callbackObject forKey:identifier];
    return identifier;
}

- (void)unregisterIdentifier:(NSString *)identifier
{
    [self.callbacks removeObjectForKey:identifier];
}

- (void)waitFor:(NSArray *)identifiers
{
    if (self.isDispatching)
    {
        for (NSString *identifier in identifiers)
        {
            MJCallback *callback = self.callbacks[identifier];
            if (callback.isPending)
            {
                if (!callback.isHandled)
                {
                    NSLog(@"Circular dependency detected while waiting for %@", identifier);
                }
                continue;
            }
            if (callback == nil)
            {
                NSLog(@"Callback not found");
            }
            [self invokeCallback:callback];
        }
    }
    else
    {
        NSLog(@"Must be invoked while dispatching");
    }
}

- (void)dispatch:(MJPayload *)payload
{
    if (self.isDispatching)
    {
        NSLog(@"Can not dispatch in the middle of a dispatch");
    }
    else
    {
        [self startDispatching:payload];

        @try
        {
            for (MJCallback *callback in self.callbacks.allValues)
            {
                if (callback.isPending)
                {
                    continue;
                }
                [self invokeCallback:callback];
            }
        }
        @catch (NSException *exception)
        {
            NSLog(@"Dispatch Exception: %@", exception.debugDescription);
        }
        @finally
        {
            [self stopDispatching];
        }
    }
}

- (void)invokeCallback:(MJCallback *)callback
{
    callback.isPending = YES;
    callback.block(self.pendingPayload);
    callback.isHandled = YES;
}

- (void)startDispatching:(MJPayload *)payload
{
    for (MJCallback *callback in self.callbacks.allValues)
    {
        callback.isPending = NO;
        callback.isHandled = NO;
    }
    self.pendingPayload = payload;
    self.isDispatching = YES;
}

- (void)stopDispatching
{
    self.pendingPayload = nil;
    self.isDispatching = NO;
}

@end
