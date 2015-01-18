// SQLSyntaxHighlighter.m
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SQLSyntaxHighlighter.h"

static NSSet * SQLReservedWordSet() {
    static NSSet *_SQLReservedWords = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _SQLReservedWords = [[NSSet alloc] initWithObjects:@"ADD", @"ALL", @"ALTER", @"ANALYZE", @"AND", @"AS", @"ASC", @"ASENSITIVE", @"BEFORE", @"BETWEEN", @"BIGINT", @"BINARY", @"BLOB", @"BOTH", @"BY", @"CALL", @"CASCADE", @"CASE", @"CHANGE", @"CHAR", @"CHARACTER", @"CHECK", @"COLLATE", @"COLUMN", @"CONDITION", @"CONSTRAINT", @"CONTINUE", @"CONVERT", @"CREATE", @"CROSS", @"CURRENT_DATE", @"CURRENT_TIME", @"CURRENT_TIMESTAMP", @"CURRENT_USER", @"CURSOR", @"DATABASE", @"DATABASES", @"DAY_HOUR", @"DAY_MICROSECOND", @"DAY_MINUTE", @"DAY_SECOND", @"DEC", @"DECIMAL", @"DECLARE", @"DEFAULT", @"DELAYED", @"DELETE", @"DESC", @"DESCRIBE", @"DETERMINISTIC", @"DISTINCT", @"DISTINCTROW", @"DIV", @"DOUBLE", @"DROP", @"DUAL", @"EACH", @"ELSE", @"ELSEIF", @"ENCLOSED", @"ESCAPED", @"EXISTS", @"EXIT", @"EXPLAIN", @"FALSE", @"FETCH", @"FLOAT", @"FLOAT4", @"FLOAT8", @"FOR", @"FORCE", @"FOREIGN", @"FROM", @"FULLTEXT", @"GRANT", @"GROUP", @"HAVING", @"HIGH_PRIORITY", @"HOUR_MICROSECOND", @"HOUR_MINUTE", @"HOUR_SECOND", @"IF", @"IGNORE", @"IN", @"INDEX", @"INFILE", @"INNER", @"INOUT", @"INSENSITIVE", @"INSERT", @"INT", @"INT1", @"INT2", @"INT3", @"INT4", @"INT8", @"INTEGER", @"INTERVAL", @"INTO", @"IS", @"ITERATE", @"JOIN", @"KEY", @"KEYS", @"KILL", @"LEADING", @"LEAVE", @"LEFT", @"LIKE", @"LIMIT", @"LINES", @"LOAD", @"LOCALTIME", @"LOCALTIMESTAMP", @"LOCK", @"LONG", @"LONGBLOB", @"LONGTEXT", @"LOOP", @"LOW_PRIORITY", @"MATCH", @"MEDIUMBLOB", @"MEDIUMINT", @"MEDIUMTEXT", @"MIDDLEINT", @"MINUTE_MICROSECOND", @"MINUTE_SECOND", @"MOD", @"MODIFIES", @"NATURAL", @"NOT", @"NO_WRITE_TO_BINLOG", @"NULL", @"NUMERIC", @"ON", @"OPTIMIZE", @"OPTION", @"OPTIONALLY", @"OR", @"ORDER", @"OUT", @"OUTER", @"OUTFILE", @"PRECISION", @"PRIMARY", @"PROCEDURE", @"PURGE", @"READ", @"READS", @"REAL", @"REFERENCES", @"REGEXP", @"RELEASE", @"RENAME", @"REPEAT", @"REPLACE", @"REQUIRE", @"RESTRICT", @"RETURN", @"REVOKE", @"RIGHT", @"RLIKE", @"SCHEMA", @"SCHEMAS", @"SECOND_MICROSECOND", @"SELECT", @"SENSITIVE", @"SEPARATOR", @"SET", @"SHOW", @"SMALLINT", @"SONAME", @"SPATIAL", @"SPECIFIC", @"SQL", @"SQLEXCEPTION", @"SQLSTATE", @"SQLWARNING", @"SQL_BIG_RESULT", @"SQL_CALC_FOUND_ROWS", @"SQL_SMALL_RESULT", @"SSL", @"STARTING", @"STRAIGHT_JOIN", @"TABLE", @"TERMINATED", @"THEN", @"TINYBLOB", @"TINYINT", @"TINYTEXT", @"TO", @"TRAILING", @"TRIGGER", @"TRUE", @"UNDO", @"UNION", @"UNIQUE", @"UNLOCK", @"UNSIGNED", @"UPDATE", @"USAGE", @"USE", @"USING", @"UTC_DATE", @"UTC_TIME", @"UTC_TIMESTAMP", @"VALUES", @"VARBINARY", @"VARCHAR", @"VARCHARACTER", @"VARYING", @"WHEN", @"WHERE", @"WHILE", @"WITH", @"WRITE", @"XOR", @"YEAR_MONTH", @"ZEROFILL", nil];
    });
    
    return _SQLReservedWords;
}

