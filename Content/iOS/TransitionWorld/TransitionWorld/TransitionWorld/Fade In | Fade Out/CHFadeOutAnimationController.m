//
//  CHFadeOutAnimationController.m
//  TransitionWorld
//
//  Created by pmst on 2018/8/27.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHFadeOutAnimationController.h"

@implementation CHFadeOutAnimationController
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];

    if (fromView) {
        CGFloat duration = [self transitionDuration:transitionContext];
        [UIView animateWithDuration:duration animations:^{
            fromView.alpha = 0.f;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
        }];
    }
}
@end
