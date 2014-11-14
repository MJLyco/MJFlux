//
//  MJPayload.h
//  MJFlux
//
//  Created by Michael Lyons on 11/11/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJPayload : NSObject

@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, strong) NSDictionary *info;

@end
