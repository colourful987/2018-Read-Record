//
//  ListViewController.m
//  TransitionWorld
//
//  Created by pmst on 2018/8/27.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "ListViewController.h"
#import "Masonry.h"

static NSString * const kIdentifierOfTableViewCell = @"kIdentifierOfTableViewCell";

@interface ListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong)UITableView *listTableView;
@property(nonatomic, strong)NSArray *items;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self p_initialize];
}

#pragma mark - Private
- (void)p_initialize {
    self.items = @[@"Fade In(淡入)/Fade Out(淡出)",
                   @"Side In(滑入)/Side Out(滑出)",
                   @"Rotate Portrait to Landscape",
                   @"Interactive Side In/Out Ver&Hor",
                   @"Transition Animation Like in the Ping App"];
    self.title = @"Transition Animation World";
    [self.view addSubview:self.listTableView];
    [self.listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Protocol conformance
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifierOfTableViewCell forIndexPath:indexPath];
    
    cell.textLabel.text = _items[indexPath.row];
    
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class sourceVCClass = NSClassFromString([NSString stringWithFormat:@"CHDemo%dSourceViewController",(int)indexPath.row]);
    id controller = [[sourceVCClass alloc] init];
    [self presentViewController:controller animated:YES completion:nil];
}
#pragma mark - Custom Accessors
- (UITableView *)listTableView {
    if (!_listTableView) {
        _listTableView = [[UITableView alloc] init];
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        [_listTableView registerClass:UITableViewCell.class forCellReuseIdentifier:kIdentifierOfTableViewCell];
    }
    return _listTableView;
}

@end
