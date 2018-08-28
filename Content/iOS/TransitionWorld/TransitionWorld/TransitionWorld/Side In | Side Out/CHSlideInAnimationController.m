//
//  CHSlideInAnimationController.m
//  TransitionWorld
//
//  Created by pmst on 2018/8/28.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHSlideInAnimationController.h"
#import "CHSlideInOutTransitionable.h"

@implementation CHSlideInAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.15;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController<CHSlideInOutTransitionable> *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    if (toViewController && toView) {
        [transitionContext.containerView addSubview:toView];
        UIView *contentView = toViewController.contentView;
        CGRect contentRect = toViewController.contentRect;
        CGRect finalRect = contentRect;
        CGRect startRect = CGRectMake(contentRect.origin.x, contentRect.origin.y + CGRectGetHeight(contentRect), contentRect.size.width, contentRect.size.height);
        contentView.frame = startRect;
        
        CGFloat duration = [self transitionDuration:transitionContext];
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            contentView.frame = finalRect;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
        }];
    }
}

@end
