//
//  MJStore.h
//  
//
//  Created by Michael Lyons on 11/12/14.
//
//

#import <Foundation/Foundation.h>

/**
 *  Change callback type
 */
typedef void(^MJBlock)(void);


/**
 *  MJStores register callbacks from a dispatcher,
 *  process data, hold data, and emit change callbacks
 *  to views
 */
@interface MJStore : NSObject

/**
 *  Unique dispatch token from the dispatcher
 */
@property (nonatomic, strong) NSString *dispatchToken;

/**
 *  Tell registered listeners about a change
 */
- (void)emitChange;

/**
 *  Add a listener for Store changes
 *
 *  @param listener The object doing the listening
 *  @param block    The callback triggered when a change is emitted
 */
- (void)addChangeListener:(id)listener usingBlock:(MJBlock)block;

/**
 *  Remove a listener for Store changes
 *
 *  @param listener The object that was doing the listening
 */
- (void)removeChangeListener:(id)listener;

@end
