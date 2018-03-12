//
//  ViewController.m
//  Lexical_Analyzer_UI
//
//  Created by pmst on 13/03/2018.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "ViewController.h"
#import "Interpreter.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textfield;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)expr:(id)sender {
    NSString *text = self.textfield.text;
    Interpreter *interpreter = [[Interpreter alloc] initWithText:text];
    NSLog(@"result is %d",[interpreter expr]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
