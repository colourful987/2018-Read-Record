//
//  CHDemo2SourceViewController.m
//  TransitionWorld
//
//  Created by pmst on 2018/8/28.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHDemo2SourceViewController.h"
#import "CHDemo2DestinationViewController.h"
#import "Masonry.h"
#import "CHRotateToPortaitAnimationController.h"
#import "CHRotateToLandscapeAnimationController.h"
#import "CHRotateTransitionable.h"

@interface CHDemo2SourceViewController ()<UIViewControllerTransitioningDelegate, CHRotateTransitionable>
@property(nonatomic, strong)UIView *playerView;

@end

@implementation CHDemo2SourceViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self p_initialize];
}

#pragma mark - IBActions
- (void)presentAction:(id)sender {
    CHDemo2DestinationViewController *destinationVC = [[CHDemo2DestinationViewController alloc] init];
    destinationVC.transitioningDelegate = self;
    
    [self presentViewController:destinationVC animated:YES completion:nil];
}

- (void)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public

#pragma mark - Private
- (void)p_initialize {
    [self.view addSubview:self.playerView];
    
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.mas_equalTo(@200);
    }];

    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [actionButton setTitle:@"Trigger Present Action" forState:UIControlStateNormal];
    [actionButton addTarget:self action:@selector(presentAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:actionButton];
    
    [actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(240);
        make.left.equalTo(self.view).offset(32);
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

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[CHRotateToLandscapeAnimationController alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[CHRotateToPortaitAnimationController alloc] init];
}
#pragma mark - NSCopying

#pragma mark - NSObject

#pragma mark - Custom Accessors
- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [[UIView alloc] initWithFrame:CGRectZero];
        _playerView.backgroundColor = UIColor.redColor;
    }
    return _playerView;
}

- (UIView *)viewToRotate {
    return _playerView;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
@end
