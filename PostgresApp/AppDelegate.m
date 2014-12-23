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

}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

#pragma mark -
#pragma mark IBActions

- (IBAction)connect:(id)sender
{
    PGConnection *connection = [[PGConnection alloc] initWithDelegate:self];
    
    [self setConnection:connection];
    
    [[self connection] setUser:[[self user] stringValue]];
    [[self connection] setPassword:[[self password] stringValue]];
    
    [[self connection] connect];
    
    _dbWindowController = [[DBWindowController alloc] initWithConnection:[self connection]];
    
    [_dbWindowController showWindow:nil];
}

#pragma mark -
#pragma mark PGConnectionDelegate protocol

- (void)connectionEstablished:(PGConnection *)connection
{
    [[self connectionMessage] setStringValue:@"Connected :)"];
    [[self connectionMessage] setHidden:NO];

}

- (void)connectionFailed:(PGConnection *)connection
{
    [[self connectionMessage] setStringValue:@"Connection failed :("];
    [[self connectionMessage] setHidden:NO];

}

@end
