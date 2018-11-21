//
//  NotificationToken.m
//  NotificationDispatch
//
//  Created by pmst on 2018/11/21.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "NotificationToken.h"

@interface NotificationToken ()
@property(nonatomic, weak)id observer;
@property(nonatomic, assign)SEL selector;
@end

@implementation NotificationToken

- (instancetype)initWithObserver:(id)observer
                        selector:(SEL)aSelector
                            name:(nullable NSNotificationName)aName {
    self = [super init];
    
    if (self) {
        self.observer = observer;
        self.selector = aSelector;
        [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:aName object:nil];
    }
    return self;
}

- (instancetype)initWithObserver:(id)observer {
    self = [super init];
    
    if (self) {
        self.observer = observer;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
}
@end
