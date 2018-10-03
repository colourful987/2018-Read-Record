//
//  CHAppIntroItemCell.h
//  TransitionWorld
//
//  Created by pmst on 2018/10/2.
//  Copyright © 2018 pmst. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHAppIntroItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *mockView;
@property(nonatomic, assign, readonly)CGRect mockViewFrame;

- (void)configuration:(UIColor *)color;

- (void)userSelectAppIntroCell;

- (void)userDeselectedAppIntroCell;
@end
