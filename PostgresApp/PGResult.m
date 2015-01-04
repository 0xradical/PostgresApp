//
//  PGResult.m
//  PostgresApp
//
//  Created by thiago on 12/23/14.
//  Copyright (c) 2014 thiagobrandam. All rights reserved.
//

#import "PGResult.h"

@interface PGResult ()
{
    PGresult *_result;
    NSUInteger _rowsCount;
    NSUInteger _fieldsCount;
}
@end

@implementation PGResult

- (instancetype)initWithResult:(PGresult *)result
{
    self = [super init];
    
    if (self) {
        _result = result;
    }
    
    return self;
}

- (ExecStatusType)status
{
    return PQresultStatus(_result);
}

- (NSUInteger)rowsCount
{
    if (_rowsCount) {
        return _rowsCount;
    }
    
    _rowsCount = PQntuples(_result);
    
    return _rowsCount;
}

- (NSUInteger)fieldsCount
{
    if (_fieldsCount) {
        return _fieldsCount;
    }

    _fieldsCount = PQnfields(_result);

    return _fieldsCount;
}

- (NSString *)valueForRow:(NSUInteger)row AndColumn:(NSUInteger)column
{
    const char* value = PQgetvalue(_result, (int)row, (int)column);
    
    return [NSString stringWithUTF8String:value];
}

- (NSString *)fieldForColumn:(NSUInteger)column
{
    const char* field = PQfname(_result, (int)column);
    
    return [NSString stringWithUTF8String:field];
}

- (void)setValue:(NSString *)value forRow:(NSUInteger)row AndColumn:(NSUInteger)column
{
    char *val = malloc(sizeof(char)*([value length] + 1));
    
    strcpy(val, [value UTF8String]);
    
    PQsetvalue(_result, (int)row, (int)column, val, (int)[value length]);
    
    free(val);

}

- (void)dealloc
{
    PQclear(_result);
}

@end