static NSCharacterSet * SQLNumericSymbolsCharacterSet() {
    static NSMutableCharacterSet *_SQLNumericSymbolsCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _SQLNumericSymbolsCharacterSet = [[NSMutableCharacterSet alloc] init];
        [_SQLNumericSymbolsCharacterSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
        [_SQLNumericSymbolsCharacterSet addCharactersInString:@"<=>"];
        [_SQLNumericSymbolsCharacterSet invert];
    });
    
    return _SQLNumericSymbolsCharacterSet;
}

static NSDictionary * SQLReservedWordsStyleAttributes() {
    static NSDictionary *_SQLReservedWordsStyleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _SQLReservedWordsStyleAttributes = [NSDictionary dictionaryWithObject:[NSColor orangeColor] forKey:NSForegroundColorAttributeName];
    });
    
    return _SQLReservedWordsStyleAttributes;
}

static NSDictionary * SQLNumericSymbolsStyleAttributes() {
    static NSDictionary *_SQLNumericSymbolsStyleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _SQLNumericSymbolsStyleAttributes = [NSDictionary dictionaryWithObject:[NSColor darkGrayColor] forKey:NSForegroundColorAttributeName];
    });
    
    return _SQLNumericSymbolsStyleAttributes;
}

static NSDictionary * SQLNormalWordsStyleAttributes() {
    static NSDictionary *_SQLNormalWordsStyleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _SQLNormalWordsStyleAttributes = [NSDictionary dictionaryWithObject:[NSColor blueColor] forKey:NSForegroundColorAttributeName];
    });
    
    return _SQLNormalWordsStyleAttributes;
}

@interface SQLSyntaxHighlighter ()
{
    NSLinguisticTagger *_tagger;
}
@property (unsafe_unretained) IBOutlet NSTextView *customQuery;

@end

@implementation SQLSyntaxHighlighter

- (void)awakeFromNib {
    _tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:[NSArray arrayWithObject:NSLinguisticTagSchemeTokenType] options:NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerOmitOther];
    
    [self.customQuery setDelegate:self];
    [[self.customQuery textStorage] setDelegate:self];
}

#pragma mark - NSTextViewDelegate

- (NSArray *)textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    if (charRange.length == 0) {
        return nil;
    }
    
    NSString *partialWord = [[textView string] substringWithRange:charRange];
    
    return [[SQLReservedWordSet() filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", partialWord]] allObjects];
}

#pragma mark - NSTextStorageDelegate

- (void)textStorageWillProcessEditing:(NSNotification *)notification {
    NSTextStorage *textStorage = [notification object];
    NSString *string = [textStorage string];
    NSRange stringRange = NSMakeRange(0, [string length]);
    
    NSLayoutManager *layoutManager = [[textStorage layoutManagers] objectAtIndex:0];
    
    _tagger.string = [textStorage string];
    
    [_tagger enumerateTagsInRange:stringRange scheme:NSLinguisticTagSchemeTokenType options:NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerOmitOther usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
        if (NSMaxRange(tokenRange) != NSMaxRange(stringRange)) {
            NSString *token = [string substringWithRange:tokenRange];
            
            if ([SQLReservedWordSet() containsObject:[token uppercaseString]]) {
                [layoutManager addTemporaryAttributes:SQLReservedWordsStyleAttributes() forCharacterRange:tokenRange];
            } else if ([token rangeOfCharacterFromSet:SQLNumericSymbolsCharacterSet()].location == NSNotFound) {
                [layoutManager addTemporaryAttributes:SQLNumericSymbolsStyleAttributes() forCharacterRange:tokenRange];
            } else {
                [layoutManager addTemporaryAttributes:SQLNormalWordsStyleAttributes() forCharacterRange:tokenRange];
            }
        }
    }];
}


@end
