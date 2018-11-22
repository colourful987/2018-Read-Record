//
//  NSObject+Notification_Private.m
//  AdvancedNotificationDispatch
//
//  Created by pmst on 2018/11/22.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "NSObject+Notification_Private.h"
#import <objc/runtime.h>
#import "DisposeBag.h"

static const char key_of_disposeBagContext;

@implementation NSObject (Notification_Private)

- (DisposeBag *)disposeBag {
    DisposeBag *bag = objc_getAssociatedObject(self, &key_of_disposeBagContext);
    if (!bag) {
        bag = [DisposeBag new];
        objc_setAssociatedObject(self, &key_of_disposeBagContext, bag, OBJC_ASSOCIATION_RETAIN);
    }
    return bag;
}

- (void)observeWithName:(nullable NSNotificationName)aName
               observer:(id)observer
               selector:(SEL)aSelector {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:aName object:nil];
    
    NotificationToken *token = [[NotificationToken alloc] initWithObserver:observer];
    [self.disposeBag addToken:token];
}

@end
