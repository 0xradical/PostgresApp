//
//  PGConnection.m
//  PostgresApp
//
//  Created by thiago on 12/22/14.
//  Copyright (c) 2014 thiagobrandam. All rights reserved.
//

#import "PGConnection.h"
#import "PGConnectionDelegate.h"
#import "PGResult.h"
#import "libpq-fe.h"
#import <poll.h>

@interface PGConnection ()
{
    PGconn *_connection;
    NSString *_connectionParameters;
    id<PGConnectionDelegate> _delegate;
}
@end

@implementation PGConnection


- (instancetype)initWithDelegate:(id<PGConnectionDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        _delegate = delegate;
    }
    
    return self;
}

/**
 * Does this connection have an underlying connection established with the server.
 *
 * @return A BOOL indicating the result of the query.
 */
- (BOOL)isConnected
{
    if (!_connection) return NO;
    
    return PQstatus(_connection) == CONNECTION_OK;
}

/**
 * Initiates the underlying connection to the server asynchronously.
 *
 * Note, that if no user, host or database is set when connect is called, then libpq's defaults are used.
 * For no host, this means a socket connection to /tmp is attempted.
 *
 * @return A BOOL indicating the success of requesting the connection. Note, that this does not indicate
 *         that a successful connection has been made, only that it has successfullly been requested.
 */
- (BOOL)connect
{
    if ([self isConnected])
        return YES;
    
    NSLog(@"Connection parameters: %@", [self connectionParameters]);
    
    _connection = PQconnectStart([[self connectionParameters] UTF8String]);
    
    // Perform the connection
    if (!_connection || PQstatus(_connection) == CONNECTION_BAD) {
        
        PQfinish(_connection);
        
        if (_delegate) {
            [_delegate connectionFailed:self];
        }
        return NO;
    }
    else {
        [self performSelectorInBackground:@selector(pollConnection) withObject:nil];
        return YES;
    }
    
}

- (NSString *)lastErrorMessage
{
    if ([self isConnected]) {
        return [[NSString alloc] initWithUTF8String:PQerrorMessage(_connection)];
    } else {
        return @"Could not connect to Postgres";
    }
}

#pragma mark -
#pragma mark Querying

- (PGResult *)execute:(NSString *)query
{
    PGresult *result = PQexec(_connection, [query UTF8String]);
        
    return [[PGResult alloc] initWithResult:result];
}


#pragma mark -
#pragma mark Private API

- (NSString *)connectionParameters
{
    if (_connectionParameters) {
        return _connectionParameters;
    }
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    
    if ([self user]) {
        [params addObject:[NSString stringWithFormat:@"user='%@'", [self user]]];
    }
    
    if ([self password]) {
        [params addObject:[NSString stringWithFormat:@"password='%@'", [self password]]];
    }
    
    if ([self database]) {
        [params addObject:[NSString stringWithFormat:@"dbname='%@'", [self database]]];
    }
    
    if ([self host]) {
        [params addObject:[NSString stringWithFormat:@"host='%@'", [self host]]];
    }
    
    if ([self hostAddress]) {
        [params addObject:[NSString stringWithFormat:@"hostaddr='%@'", [self hostAddress]]];
    }
    
    if ([self port]) {
        [params addObject:[NSString stringWithFormat:@"port='%@'", [self port]]];
    }
    
    _connectionParameters = [params componentsJoinedByString:@" "];
    
    return _connectionParameters;
}

- (void)pollConnection
{
    int sock = PQsocket(_connection);
    
    if (sock == -1) {
        NSLog(@"Polling status: could not obtain socket");
        return;
    }
    
    struct pollfd fdinfo[1];
    
    fdinfo[0].fd = sock;
    fdinfo[0].events = POLLIN|POLLOUT;
    
    PostgresPollingStatusType pollStatus;
    
    do {
        pollStatus = PQconnectPoll(_connection);
        
        if (pollStatus == PGRES_POLLING_READING || pollStatus == PGRES_POLLING_WRITING) {
            if (poll(fdinfo, 1, -1) < 0) {
                break;
            }
        }
    } while (pollStatus != PGRES_POLLING_OK && pollStatus != PGRES_POLLING_FAILED);
    
    if (pollStatus == PGRES_POLLING_OK && [self isConnected]) {
        if (_delegate) {
            [_delegate connectionEstablished:self];
        }
    }
    else {
        NSLog(@"Polling error: %@", [[NSString alloc] initWithUTF8String:PQerrorMessage(_connection)]);
        if (_delegate) {
            [_delegate connectionFailed:self];
        }
    }
    
}

- (void)dealloc
{
    NSLog(@"Deallocing connection");
}

@end
