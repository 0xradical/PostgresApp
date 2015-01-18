//
//  TablesController.m
//  PostgresApp
//
//  Created by thiago on 12/31/14.
//  Copyright (c) 2014 thiagobrandam. All rights reserved.
//

#import "TablesController.h"
#import "Notifications.h"
#import "PGConnection.h"
#import "PGResult.h"

@interface TablesController ()
{
    PGResult *_result;
}
@property (weak) IBOutlet NSTableView *tables;

@end

@implementation TablesController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTables:) name:kConnectionWasChanged object:nil];
   
}

#pragma mark -
#pragma mark Notification Center - Connection changed
- (void)reloadTables:(NSNotification *)aNotification
{
    PGConnection* connection = [aNotification object];
    
    _result = [connection execute:@"SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name"];
    
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

// http://stackoverflow.com/questions/25468456/getting-selected-value-from-nstableview#answer-25468898
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    
    NSInteger selectedRow = [_tables selectedRow];
    
    if (selectedRow != -1) {
        // Announce that current table changed
        [[NSNotificationCenter defaultCenter] postNotificationName:kTableCellWasSelected object:[_result valueForRow:selectedRow AndColumn:0]];
    }
}

@end
