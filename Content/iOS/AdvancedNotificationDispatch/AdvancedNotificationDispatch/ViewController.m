//
//  ViewController.m
//  AdvancedNotificationDispatch
//
//  Created by pmst on 2018/11/22.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+Notification_Private.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self observeWithName:@"ClickButton" observer:self selector:@selector(notificationDidReceived:)];
}

- (IBAction)triggerNotification:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClickButton" object:nil userInfo:@{@"triggerVC":@"ViewController2", @"triggerEvent":@"ButtonClick"}];
}

- (void)notificationDidReceived:(NSDictionary *)userInfo {
    NSLog(@"received userInfo:%@",userInfo);
}
@end
