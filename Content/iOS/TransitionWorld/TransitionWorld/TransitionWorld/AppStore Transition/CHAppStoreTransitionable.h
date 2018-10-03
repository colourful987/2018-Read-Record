//
//  CHAppStoreTransitionable.h
//  TransitionWorld
//
//  Created by pmst on 2018/10/3.
//  Copyright © 2018 pmst. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CHAppStoreTransitionable <NSObject>
@property(nonatomic, assign, readonly)CGRect position;
@property(nonatomic, strong, readonly)UIView *appIntroView;
@property(nonatomic, strong, readonly)UITextView *textView;
@end
