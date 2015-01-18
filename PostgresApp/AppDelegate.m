//
//  AppDelegate.m
//  PostgresApp
//
//  Created by thiago on 12/22/14.
//  Copyright (c) 2014 thiagobrandam. All rights reserved.
//

#import "AppDelegate.h"
#import "PGConnection.h"
#import "DBWindowController.h"
#import "Notifications.h"

@interface AppDelegate ()
{
    DBWindowController *_dbWindowController;
}

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *connectionMessage;
@property (weak) IBOutlet NSTextField *user;
@property (weak) IBOutlet NSSecureTextField *password;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Application finished launching");
    
    // Notification received from DatabasesController
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDatabase:) name:kDatabaseWasChanged object:nil];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

#pragma mark -
#pragma mark Notification Center - Database changed
- (void)loadDatabase:(NSNotification *)aNotification
{
    NSString* selectedDatabase = [aNotification object];
    
    PGConnection *connection = [[PGConnection alloc] initWithDelegate:self];
    
    [connection setUser:[[self user] stringValue]];
    [connection setPassword:[[self password] stringValue]];
    [connection setDatabase:selectedDatabase];
    
    [connection connect];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)connect:(id)sender
{
    PGConnection *connection = [[PGConnection alloc] initWithDelegate:self];
        
    [connection setUser:[[self user] stringValue]];
    [connection setPassword:[[self password] stringValue]];
    
    [connection connect];
}

#pragma mark -
#pragma mark PGConnectionDelegate protocol

- (void)connectionEstablished:(PGConnection *)connection
{
    if (_dbWindowController) {
        [_dbWindowController setConnection:connection];
    } else {
        _dbWindowController = [[DBWindowController alloc] initWithConnection:connection];
        [_dbWindowController showWindow:nil];
    }
    
    // Notify that connection was changed
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectionWasChanged object:connection];
}

- (void)connectionFailed:(PGConnection *)connection
{
    NSString *message = [NSString stringWithFormat:@"Connection failed: %@", [connection lastErrorMessage]];
    [[self connectionMessage] setStringValue:message];
    [[self connectionMessage] setHidden:NO];

}

@end
