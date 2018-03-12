//
//  Token.h
//  Lexical_Analyzer
//
//  Created by pmst on 12/03/2018.
//  Copyright © 2018 pmst. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, TokenType) {
    TokenType_INTEGER,
    TokenType_PLUS,
    TokenType_MINUS,
    TokenType_EOF
};

@interface Token : NSObject
@property(nonatomic, assign)TokenType type;
@property(nonatomic, strong)id value;

- (instancetype)initWithType:(TokenType)type value:(id)value;
@end





























