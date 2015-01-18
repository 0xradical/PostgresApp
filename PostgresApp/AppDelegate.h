//
//  AppDelegate.h
//  PostgresApp
//
//  Created by thiago on 12/22/14.
//  Copyright (c) 2014 thiagobrandam. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PGConnectionDelegate.h"

@class PGConnection;

@interface AppDelegate : NSObject <NSApplicationDelegate, PGConnectionDelegate>

@end

