//
//  CHAppStoreTransition.m
//  TransitionWorld
//
//  Created by pmst on 2018/10/3.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHAppStoreTransition.h"
#import "CHAppStoreTransitionable.h"
#import "Masonry.h"

@implementation CHAppStoreTransition
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  // 第一阶段 概要图缩放到0.9(optional) 添加x按钮
  // containerView 转场过渡中的容器视图，和横屏视图size和方向保持一致
  UIView *containerView = transitionContext.containerView;
  UIViewController<CHAppStoreTransitionable> *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  UIViewController<CHAppStoreTransitionable> *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

  // always add toView in containerView is correct
  // and fromView is still in containerView.
  // 牢记：fromView一开始就存在，toView总是需要我们去手动添加
  // 动画一开始 我们就把toView视图放置当前cell的位置
  toVC.view.frame = fromVC.position;
  [toVC.view layoutIfNeeded];
  toVC.appIntroView.backgroundColor = fromVC.appIntroView.backgroundColor;
  toVC.textView.hidden = YES; // 先隐藏掉
  [containerView addSubview:toVC.view];
  
  [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
    [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.7 animations:^{
      [toVC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.right.equalTo(@(-16));
        make.height.mas_equalTo(CGRectGetHeight(containerView.bounds) - 40);
        make.top.equalTo(@40);
      }];
      [containerView layoutIfNeeded];
    }];
    
    [UIView addKeyframeWithRelativeStartTime:0.7 relativeDuration:0.3 animations:^{
      [toVC.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(containerView);
        make.top.equalTo(containerView);
      }];
      [containerView layoutIfNeeded];
    }];
  } completion:^(BOOL finished) {
    toVC.textView.hidden = NO;
    [transitionContext completeTransition:finished];
  }];

  
  // 第三阶段 概要图离顶部大概40pt时候可以进行width变换，最大就是screen width
  
  // 第四阶段 概要图回到顶部位置 textview 出现

}
@end
