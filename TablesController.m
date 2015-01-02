//
//  TablesController.m
//  PostgresApp
//
//  Created by thiago on 12/31/14.
//  Copyright (c) 2014 thiagobrandam. All rights reserved.
//

#import "TablesController.h"
#import "DBWindowController.h"
#import "Notifications.h"
#import "PGConnection.h"
#import "PGResult.h"

@interface TablesController ()
{
    PGResult *_result;
}
@property (weak) IBOutlet DBWindowController *dbWindowController;
@property (weak) IBOutlet NSTableView *tables;

@end

@implementation TablesController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
}

- (void)awakeFromNib
{
    _result = [[self connection] execute:@"SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name"];
    
    [[self tables] reloadData];
   
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
    return [_result valueForRow:rowIndex AndColumn:0];
}

#pragma mark -
#pragma NSTableView delegate methods

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    
    NSInteger selectedRow = [_tables selectedRow];
    
    if (selectedRow != -1) {
        // Announce that current table changed
        [[NSNotificationCenter defaultCenter] postNotificationName:kTableCellWasSelected object:[_result valueForRow:selectedRow AndColumn:0]];
    }
}

#pragma mark -
#pragma Methods delegated to DBWindowController

- (PGConnection *)connection
{
    return [[self dbWindowController] connection];
}

@end
