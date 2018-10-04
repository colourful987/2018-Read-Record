//
//  CHDemo5DestinationViewController.m
//  TransitionWorld
//
//  Created by pmst on 2018/10/02.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHDemo5DestinationViewController.h"
#import "Masonry.h"

@interface CHDemo5DestinationViewController ()
// 应用程序插画
@property(nonatomic, strong)UIView *appIllustration;
// 应用程序描述
@property(nonatomic, strong)UITextView *textView;
// 关闭按钮
@property(nonatomic, strong)UIButton *closeButton;
@end

@implementation CHDemo5DestinationViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = UIColor.whiteColor;
  
  [self.view addSubview:self.appIllustration];
  [self.appIllustration mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.top.equalTo(self.view);
    make.height.mas_equalTo(367.5);
  }];
  
  [self.appIllustration addSubview:self.closeButton];
  [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.appIllustration).offset(16);
      make.right.equalTo(self.appIllustration).offset(-16);
      make.size.mas_equalTo(CGSizeMake(32, 32));
  }];
  
  [self.view addSubview:self.textView];
  [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.equalTo(self.view);
    make.top.equalTo(self.appIllustration.mas_bottom);
  }];
  
}

- (void)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Custom Accessors
- (UIButton *)closeButton {
  if (!_closeButton) {
    _closeButton = [[UIButton alloc] init];
    [_closeButton setImage:[UIImage imageNamed:@"CloseButton"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
  }
  return _closeButton;
}

- (UIView *)appIllustration {
  if (!_appIllustration) {
    _appIllustration = [[UIView alloc] init];
    _appIllustration.backgroundColor = UIColor.grayColor;
  }
  return _appIllustration;
}

- (UITextView *)textView {
  if (!_textView) {
    _textView = [[UITextView alloc ] init];
    _textView.text = @"每到一个节日，在聊天工具上发个xx节日快乐 总觉得干巴巴的。\n要是日子足够重要，你或许也想过学习电视上的男女主角制造场面盛大的惊喜";
  }
  return _textView;
}

- (CGRect)position {
  return _appIllustration.frame;
}

- (UIView *)appIntroView {
  return _appIllustration;
}

@end
