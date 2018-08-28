//
//  CHSlideOutAnimationController.m
//  TransitionWorld
//
//  Created by pmst on 2018/8/28.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHSlideOutAnimationController.h"
#import "CHSlideInOutTransitionable.h"

@implementation CHSlideOutAnimationController
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController<CHSlideInOutTransitionable> *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    if (fromViewController && fromView) {
        UIView *contentView = fromViewController.contentView;

        CGRect finalRect = CGRectMake(contentView.frame.origin.x, contentView.frame.origin.y + CGRectGetHeight(contentView.frame), contentView.frame.size.width, contentView.frame.size.height);
        
        CGFloat duration = [self transitionDuration:transitionContext];
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
             contentView.frame = finalRect;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
        }];
    }
}
@end
