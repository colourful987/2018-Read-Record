//
//  CircleTransitionable.h
//  TransitionWorld
//
//  Created by pmst on 2018/9/6.
//  Copyright © 2018 pmst. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CircleTransitionable <NSObject>
@property(nonatomic, strong, readonly)UIButton *triggerButton;
@property(nonatomic, strong, readonly)UIView *mainView;
@end

NS_ASSUME_NONNULL_END
