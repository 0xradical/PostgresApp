//
//  DBWindowController.m
//  PostgresApp
//
//  Created by thiago on 12/23/14.
//  Copyright (c) 2014 thiagobrandam. All rights reserved.
//

#import "DBWindowController.h"
#import "PGConnection.h"

@interface DBWindowController ()
{
    PGConnection *_connection;
}

@property (strong) IBOutlet NSWindow *window;

@end

@implementation DBWindowController

- (instancetype)initWithConnection:(PGConnection *)connection
{
    self = [super initWithWindowNibName:@"DBWindowController"];
    
    if (self) {
        _connection = connection;
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (PGConnection *)connection
{
    return _connection;
}

- (void)setConnection:(PGConnection *)connection
{
    _connection = connection;
}

@end
