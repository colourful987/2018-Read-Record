//
//  CHDemo1SourceViewController.m
//  TransitionWorld
//
//  Created by pmst on 2018/8/28.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHDemo1SourceViewController.h"
#import "CHDemo1DestinationViewController.h"
#import "Masonry.h"
#import "DimmingPresentationController.h"
#import "CHSlideInAnimationController.h"
#import "CHSlideOutAnimationController.h"

@interface CHDemo1SourceViewController ()<UIViewControllerTransitioningDelegate>

@end

@implementation CHDemo1SourceViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self p_initialize];
}

#pragma mark - IBActions
- (void)presentAction:(id)sender {
    CHDemo1DestinationViewController *destinationVC = [[CHDemo1DestinationViewController alloc] init];
    destinationVC.transitioningDelegate = self;
    destinationVC.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:destinationVC animated:YES completion:nil];
}

- (void)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public

#pragma mark - Private
- (void)p_initialize {
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [actionButton setTitle:@"Trigger Present Action" forState:UIControlStateNormal];
    [actionButton addTarget:self action:@selector(presentAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:actionButton];
    
    [actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view).offset(32);
    }];
    
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
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[DimmingPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[CHSlideInAnimationController alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[CHSlideOutAnimationController alloc] init];
}
#pragma mark - NSCopying

#pragma mark - NSObject

#pragma mark - Custom Accessors


@end
