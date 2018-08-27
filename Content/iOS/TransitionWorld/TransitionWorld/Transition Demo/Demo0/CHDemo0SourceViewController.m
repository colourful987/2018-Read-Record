//
//  CHDemo0SourceViewController.m
//  TransitionWorld
//
//  Created by pmst on 2018/8/27.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHDemo0SourceViewController.h"
#import "CHDemo0DestinationViewController.h"
#import "Masonry.h"
#import "DimmingPresentationController.h"
#import "CHFadeInAnimationController.h"
#import "CHFadeOutAnimationController.h"

@interface CHDemo0SourceViewController ()<UIViewControllerTransitioningDelegate>

@end

@implementation CHDemo0SourceViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self p_initialize];
}

#pragma mark - IBActions
- (void)presentAction:(id)sender {
    CHDemo0DestinationViewController *destinationVC = [[CHDemo0DestinationViewController alloc] init];
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
    return [[CHFadeInAnimationController alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[CHFadeOutAnimationController alloc] init];
}
#pragma mark - NSCopying

#pragma mark - NSObject

#pragma mark - Custom Accessors


@end
