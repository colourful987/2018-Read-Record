//
//  CHSlideInteractionController.h
//  TransitionWorld
//
//  Created by pmst on 2018/9/4.
//  Copyright © 2018 pmst. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHSlideInteractionController : UIPercentDrivenInteractiveTransition
@property(nonatomic, assign)BOOL interactionInProgress;

- (instancetype)initWithViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
