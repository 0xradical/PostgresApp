//
//  DatabasesController.m
//  PostgresApp
//
//  Created by thiago on 1/17/15.
//  Copyright (c) 2015 thiagobrandam. All rights reserved.
//

#import "DatabasesController.h"
#import "DBWindowController.h"
#import "Notifications.h"
#import "PGConnection.h"

@interface DatabasesController ()
{
    NSString *_currentDatabase;
}
@property (weak) IBOutlet DBWindowController *dbWindowController;
@property (weak) IBOutlet NSPopUpButton *availableDatabases;

@end

@implementation DatabasesController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)awakeFromNib
{
    _currentDatabase = [[self connection] currentDatabase];
    
    [[self availableDatabases] addItemsWithTitles:[[self connection] availableDatabases]];
    
    [[self availableDatabases] selectItemWithTitle:_currentDatabase];
}


- (IBAction)changed:(id)sender
{
    NSString *selectedDatabase = [[self.availableDatabases selectedItem]  title];
    
    if (selectedDatabase != _currentDatabase) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDatabaseWasChanged object:selectedDatabase];
    }
}

#pragma mark -
#pragma Methods delegated to DBWindowController

- (PGConnection *)connection
{
    return [[self dbWindowController] connection];
}

@end
