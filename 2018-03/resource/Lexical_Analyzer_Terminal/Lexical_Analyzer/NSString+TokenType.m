//
//  NSString+TokenType.m
//  Lexical_Analyzer
//
//  Created by pmst on 13/03/2018.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "NSString+TokenType.h"

@implementation NSString (TokenType)
- (BOOL)isspace {
    unichar ch = [self characterAtIndex:0];
    if (ch == ' ' || ch == '\0') {
        return YES;
    }
    return NO;
}

- (BOOL)isdigit {
    unichar ch = [self characterAtIndex:0];
    if ( ch >= 0x30 && ch <= 0x39 ) {
        return YES;
    }
    return NO;
}

@end
