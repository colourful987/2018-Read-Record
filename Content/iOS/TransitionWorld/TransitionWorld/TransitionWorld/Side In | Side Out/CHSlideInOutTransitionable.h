//
//  CHSlideInOutTransitionable.h
//  TransitionWorld
//
//  Created by pmst on 2018/8/28.
//  Copyright © 2018 pmst. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CHSlideInOutTransitionable <NSObject>
@property(nonatomic, strong, readonly)UIView *contentView;
@property(nonatomic, assign, readonly)CGRect contentRect;
@end
