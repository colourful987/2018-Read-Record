//
//  ViewController.m
//  NotificationDispatch
//
//  Created by pmst on 2018/11/21.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "ViewController.h"
#import "NSNotificationCenter+Token.h"

@interface ViewController ()
@property(nonatomic, strong)NotificationToken *token;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.token = [[NSNotificationCenter defaultCenter] observeWithName:@"ClickButton" observer:self selector:@selector(notificationDidReceived:)];
}

- (void)notificationDidReceived:(NSDictionary *)userInfo {
    NSLog(@"received userInfo:%@",userInfo);
}

@end
