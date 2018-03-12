//
//  main.m
//  Lexical_Analyzer
//
//  Created by pmst on 12/03/2018.
//  Copyright © 2018 pmst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Interpreter.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        char *cstring = malloc(sizeof(char) * 100);
        NSLog(@"请输入一个字符串：");
        
        // 方式一. c语言层面，但是这里有个问题 scanf会忽略空格和回车
        // 因此只能验证 `1+2-100` 无空格的表达式
        scanf("%s" , cstring);
        NSString *text = [NSString stringWithUTF8String:cstring];
        // 方式二. oc层面
        // 这里可以调用[NSString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet] 去除空格换行 当然我们会用自己写的方法 超级挫
        //NSString *text = [[NSString alloc] initWithData:[[NSFileHandle fileHandleWithStandardInput] availableData] encoding:NSUTF8StringEncoding];
        
        Interpreter *interpreter = [[Interpreter alloc] initWithText:text];
        NSLog(@"result is %d",[interpreter expr]);

    }
    return 0;
}
