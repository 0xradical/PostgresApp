//
//  DBWindowController.m
//  PostgresApp
//
//  Created by thiago on 12/23/14.
//  Copyright (c) 2014 thiagobrandam. All rights reserved.
//

#import "DBWindowController.h"
#import "PGConnection.h"
#import "PGResult.h"

@interface DBWindowController ()
{
    PGConnection *_connection;
    PGResult *_result;
}

@property (strong) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *queryResults;

@property (weak) IBOutlet NSButton *runQuery;

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

#pragma mark -
#pragma mark IBActions

- (IBAction)runQuery:(id)sender
{
    NSLog(@"Running query");
    _result = [_connection execute:@"SELECT count(*) FROM users;"];
    [_queryResults reloadData];
}

#pragma mark -
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    
    return [_result rowsCount];
}

#pragma mark NSTableViewDelegate

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{

    if ([[aTableColumn identifier] isEqualTo:@"tc1"]) {
        return [_result valueForRow:rowIndex AndColumn:0];
    }
    else {
        return @"Nothing";
    }        
}

@end
