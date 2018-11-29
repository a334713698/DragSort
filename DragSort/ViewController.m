//
//  ViewController.m
//  DragSort
//
//  Created by quanmai on 2018/11/28.
//  Copyright © 2018年 hongdongjie. All rights reserved.
//

#import "ViewController.h"

#define UIScreenWidth [UIScreen mainScreen].bounds.size.width
#define UIScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *lists;

@end

@implementation ViewController{
    NSIndexPath* _selectIndexPath;
    UIView* _snapShot;
}

#pragma mark - lazy load
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [self.view addSubview:_tableView];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.allowsSelection = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.01, 0.01)];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.01, 10)];
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 11.0) {
            _tableView.estimatedSectionHeaderHeight = 10;
            _tableView.estimatedSectionFooterHeight = 0.01;
        }
        _tableView.frame = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight);
        UILongPressGestureRecognizer* longRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [_tableView addGestureRecognizer:longRec];
    }
    return _tableView;
}

- (NSMutableArray *)lists{
    if (!_lists) {
        _lists = @[@"one",@"two",@"three",@"four",@"five",@"six"].mutableCopy;
    }
    return _lists;
}

#pragma mark - view func
- (void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.hidden = NO;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.lists[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

#pragma mark - SEL
- (void)longPress:(UILongPressGestureRecognizer*)sender{
    UIGestureRecognizerState state = sender.state;
    CGPoint location = [sender locationInView:_tableView];
    switch (state) {
        case UIGestureRecognizerStateBegan:{
            NSLog(@"选中cell");
            _selectIndexPath = [_tableView indexPathForRowAtPoint:location];
            if (!_selectIndexPath) return;
            UITableViewCell* cell = [_tableView cellForRowAtIndexPath:_selectIndexPath];
            _snapShot = [self snapShotForView:cell];
            _snapShot.frame = CGRectMake(0, location.y, _snapShot.bounds.size.width, _snapShot.bounds.size.height);
            [self.view addSubview:_snapShot];
            cell.contentView.hidden = YES;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            NSLog(@"移动cell");
            _snapShot.frame = CGRectMake(0, location.y, _snapShot.bounds.size.width, _snapShot.bounds.size.height);
            NSIndexPath* changeIndexPath = [_tableView indexPathForRowAtPoint:location];
            if (!_selectIndexPath || !changeIndexPath) return;
            if (_selectIndexPath != changeIndexPath) {
                NSLog(@"交换");
                [self.lists exchangeObjectAtIndex:_selectIndexPath.row withObjectAtIndex:changeIndexPath.row];
                //移动Section —— [self.tableView moveSection:0 toSection:0];
                //移动row
                [self.tableView moveRowAtIndexPath:_selectIndexPath toIndexPath:changeIndexPath];
                UITableViewCell* selectCell = [_tableView cellForRowAtIndexPath:_selectIndexPath];
                UITableViewCell* changeCell = [_tableView cellForRowAtIndexPath:changeIndexPath];
                selectCell.contentView.hidden = NO;
                changeCell.contentView.hidden = YES;
                _selectIndexPath = changeIndexPath;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:{
            NSLog(@"放下cell");
            [_snapShot removeFromSuperview];
            _snapShot = nil;
            if (!_selectIndexPath) return;
            UITableViewCell* cell = [_tableView cellForRowAtIndexPath:_selectIndexPath];
            cell.contentView.hidden = NO;
            _selectIndexPath = nil;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Method
- (UIView*)snapShotForView:(UIView*)inputView{
    UIView* snapshot= [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.shadowOffset = CGSizeMake(-3.0, 0.0);
    snapshot.layer.shadowRadius = 6.0;
    snapshot.layer.shadowOpacity = 0.4;
    return snapshot;
}

@end
