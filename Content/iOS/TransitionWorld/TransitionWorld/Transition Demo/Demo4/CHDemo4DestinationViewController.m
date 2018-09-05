//
//  CHDemo4DestinationViewController.m
//  TransitionWorld
//
//  Created by pmst on 2018/9/6.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHDemo4DestinationViewController.h"
#import "Masonry.h"


@interface CHDemo4DestinationViewController ()
@property(nonatomic, strong)UIButton *closeButton;
@end

@implementation CHDemo4DestinationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    
    [self.view addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(32);
        make.right.equalTo(self.view).offset(-32);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

- (void)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Custom Accessors
- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        _closeButton.backgroundColor = UIColor.whiteColor;
        [_closeButton addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton *)triggerButton {
    return self.closeButton;
}

- (UIView *)mainView {
    return self.view;
}

@end
