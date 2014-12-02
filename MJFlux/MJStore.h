//
//  MJStore.h
//  
//
//  Created by Michael Lyons on 11/12/14.
//
//

#import <Foundation/Foundation.h>

typedef void(^MJBlock)(void);

@interface MJStore : NSObject

@property (nonatomic, strong) NSString *dispatchToken;

- (void)emitChange;

- (void)addChangeListener:(id)listener usingBlock:(MJBlock)block;
- (void)removeChangeListener:(id)listener;

@end
