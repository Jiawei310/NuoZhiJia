//
//  ImageTitleDetialView.m
//  Cervella
//
//  Created by 一磊 on 2018/6/13.
//  Copyright © 2018年 Justin. All rights reserved.
//

#import "ImageTitleDetialView.h"

@interface ImageTitleDetialView () <UITableViewDelegate, UITableViewDataSource>
{
    UIView *lineBottomView;

    UITableView *_tableView;
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
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"ImageTitleDetailTableViewCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imgV = [[UIImageView alloc] init];
        imgV.frame = CGRectMake(0, 10, 40, 40);
        imgV.tag = 10;
        [cell.contentView addSubview:imgV];
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.frame = CGRectMake(52, 0, 100, 60);
        titleLab.font = [UIFont systemFontOfSize:18.0];
        titleLab.tag = 11;
        [cell.contentView addSubview:titleLab];
    }
    NSDictionary *dict = self.items[indexPath.row];
    UIImageView *imgV = [cell.contentView viewWithTag:10];
    imgV.image = [UIImage imageNamed:dict[@"image"]];
    
    UILabel *titleLab = [cell.contentView viewWithTag:11];
    titleLab.text =  dict[@"title"];
    cell.detailTextLabel.text = dict[@"detail"];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:18];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:30/255.0 green:128/255.0 blue:211/255.0 alpha:1.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSDictionary *dict = self.items[indexPath.row];
    if (self.isCanSelect) {
        if (self.imageTitleDetailViewBlock) {
            self.imageTitleDetailViewBlock();
        }
    } else {
        jxt_showTextHUDTitleMessage(@"", @"Parameter cannot be changed during stimulation.Please stop the stimulation first.");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            jxt_dismissHUD();
        });
    }
}

#pragma mark - get

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}
- (void)setItems:(NSArray *)items {
    _items = items;
    [self.tableView reloadData];
}
- (void)setIsCanSelect:(BOOL)isCanSelect {
    _isCanSelect = isCanSelect;
//    self.tableView.allowsSelection = isCanSelect;
}

//- (SelectView *)selectView {
//    if (!_selectView) {
//        _selectView = [[SelectView alloc] init];
//        _selectView.titile = @"请选择";
//        _selectView.frame = CGRectMake(0, 0, SCREENWIDTH - 60, 150);
//        _selectView.center = self.superview.center;
//        _selectView.selector = self.selector;
//        __weak typeof (*&self) weakSelf = self;
//        _selectView.selectViewBlock = ^(NSInteger index) {
//            weakSelf.selector = index;
//            if (weakSelf.imageTitleDetailViewBlock) {
//                weakSelf.imageTitleDetailViewBlock(index);
//            }
////            [weakSelf.delegate selectIndex:index];
//        };
//
//    }
//    return _selectView;
//}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
