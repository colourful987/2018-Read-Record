//
//  CHDemo4SourceViewController.m
//  TransitionWorld
//
//  Created by pmst on 2018/9/6.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHDemo4SourceViewController.h"
#import "CHDemo4DestinationViewController.h"
#import "Masonry.h"
#import "CircularAnimationController.h"

@interface CHDemo4SourceViewController ()<UIViewControllerTransitioningDelegate>
@property(nonatomic, strong)UIButton *actionButton;
@end

@implementation CHDemo4SourceViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self p_initialize];
}

#pragma mark - IBActions
- (void)presentAction:(id)sender {
    CHDemo4DestinationViewController *destinationVC = [[CHDemo4DestinationViewController alloc] init];
    
    destinationVC.transitioningDelegate = self;
    
    [self presentViewController:destinationVC animated:YES completion:nil];
}

- (void)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public

#pragma mark - Private
- (void)p_initialize {
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    actionButton.backgroundColor = UIColor.blackColor;
    [actionButton addTarget:self action:@selector(presentAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:actionButton];
    
    [actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(32);
        make.right.equalTo(self.view).offset(-32);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    self.actionButton = actionButton;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(32);
        make.top.equalTo(actionButton.mas_bottom).offset(20);
    }];
}
#pragma mark - Protocol conformance
#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[CircularAnimationController alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[CircularAnimationController alloc] init];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {

    return nil;
}

- (UIButton *)triggerButton {
    return self.actionButton;
}

- (UIView *)mainView {
    return self.view;
}

#pragma mark - NSCopying

#pragma mark - NSObject

#pragma mark - Custom Accessors


@end
