//
//  PGResult.h
//  PostgresApp
//
//  Created by thiago on 12/23/14.
//  Copyright (c) 2014 thiagobrandam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "libpq-fe.h"

@interface PGResult : NSObject

- (instancetype)initWithResult:(PGresult *)result;
- (NSUInteger)rowsCount;
- (NSUInteger)fieldsCount;
- (NSString *)valueForRow:(NSUInteger)row AndColumn:(NSUInteger)column;
- (NSString *)fieldForColumn:(NSUInteger)column;

@end
