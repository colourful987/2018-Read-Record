//
//  Token.m
//  Lexical_Analyzer
//
//  Created by pmst on 12/03/2018.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "Token.h"

@implementation Token

- (instancetype)initWithType:(TokenType)type value:(id)value {
    
    self = [super init];
    
    if (self) {
        _type = type;
        _value = value;
    }
    
    return self;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"Token(%@,%@)",self.str_tokenType, self.value];
}

- (NSString *)str_tokenType {

    switch (self.type) {
        case TokenType_INTEGER:
            return @"INTEGER";
            break;
        case TokenType_PLUS:
            return @"PLUS";
            break;
        case TokenType_MINUS:
            return @"MINUS";
            break;
        case TokenType_EOF:
            return @"EOF";
            break;
        default:
            return @"EOF";
            break;
    }
}
@end


























