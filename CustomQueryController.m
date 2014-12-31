//
//  CustomQueryController.m
//  PostgresApp
//
//  Created by thiago on 12/31/14.
//  Copyright (c) 2014 thiagobrandam. All rights reserved.
//

#import "CustomQueryController.h"
#import "DBWindowController.h"
#import "PGResult.h"
#import "PGConnection.h"
#import "NoodleLineNumberView.h"

@interface CustomQueryController ()
{
    PGResult *_result;
    NoodleLineNumberView *_lineNumberView;
}
@property (weak) IBOutlet DBWindowController *dbWindowController;

@property (unsafe_unretained) IBOutlet NSTextView *customQuery;
@property (unsafe_unretained) IBOutlet NSTextView *queryMessage;
@property (weak) IBOutlet NSTableView *queryResults;

@end

@implementation CustomQueryController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
}

- (void)awakeFromNib
{
    self.customQuery.font = [NSFont userFixedPitchFontOfSize:14.0f];
    
    _lineNumberView = [[NoodleLineNumberView alloc] initWithScrollView:[self.customQuery enclosingScrollView]];
    
    [[self.customQuery enclosingScrollView] setVerticalRulerView:_lineNumberView];
    [[self.customQuery enclosingScrollView] setHasHorizontalRuler:NO];
    [[self.customQuery enclosingScrollView] setHasVerticalRuler:YES];
    [[self.customQuery enclosingScrollView] setRulersVisible:YES];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)runQuery:(id)sender
{
    [_queryMessage setString:@"Running query ..."];
    _result = [[self connection] execute:[_customQuery string]];
    
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
        
        [_queryResults reloadData];
        [_queryMessage setString:@"Query OK"];
        
    }
    else {
        [_queryMessage setString:[[self connection] lastErrorMessage]];
        
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

#pragma mark -
#pragma Methods delegated to DBWindowController

- (PGConnection *)connection
{
    return [[self dbWindowController] connection];
}

@end
