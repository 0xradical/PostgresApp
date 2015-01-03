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
    NSString *_currentTable;
    NSUInteger _offset;
}
@property (weak) IBOutlet DBWindowController *dbWindowController;

@property (weak) IBOutlet NSTableView *content;
@property (weak) IBOutlet NSButton *previous;
@property (weak) IBOutlet NSButton *next;

@end

@implementation ContentController

- (void)viewDidLoad
{
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
     [_previous setEnabled:NO];
    
    _currentTable = [aNotification object];
    _offset = 0;
        
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ OFFSET %@ LIMIT 20", _currentTable, @(_offset)];
    
    [self loadContentByQuery:query];
    
}

#pragma mark -
#pragma Previous and Next mechanisms

- (IBAction)fetchPrevious:(id)sender
{
    _offset = _offset - 20;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ OFFSET %@ LIMIT 20", _currentTable, @(_offset)];
    
    [self loadContentByQuery:query];
    
    if (![_next isEnabled]) {
        [_next setEnabled:YES];
    }
    
    if (_offset == 0) {
        [_previous setEnabled:NO];
    }
}

- (IBAction)fetchNext:(id)sender
{
    _offset = _offset + 20;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ OFFSET %@ LIMIT 20", _currentTable, @(_offset)];
    
    [self loadContentByQuery:query];
    
    if ([_result rowsCount] < 20) {
        [_next setEnabled:NO];
    }
    
    if (![_previous isEnabled]) {
        [_previous setEnabled:YES];
    }
    
}


#pragma mark -
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_result rowsCount];
}

#pragma mark NSTableViewDelegate

// Getter
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return [_result valueForRow:rowIndex AndColumn:[[aTableColumn identifier] intValue]];
}

// Setter
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)row
{
    NSUInteger fieldIndex = [[aTableColumn identifier] intValue];
    
    NSString *query = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE id = %@", _currentTable,[_result fieldForColumn:fieldIndex], object, [_result valueForRow:row AndColumn:0]];
    
    [[self connection] execute:query];
}

#pragma mark -
#pragma Methods delegated to DBWindowController

- (PGConnection *)connection
{
    return [[self dbWindowController] connection];
}

#pragma mark -
#pragma Auxiliary methods

- (void)loadContentByQuery:(NSString *)query
{
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
        [column setEditable:YES];
        [[column headerCell] setStringValue:[_result fieldForColumn:i]];
        [_content addTableColumn:column];
    }
    
    [[_content headerView] setNeedsDisplay:YES];
    [_content reloadData];
}

@end
