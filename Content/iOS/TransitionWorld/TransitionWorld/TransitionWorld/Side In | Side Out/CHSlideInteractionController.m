//
//  CHSlideInteractionController.m
//  TransitionWorld
//
//  Created by pmst on 2018/9/4.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHSlideInteractionController.h"

@interface CHSlideInteractionController()
@property(nonatomic, assign)BOOL shouldCompleteTransition;
@property(nonatomic, weak)UIViewController *viewController;

@end

@implementation CHSlideInteractionController

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    
    if (self) {
        self.interactionInProgress = NO;
        self.shouldCompleteTransition = NO;
        self.viewController = viewController;
        [self prepareGestureRecognizerIn:viewController.view];
    }
    
    return self;
}

- (void)prepareGestureRecognizerIn:(UIView *)view {
    UIScreenEdgePanGestureRecognizer *gesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    gesture.edges = UIRectEdgeLeft;
    [view addGestureRecognizer:gesture];
}


- (void)handleGesture:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    CGFloat progress = translation.x/200;
    progress = MIN(MAX(progress, 0.0), 1.0);
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.interactionInProgress = YES;
            [self.viewController dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case UIGestureRecognizerStateChanged:{
            self.shouldCompleteTransition = progress > 0.5;
            [self updateInteractiveTransition:progress];
            }
            break;
        case UIGestureRecognizerStateCancelled:{
            self.interactionInProgress = NO;
            [self cancelInteractiveTransition];
        }
            break;
        case UIGestureRecognizerStateEnded:{
            self.interactionInProgress = NO;
            if (self.shouldCompleteTransition) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
        }
            break;
        default:
            break;
    }
    
}
@end
