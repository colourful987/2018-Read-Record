//
//  Interpreter.m
//  Lexical_Analyzer
//
//  Created by pmst on 12/03/2018.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "Interpreter.h"
#import "Token.h"
#import "NSString+TokenType.h"

#define C2S(c) [NSString stringWithFormat:@"%c", c]
#define C2S_Text(s,idx) C2S([s characterAtIndex:idx])

@interface Interpreter()
@property(nonatomic, strong) NSString *text;
@property(nonatomic, assign) int position;
@property(nonatomic, strong) Token *current_token;
@property(nonatomic, strong) NSString *current_char;
@end

@implementation Interpreter
- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        _position = 0;
        _text = text;
        _current_token = nil;
        _current_char = C2S_Text(_text,_position);
    }
    return self;
}

- (void)advance{
    _position += 1;
    if (_position > _text.length - 1) {
        self.current_char = nil;
    } else {
        self.current_char = C2S_Text(_text,_position);;
    }
}

- (void)skip_whitespace {
    while (self.current_char != nil && self.current_char.isspace) {
        [self advance];
    }
}

- (int)integer {
    NSMutableString *result = [@"" mutableCopy];
    while (self.current_char != nil && self.current_char.isdigit) {
        [result appendString: self.current_char];
        [self advance];
    }
    
    return [result intValue];
}

- (Token *)get_next_token {
    while (self.current_char != nil) {
        if (self.current_char.isspace) {
            [self skip_whitespace];
            continue;
        }
        
        if (self.current_char.isdigit) {
            return [[Token alloc] initWithType:TokenType_INTEGER value:@([self integer])];
        }
        
        if ([self.current_char isEqualToString: @"+"]) {
            [self advance];
            return [[Token alloc] initWithType:TokenType_PLUS value:@"+"];
        }
        
        if ([self.current_char isEqualToString: @"-"]) {
            [self advance];
            return [[Token alloc] initWithType:TokenType_MINUS value:@"-"];
        }
        
        [NSException exceptionWithName:@"出错" reason:@"出错" userInfo:nil];
    }
    return [[Token alloc] initWithType:TokenType_EOF value:nil];
}

- (void)eat:(TokenType)type {
    if (self.current_token.type == type) {
        self.current_token = [self get_next_token];
    } else {
        [NSException exceptionWithName:@"出错" reason:@"出错" userInfo:nil];
    }
}

- (int)term {
    Token *tk = self.current_token;
    [self eat:TokenType_INTEGER];
    return [tk.value intValue];
}

- (int)expr {
    self.current_token = [self get_next_token];
    
    int result = [self term];
    while (self.current_token.type == TokenType_PLUS || self.current_token.type == TokenType_MINUS) {
        Token *token = self.current_token;
        
        if (token.type == TokenType_PLUS) {
            [self eat:TokenType_PLUS];
            result = result + [self term];
        } else if (token.type == TokenType_MINUS) {
            [self eat:TokenType_MINUS];
            result = result - [self term];
        }
    }
    return result;
}
@end





























