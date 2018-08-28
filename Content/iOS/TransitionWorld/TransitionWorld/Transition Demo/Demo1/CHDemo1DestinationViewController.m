//
//  CHDemo1DestinationViewController.m
//  TransitionWorld
//
//  Created by pmst on 2018/8/28.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHDemo1DestinationViewController.h"
#import "Masonry.h"

static CGFloat const kHeightOfContentView = 200;

@interface CHDemo1DestinationViewController ()<UIGestureRecognizerDelegate>
@property(nonatomic, strong)UIView *contentView;
@property(nonatomic, strong)UIButton *closeButton;
@end

@implementation CHDemo1DestinationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.closeButton];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.mas_equalTo(kHeightOfContentView);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAction:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self.view;
}

#pragma mark - Custom Accessors
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = UIColor.redColor;
    }
    return _contentView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"CloseButton"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (CGRect)contentRect {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat screenHeight = CGRectGetHeight(screenRect);
    CGFloat screenWidth = CGRectGetWidth(screenRect);
    return CGRectMake(0, screenHeight - kHeightOfContentView, screenWidth, kHeightOfContentView);
}
@end
