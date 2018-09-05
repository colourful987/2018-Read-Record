//
//  CircularAnimationController.m
//  TransitionWorld
//
//  Created by pmst on 2018/9/6.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CircularAnimationController.h"
#import "CircleTransitionable.h"

@interface CircularAnimationController()<CAAnimationDelegate>
@property(nonatomic, weak)id<UIViewControllerContextTransitioning> context;
@end

@implementation CircularAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.context = transitionContext;
    
    // containerView 转场过渡中的容器视图，和横屏视图size和方向保持一致
    UIView *containerView = transitionContext.containerView;
    UIViewController<CircleTransitionable> *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController<CircleTransitionable> *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    

    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.frame = toViewController.mainView.frame;
    backgroundView.backgroundColor = fromViewController.mainView.backgroundColor;
    [containerView addSubview:backgroundView];
    
    UIView *snapshot = [fromViewController.mainView snapshotViewAfterScreenUpdates:NO];
    [containerView addSubview:snapshot];
    
    [fromViewController.mainView removeFromSuperview];
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        snapshot.center = CGPointMake(snapshot.center.x - 1300, snapshot.center.y + 1500);
        snapshot.transform = CGAffineTransformMakeScale(5.f, 5.f);
    } completion:nil];
    
    
    [containerView addSubview:toViewController.mainView];
    UIButton *triggerButton = fromViewController.triggerButton;
    UIView *toView = toViewController.mainView;

    CGRect rect = CGRectMake(triggerButton.frame.origin.x,
                             triggerButton.frame.origin.y,
                             triggerButton.frame.size.width,
                             triggerButton.frame.size.width);
    UIBezierPath *circleMaskPathInitial = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    CGFloat fullHeight = toView.bounds.size.height;
    CGPoint extremePoint = CGPointMake(triggerButton.center.x, triggerButton.center.y - fullHeight);
    
    CGFloat radius = sqrt((extremePoint.x * extremePoint.x) +
                          (extremePoint.y * extremePoint.y));
    
    UIBezierPath *circleMaskPathFinal = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(triggerButton.frame, -radius, -radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer new];
    maskLayer.path = circleMaskPathFinal.CGPath;
    toView.layer.mask = maskLayer;
    
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    maskLayerAnimation.fromValue = (__bridge id _Nullable)(circleMaskPathInitial.CGPath);
    maskLayerAnimation.toValue = (__bridge id _Nullable)(circleMaskPathFinal.CGPath);
    maskLayerAnimation.duration = 0.15;
    maskLayerAnimation.delegate = self;
    [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.context completeTransition:true];
}

@end
