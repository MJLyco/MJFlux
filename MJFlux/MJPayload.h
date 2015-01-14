//
//  MJPayload.h
//  MJFlux
//
//  Created by Michael Lyons on 11/11/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  An MJPayload is information you send 
 *  to the dispatcher caused by some action
 */
@interface MJPayload : NSObject

/**
 *  Create a new MJPayload object with the given parameters
 *
 *  @param type What type of payload it is
 *  @param info The information contained in the payload
 *
 *  @return a new MJPayload instance
 */
+ (instancetype)payloadWithType:(NSUInteger)type andInfo:(NSDictionary *)info;

/**
 *  The type of payload we're sending.
 *  I recommend using various enums
 */
@property (nonatomic, assign) NSUInteger type;

/**
 *  The information contained in the payload
 */
@property (nonatomic, strong) NSDictionary *info;

@end
