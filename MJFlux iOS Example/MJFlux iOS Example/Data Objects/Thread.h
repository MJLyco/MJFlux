//
//  Thread.h
//  MJFlux iOS Example
//
//  Created by Michael Lyons on 12/2/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import "Message.h"

@interface Thread : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) Message *lastMessage;

@end
