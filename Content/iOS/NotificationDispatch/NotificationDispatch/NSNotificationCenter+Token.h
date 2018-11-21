//
//  NSNotificationCenter+Token.h
//  NotificationDispatch
//
//  Created by pmst on 2018/11/21.
//  Copyright © 2018 pmst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationToken.h"

NS_ASSUME_NONNULL_BEGIN
@interface NSNotificationCenter (Token)

- (NotificationToken *)observeWithName:(nullable NSNotificationName)aName
                              observer:(id)observer
                              selector:(SEL)aSelector;
@end

NS_ASSUME_NONNULL_END
