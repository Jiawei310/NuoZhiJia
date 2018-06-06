//
//  DataTableView.m
//  LiaoLiaoDoctor
//
//  Created by 诺之嘉 on 2017/12/5.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import "DataTableView.h"
#import "Equipment.h"
@interface DataTableView () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
    
}

@end

@implementation DataTableView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)btnCloseAction{
    [self closeView];
}

- (void)showViewInView:(UIView *)view {
    [view addSubview:self];
    self.hidden = NO;
}

- (void)closeView {
    self.hidden = YES;
    [self removeFromSuperview];
}



#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (_dataType) {
        case DataTypeBluetooth:{
            return 44.0f;
        }
            break;
        default:
            break;
    }
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (_dataType) {
        case DataTypeBluetooth:
            return 44.0f;
        default:
            break;
    }
    return 0;
}

#pragma mark - UITableViewDataSource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (_dataType) {
        case DataTypeBluetooth:
        {
            UIView *headView = [[UIView alloc] init];
            headView.frame = CGRectMake(0, 0, tableView.frame.size.width, 44.0f);
    
            UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
            btnClose.frame = CGRectMake(tableView.frame.size.width - 80.0f, 0.0f, 60.0f, 44.0f);
            [btnClose setTitle:@"关闭" forState: UIControlStateNormal];
            [btnClose setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

            [btnClose addTarget:self action:@selector(btnCloseAction) forControlEvents:UIControlEventTouchUpInside];
            [headView addSubview:btnClose];
            return headView;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    static NSString *cellId;
    
    switch (_dataType) {
        case DataTypeBluetooth:
        {
            cellId = @"DataTypeDoctorCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
            }
            Equipment *equipment = self.dataArr[indexPath.row];
            cell.textLabel.text = equipment.peripheral.name;
            cell.detailTextLabel.text = [equipment.RSSI stringValue];
        }
            break;
        default:
            break;
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(dataTableView:selectRowObject:)]) {
        id object = self.dataArr[indexPath.row];
        [self.delegate dataTableView:self selectRowObject:object];
    }
    switch (_dataType) {
        case DataTypeBluetooth:
        {
            [self closeView];
        }
            break;
        default:
            break;
    }
}

#pragma mark - setter and getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (void)setDataArr:(NSArray *)dataArr {
    _dataArr = dataArr;
    
    [self.tableView reloadData];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
