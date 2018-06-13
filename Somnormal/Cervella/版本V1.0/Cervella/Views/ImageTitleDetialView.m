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
    UITableView *_tableView;
}
@end
@implementation ImageTitleDetialView
- (id)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
        [self addSubview:self.tableView];
    }
    return self;
}

//tableView需要实现的代理方法
#pragma mark - UITableViewDelegate,UITableViewDataSource
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
    }
    
    
    cell.textLabel.text = self.items[indexPath.row];
    
    return cell;
}


#pragma mark - get

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREENWIDTH/10, SCREENHEIGHT*3/8, SCREENWIDTH*4/5, (self.items.count)*40)];
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
