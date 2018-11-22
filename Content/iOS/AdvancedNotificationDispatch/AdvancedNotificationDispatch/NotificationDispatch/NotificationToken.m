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
@end

@implementation NotificationToken

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
