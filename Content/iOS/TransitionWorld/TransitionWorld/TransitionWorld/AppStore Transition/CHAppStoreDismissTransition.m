//
//  CHAppStoreDismissTransition.m
//  TransitionWorld
//
//  Created by pmst on 2018/10/4.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHAppStoreDismissTransition.h"
#import "CHAppStoreTransitionable.h"
#import "Masonry.h"

@implementation CHAppStoreDismissTransition
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  UIView *containerView = transitionContext.containerView;
  UIViewController<CHAppStoreTransitionable> *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  UIViewController<CHAppStoreTransitionable> *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  
  // always add toView in containerView is correct
  // and fromView is still in containerView.
  [containerView addSubview:toVC.view];
  [containerView bringSubviewToFront:fromVC.view];
  fromVC.textView.hidden = YES;
  // fromVC.view 慢慢缩小到toView中cell的视图缩略图中
  [UIView animateWithDuration:0.5 animations:^{
    NSLog(@"toVC %@",NSStringFromCGRect(toVC.position));
    fromVC.view.frame = toVC.position;
  } completion:^(BOOL finished) {
    [fromVC.view removeFromSuperview];
    [transitionContext completeTransition:finished];
  }];}
@end
