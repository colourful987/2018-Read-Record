//
//  CHFadeInAnimationController.m
//  TransitionWorld
//
//  Created by pmst on 2018/8/27.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHFadeInAnimationController.h"

@implementation CHFadeInAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    toView.alpha = 0.f;
    
    if (toView) {
        [transitionContext.containerView addSubview:toView];
        
        CGFloat duration = [self transitionDuration:transitionContext];
        [UIView animateWithDuration:duration animations:^{
            toView.alpha = 1.f;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
        }];
    }
}
@end
