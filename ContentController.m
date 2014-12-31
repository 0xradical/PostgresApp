//
//  ContentController.m
//  PostgresApp
//
//  Created by thiago on 12/31/14.
//  Copyright (c) 2014 thiagobrandam. All rights reserved.
//

#import "ContentController.h"
#import "DBWindowController.h"
#import "Notifications.h"
#import "PGConnection.h"
#import "PGResult.h"

@interface ContentController ()
{
    PGResult *_result;
}
@property (weak) IBOutlet DBWindowController *dbWindowController;

@property (weak) IBOutlet NSTableView *content;

@end

@implementation ContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCurrentTableData:) name:kTableCellWasSelected object:nil];
}

#pragma mark -
#pragma Notification Center

- (void)loadCurrentTableData:(NSNotification *)aNotification
{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ LIMIT 20", [aNotification object]];
    
    _result = [[self connection] execute:query];
    
    NSArray *columns = [[_content tableColumns] copy];
    
    for( int i=0; i < [columns count]; i++)
    {
        NSTableColumn *col = [columns objectAtIndex:i];
        [_content removeTableColumn:col];
    }
    
    for( int i=0; i < [_result fieldsCount]; i++)
    {
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%i", i]];
        [column setEditable:NO];
        [[column headerCell] setStringValue:[_result fieldForColumn:i]];
        [_content addTableColumn:column];
    }
    
    [[_content headerView] setNeedsDisplay:YES];
    [_content reloadData];
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

#pragma mark -
#pragma Methods delegated to DBWindowController

- (PGConnection *)connection
{
    return [[self dbWindowController] connection];
}

@end
