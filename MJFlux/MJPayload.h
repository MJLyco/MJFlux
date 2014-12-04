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
 *  The type of payload we're saying. 
 *  I recommend using various enums
 */
@property (nonatomic, assign) NSUInteger type;

/**
 *  The information contained in the payload
 */
@property (nonatomic, strong) NSDictionary *info;

@end
