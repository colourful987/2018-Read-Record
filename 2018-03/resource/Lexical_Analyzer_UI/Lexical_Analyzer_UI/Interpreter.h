//
//  Interpreter.h
//  Lexical_Analyzer
//
//  Created by pmst on 12/03/2018.
//  Copyright © 2018 pmst. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Interpreter : NSObject

- (instancetype)initWithText:(NSString *)text;

- (int)expr ;
@end
