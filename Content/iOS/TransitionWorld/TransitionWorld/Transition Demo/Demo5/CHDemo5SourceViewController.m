//
//  CHDemo5SourceViewController.m
//  TransitionWorld
//
//  Created by pmst on 2018/10/02.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHDemo5SourceViewController.h"
#import "CHDemo5DestinationViewController.h"
#import "CHAppIntroItemCell.h"
#import "CHAppStoreTransition.h"
#import "Masonry.h"


@interface CHDemo5SourceViewController ()<UIViewControllerTransitioningDelegate, UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong)UITableView *list;
@property(nonatomic, strong)NSArray *mockModel;
@property(nonatomic, assign)CGRect selectFrame;
@property(nonatomic, strong)UIView *selectView;
@end

@implementation CHDemo5SourceViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mockModel = @[UIColor.redColor, UIColor.greenColor, UIColor.lightGrayColor];
    [self p_initialize];
}

#pragma mark - IBActions
- (void)gotoDetailApplicationIntroPage {
    CHDemo5DestinationViewController *destinationVC = [[CHDemo5DestinationViewController alloc] init];
    
    destinationVC.transitioningDelegate = self;  
    [self presentViewController:destinationVC animated:YES completion:nil];
}

- (void)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public

#pragma mark - Private
- (void)p_initialize {
  self.view.backgroundColor = UIColor.whiteColor;
  
  UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [closeButton setTitle:@"Close" forState:UIControlStateNormal];
  [closeButton addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:closeButton];
  
  [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view).offset(32);
    make.top.equalTo(self.view).offset(32);
  }];
  
  self.list = [[UITableView alloc] init];
  self.list.delegate = self;
  self.list.dataSource = self;
  [self.view addSubview:self.list];
  
  [self.list registerNib:[UINib nibWithNibName:@"CHAppIntroItemCell" bundle:nil] forCellReuseIdentifier:@"AppCellIdentifier"];
  [self.list mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.bottom.right.equalTo(self.view);
    make.top.equalTo(closeButton.mas_bottom);
  }];
}
#pragma mark - Protocol conformance
#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString * const kAppIntroIdentifier = @"AppCellIdentifier";
  CHAppIntroItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kAppIntroIdentifier];
  
  [cell configuration:self.mockModel[indexPath.row % 3]];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 400.f;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  CHAppIntroItemCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
  [cell userSelectAppIntroCell];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  CHAppIntroItemCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
  [cell userDeselectedAppIntroCell];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  CHAppIntroItemCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
  self.selectFrame = [cell convertRect:cell.mockViewFrame toView:self.view];
  self.selectView = cell.mockView;
  [self gotoDetailApplicationIntroPage];
}
#pragma mark - UIViewControllerTransitioningDelegate

//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
//  return nil;
//}
//
//- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
//
//  return nil;
//}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
  return [[CHAppStoreTransition alloc] init];
}

- (CGRect)position {
  return self.selectFrame;
}

- (UITextView *)textView {
  return nil;
}

- (UIView *)appIntroView {
  return self.selectView;
}


#pragma mark - NSCopying

#pragma mark - NSObject

#pragma mark - Custom Accessors


@end
