//
//  CHRotateToLandscapeAnimationController.m
//  TransitionWorld
//
//  Created by pmst on 2018/8/28.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHRotateToLandscapeAnimationController.h"
#import "CHRotateTransitionable.h"

@implementation CHRotateToLandscapeAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // containerView 转场过渡中的容器视图，和横屏视图size和方向保持一致
    UIView *containerView = transitionContext.containerView;
    UIViewController<CHRotateTransitionable> *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController<CHRotateTransitionable> *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // always add toView in containerView is correct
    // and fromView is still in containerView.
    toViewController.view.frame = containerView.bounds;
    [containerView addSubview:toViewController.view];
    [containerView bringSubviewToFront:fromViewController.view];
    
    // 此时from中的视图位置是明确的
    UIView *viewToRotate = fromViewController.viewToRotate;
    UIView *viewToRotateInToView = toViewController.viewToRotate;
    [viewToRotateInToView.superview layoutIfNeeded];
    
    CGPoint initialCenter = viewToRotate.center;
    CGSize initialSize = viewToRotate.frame.size;
    
    CGSize finalSize = viewToRotateInToView.frame.size;
    CGPoint pt = CGPointMake(CGRectGetMidX(viewToRotateInToView.frame), CGRectGetMidY(viewToRotateInToView.frame));
    CGPoint finalCenter = [containerView convertPoint:pt toView:viewToRotate.superview];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        viewToRotate.bounds = CGRectMake(0, 0, finalSize.width, finalSize.height);
        viewToRotate.center = finalCenter;
        viewToRotate.transform = CGAffineTransformMakeRotation(M_PI_2);
    } completion:^(BOOL finished) {
        [containerView bringSubviewToFront:toViewController.view];
        viewToRotate.bounds = CGRectMake(0, 0, initialSize.width, initialSize.height);
        viewToRotate.center = initialCenter;
        viewToRotate.transform = CGAffineTransformMakeRotation(0);

        [transitionContext completeTransition:finished];
        
    }];
}
@end



























