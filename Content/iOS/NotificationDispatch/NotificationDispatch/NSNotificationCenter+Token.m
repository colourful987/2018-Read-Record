//
//  NSNotificationCenter+Token.m
//  NotificationDispatch
//
//  Created by pmst on 2018/11/21.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "NSNotificationCenter+Token.h"

@implementation NSNotificationCenter (Token)


- (NotificationToken *)observeWithName:(nullable NSNotificationName)aName
                              observer:(id)observer
                              selector:(SEL)aSelector {
    
    [self addObserver:observer selector:aSelector name:aName object:nil];
    
    NotificationToken *token = [[NotificationToken alloc] initWithObserver:observer];
    return token;
}


@end
