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
@property (weak) IBOutlet NSButton *queryButton;
@property (unsafe_unretained) IBOutlet NSTextView *customQuery;
@property (weak) IBOutlet NSTextField *errorText;

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
    _result = [_connection execute:[_customQuery string]];
    
    if (_result && ([_result status] == PGRES_COMMAND_OK || [_result status] == PGRES_TUPLES_OK)) {
        NSLog(@"Adds/Removes columns");
        NSArray *columns = [[_queryResults tableColumns] copy];
        
        for( int i=0; i < [columns count]; i++)
        {
            NSTableColumn *col = [columns objectAtIndex:i];
            NSLog(@"removing column: %@", [col identifier]);
            [_queryResults removeTableColumn:col];
        }
        
        for( int i=0; i < [_result fieldsCount]; i++)
        {
            NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%i", i]];
            [column setEditable:NO];
            [[column headerCell] setStringValue:[_result fieldForColumn:i]];
            [_queryResults addTableColumn:column];
        }
        
        [[_queryResults headerView] setNeedsDisplay:YES];
        
        NSLog(@"Reloading data");
        [_queryResults reloadData];

    }
    else {
        [_errorText setStringValue:[_connection lastErrorMessage]];
        
    }
    
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
    return [_result valueForRow:rowIndex AndColumn:[[aTableColumn identifier] intValue]];
}

@end
