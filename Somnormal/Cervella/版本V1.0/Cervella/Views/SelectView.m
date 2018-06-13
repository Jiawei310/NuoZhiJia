//
//  SelectView.m
//  Cervella
//
//  Created by 一磊 on 2018/6/13.
//  Copyright © 2018年 Justin. All rights reserved.
//

#import "SelectView.h"
@interface SelectView () <UITableViewDelegate, UITableViewDataSource>
{
    UIView *_backView;
    UITableView *_tableView;
}
@end

@implementation SelectView

- (id)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
        [self addSubview:self.backView];
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)showViewInView:(UIView *)view {
    [view addSubview:self];
    [self.tableView reloadData];
}

- (void)hideView {
    [self removeFromSuperview];
    
}

-(void)handletapPressGestures:(UITapGestureRecognizer*)sender
{
    [self hideView];
}


- (void)selectBtnAction:(UIButton *)btn {
    self.selector = btn.tag - 10;
}

//tableView需要实现的代理方法
#pragma mark - UITableViewDelegate,UITableViewDataSource
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH*4/5, SCREENHEIGHT/20)];
    customView.backgroundColor=[UIColor colorWithRed:0xed/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.textAlignment=NSTextAlignmentCenter;
    headerLabel.frame =CGRectMake(0, 0, SCREENWIDTH*4/5, SCREENHEIGHT/20);
    
    headerLabel.text = self.titile;
    
    [customView addSubview:headerLabel];
    return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SCREENHEIGHT/20;
}

//tabeview的代理方法 （如果此方法返回值为0，则后面两个代理方法不执行）
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"SelectViewTableViewCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        UIButton *selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH*3/5, 0, 30,40)];
        [selectBtn addTarget:self action:@selector(selectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        selectBtn.tag = indexPath.row + 10;
        [cell.contentView addSubview:selectBtn];
    }
    UIButton *selectBtn = [cell.contentView viewWithTag:indexPath.row + 10];
    if (indexPath.row == self.selector)
    {
        [selectBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
    } else {
        [selectBtn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
    }
    cell.textLabel.text = self.items[indexPath.row];
    
    return cell;
    
}

#pragma mark - get
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _backView.backgroundColor=[UIColor colorWithWhite:0.1 alpha:0.5];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressGestures:)];
        [_backView addGestureRecognizer:tapGesture];
    }
    return _backView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREENWIDTH/10, SCREENHEIGHT*3/8, SCREENWIDTH*4/5, (self.items.count)*40 +SCREENHEIGHT/20)];
        [_tableView.layer setCornerRadius:10.0];
        _tableView.backgroundColor=[UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
