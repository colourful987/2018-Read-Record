//
//  DisposeBag.m
//  AdvancedNotificationDispatch
//
//  Created by pmst on 2018/11/22.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "DisposeBag.h"

@interface DisposeBag ()
@property(nonatomic, strong)NSMutableArray<NotificationToken *> *tokens;
@end

@implementation DisposeBag
- (NSMutableArray<NotificationToken *> *)tokens {
    if (!_tokens) {
        _tokens = [[NSMutableArray alloc] init];
    }
    return _tokens;
}

- (void)addToken:(NotificationToken *)token {
    @synchronized(self) {
        [self.tokens addObject:token];
    }
}

@end
