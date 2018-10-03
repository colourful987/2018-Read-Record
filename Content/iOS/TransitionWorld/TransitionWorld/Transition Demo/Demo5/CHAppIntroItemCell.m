//
//  CHAppIntroItemCell.m
//  TransitionWorld
//
//  Created by pmst on 2018/10/2.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHAppIntroItemCell.h"

@interface CHAppIntroItemCell()

@end

@implementation CHAppIntroItemCell

- (void)configuration:(UIColor *)color {
  _mockView.backgroundColor = color;
  _mockView.layer.cornerRadius = 5;
  _mockView.layer.shadowOffset = CGSizeMake(4, 4);
  _mockView.layer.shadowRadius = 5;
  _mockView.layer.shadowOpacity = 0.9;
}

- (void)userSelectAppIntroCell {
  [UIView animateWithDuration:0.2 animations:^{
    self.mockView.transform = CGAffineTransformMakeScale(0.9, 0.9);
  }];
  
}

- (void)userDeselectedAppIntroCell {
  self.mockView.transform = CGAffineTransformIdentity;
}

- (CGRect)mockViewFrame {
  return self.mockView.frame;
}
@end
