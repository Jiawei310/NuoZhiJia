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
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)showViewInView:(UIView *)view {
    [view addSubview:self.backView];
    [view addSubview:self];
    self.center = view.center;


    [self.tableView reloadData];
}

- (void)hideView {
    [self.backView removeFromSuperview];
    [self removeFromSuperview];
    
}

-(void)handletapPressGestures:(UITapGestureRecognizer*)sender
{
    [self hideView];
}


//- (void)selectBtnAction:(UIButton *)btn {
//    self.selector = btn.tag - 10;
//}

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
    return 30;
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 30, 12.5, 15,15)];
        imageView.tag = 10;
        [cell.contentView addSubview:imageView];
    }
    UIImageView *imageView = [cell.contentView viewWithTag:10];
    if (self.selector == indexPath.row) {
        imageView.image = [UIImage imageNamed:@"selected"];
    } else {
        imageView.image = [UIImage imageNamed:@"unselected"];
    }
    cell.textLabel.text = self.items[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selector = indexPath.row;
    [self.tableView reloadData];
    
    if (self.selectViewBlock) {
        self.selectViewBlock(indexPath.row);
    }
    
    
    //    if ([self.delegate respondsToSelector:@selector(selectIndex:)]) {
    //        [self.delegate selectIndex:self.selector];
    //    }
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
        _tableView = [[UITableView alloc] init];
        [_tableView.layer setCornerRadius:10.0];
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
