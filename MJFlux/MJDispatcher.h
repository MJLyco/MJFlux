//
//  MJDispatcher.h
//  MJFlux
//
//  Created by Michael Lyons on 11/11/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "MJPayload.h"

/**
 *  Block used with dispatches
 *
 *  @param payload MJPayload object sent back
 */
typedef void (^MJCallbackBlock)(MJPayload *payload);


/**
 *  A Dispatcher handles the flow of information and blocks
 *  actions from being taken while it is still processing
 */
@interface MJDispatcher : NSObject

/**
*  Registers a callback to be invoked with every dispatched payload. Returns
*  a token that can be used with `waitFor`.
*
*  @param callback Block to run when a payload gets dispatched
*
*  @return The unique ID for this callback
*/
- (NSString *)registerCallback:(MJCallbackBlock)callback;

/**
 *  Removes a callback based on its token
 *
 *  @param identifier the identifier of the callback to remove
 */
- (void)unregisterIdentifier:(NSString *)identifier;

/**
 *  Waits for the callbacks specified to be invoked before continuing execution
 *  of the current callback. This method should only be used by a callback in
 *  response to a dispatched payload.
 *
 *  @param identifiers Array of IDs
 */
- (void)waitFor:(NSArray *)identifiers;

/**
 *  Dispatches a payload to all registered callbacks.
 *
 *  @param Payload for the dispatch
 */
- (void)dispatch:(MJPayload *)payload;

@end
