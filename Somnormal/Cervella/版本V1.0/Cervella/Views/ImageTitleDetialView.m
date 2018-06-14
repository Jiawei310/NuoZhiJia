//
//  ImageTitleDetialView.m
//  Cervella
//
//  Created by 一磊 on 2018/6/13.
//  Copyright © 2018年 Justin. All rights reserved.
//

#import "ImageTitleDetialView.h"
#import "SelectView.h"

@interface ImageTitleDetialView () <UITableViewDelegate, UITableViewDataSource>
{
    UIView *lineBottomView;

    UITableView *_tableView;
    SelectView *_selectView;
}
@end
@implementation ImageTitleDetialView
- (id)init {
    self = [super init];
    if (self) {
        [self addSubview:self.tableView];
        
        lineBottomView = [[UIView alloc] init];
        lineBottomView.backgroundColor = [UIColor grayColor];
        [self addSubview:lineBottomView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    lineBottomView.frame = CGRectMake(0, self.frame.size.height - 1.0, self.frame.size.width, 1.0);
}

//tableView需要实现的代理方法
#pragma mark - UITableViewDelegate,UITableViewDataSource
//tabeview的代理方法 （如果此方法返回值为0，则后面两个代理方法不执行）
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"ImageTitleDetailTableViewCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGFloat w = tableView.frame.size.width;
        
        UIView *lineTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.5, w, 1.0)];
        lineTopView.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:lineTopView];
    }
    NSDictionary *dict = self.items[indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:dict[@"image"]];
    cell.textLabel.text = dict[@"title"];
    cell.detailTextLabel.text = dict[@"detail"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.items[indexPath.row];
    if ([dict[@"title"] isEqualToString:@"Frequency"]) {
        self.selectView.items = @[@"0.5Hz",@"1.5Hz",@"100Hz"];
        [self.selectView showViewInView:self.superview];
    }
    else if ([dict[@"title"] isEqualToString:@"Time"]) {
        self.selectView.items = @[@"10min",@"20min",@"30min",@"40min",@"50min",@"60min"];

        [self.selectView showViewInView:self.superview];
    }
    
}

//#pragma mark - SelectViewDelegate
//- (void)selectIndex:(NSInteger)index {
//    if ([self.delegate respondsToSelector:@selector(selectIndex:)]) {
//        self.selector = index;
//        [self.delegate selectIndex:index];
//    }
//}

#pragma mark - get

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        [_tableView.layer setCornerRadius:10.0];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (SelectView *)selectView {
    if (!_selectView) {
        _selectView = [[SelectView alloc] init];
        _selectView.titile = @"请选择";
        _selectView.frame = CGRectMake(0, 0, SCREENWIDTH - 60, 150);
        _selectView.center = self.superview.center;
        _selectView.selector = self.selector;
        __weak typeof (*&self) weakSelf = self;
        _selectView.selectViewBlock = ^(NSInteger index) {
            weakSelf.selector = index;
            if (weakSelf.imageTitleDetailViewBlock) {
                weakSelf.imageTitleDetailViewBlock(index);

            }
//            [weakSelf.delegate selectIndex:index];
        };

    }
    return _selectView;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
