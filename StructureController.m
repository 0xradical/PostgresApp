//
//  StructureController.m
//  PostgresApp
//
//  Created by thiago on 1/4/15.
//  Copyright (c) 2015 thiagobrandam. All rights reserved.
//

#import "StructureController.h"
#import "DBWindowController.h"
#import "Notifications.h"
#import "PGConnection.h"
#import "PGResult.h"

@interface StructureController ()
{
    PGResult *_result;
    NSString *_currentTable;
}
@property (weak) IBOutlet DBWindowController *dbWindowController;
@property (weak) IBOutlet NSTableView *structure;

@end

@implementation StructureController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCurrentTableStructure:) name:kTableCellWasSelected object:nil];
}

#pragma mark -
#pragma Notification Center

- (void)loadCurrentTableStructure:(NSNotification *)aNotification
{
    _currentTable = [aNotification object];
    
    NSString *query = [NSString stringWithFormat:@"SELECT column_name, data_type, character_maximum_length, column_default FROM information_schema.columns WHERE table_name = '%@'", _currentTable];
    
    _result = [[self connection] execute:query];
    
    [_structure reloadData];
    
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


#pragma mark -
#pragma Methods delegated to DBWindowController

- (PGConnection *)connection
{
    return [[self dbWindowController] connection];
}

@end
