//
//  DisposeBag.h
//  AdvancedNotificationDispatch
//
//  Created by pmst on 2018/11/22.
//  Copyright © 2018 pmst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationToken.h"

NS_ASSUME_NONNULL_BEGIN

@interface DisposeBag : NSObject
- (void)addToken:(NotificationToken *)token;
@end

NS_ASSUME_NONNULL_END
