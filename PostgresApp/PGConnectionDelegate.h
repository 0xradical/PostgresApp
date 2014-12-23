//
//  PGConnectionDelegate.h
//  PostgresApp
//
//  Created by thiago on 12/22/14.
//  Copyright (c) 2014 thiagobrandam. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PGConnection;

@protocol PGConnectionDelegate <NSObject>

/**
 * Called whenever the supplied connection has been successfully established and is ready to use.
 *
 * @param connection The connection instance.
 */
- (void)connectionEstablished:(PGConnection *)connection;

/**
 * Called when failed to established the connection
 
 */
- (void)connectionFailed:(PGConnection *)connection;

@end
