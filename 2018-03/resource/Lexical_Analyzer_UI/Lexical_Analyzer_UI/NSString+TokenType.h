//
//  NSString+TokenType.h
//  Lexical_Analyzer
//
//  Created by pmst on 13/03/2018.
//  Copyright © 2018 pmst. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TokenType)
- (BOOL)isspace;

- (BOOL)isdigit;
@end
