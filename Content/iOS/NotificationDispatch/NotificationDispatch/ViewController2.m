//
//  ViewController2.m
//  NotificationDispatch
//
//  Created by pmst on 2018/11/21.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "ViewController2.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)triggerNotification:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClickButton" object:nil userInfo:@{@"triggerVC":@"ViewController2", @"triggerEvent":@"ButtonClick"}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
