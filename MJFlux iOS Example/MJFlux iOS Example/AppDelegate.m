//
//  AppDelegate.m
//  MJFlux iOS Example
//
//  Created by Michael Lyons on 11/12/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatStore.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    MJPayload *payload = [[MJPayload alloc] init];
    payload.type = ChatPayloadTypeGetChats;
    [[ChatDispatcher dispatcher] dispatch:payload];

    [self sendRandomMessage];

    return YES;
}

- (void)sendRandomMessage
{
    NSInteger seconds = arc4random() % 8;

    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        MJPayload *payload = [[MJPayload alloc] init];
        payload.type = ChatPayloadTypeNewMessage;
        payload.info = [ChatStore newMessage:[[NSUUID UUID].UUIDString substringToIndex:3]];
        [[ChatDispatcher dispatcher] dispatch:payload];

        __weak typeof(self)strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [weakSelf sendRandomMessage];
        }
    });
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end