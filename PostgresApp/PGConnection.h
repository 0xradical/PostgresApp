//
//  PGConnection.h
//  PostgresApp
//
//  Created by thiago on 12/22/14.
//  Copyright (c) 2014 thiagobrandam. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PGConnectionDelegate;
@class PGResult;

@interface PGConnection : NSObject

@property (nonatomic) NSString* user;
@property (nonatomic) NSString* password;
@property (nonatomic) NSString* database;
@property (nonatomic) NSString* host;
@property (nonatomic) NSString* hostAddress;
@property (nonatomic) NSString* port;

- (instancetype)initWithDelegate:(id<PGConnectionDelegate>)delegate;
- (BOOL)isConnected;
- (BOOL)connect;
- (PGResult *)execute:(NSString *)query;

@end
