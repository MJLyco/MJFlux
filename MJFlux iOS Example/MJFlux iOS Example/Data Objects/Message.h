//
//  Message.h
//  MJFlux iOS Example
//
//  Created by Michael Lyons on 12/2/14.
//  Copyright (c) 2014 MJ Lyco LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *threadID;
@property (nonatomic, strong) NSString *authorName;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) BOOL isRead;

+ (Message *)convertRawMessage:(NSDictionary *)rawMessage;

@end
