//
//  DataTableView.h
//  LiaoLiaoDoctor
//
//  Created by 诺之嘉 on 2017/12/5.
//  Copyright © 2017年 nuozhijia. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    DataTypeNone,
    DataTypeBluetooth,//蓝牙
}DataType;

@protocol DataTableViewDelegate;

@interface DataTableView : UIView
@property (nonatomic, weak)  id <DataTableViewDelegate> delegate;
@property (nonatomic, assign) DataType dataType;
@property (nonatomic, strong) NSArray *dataArr;

- (void)showViewInView:(UIView *)view;
@end

@protocol DataTableViewDelegate <NSObject>

@optional
- (void)dataTableView:(DataTableView *)dataTableView selectRowObject:(id)object;
@end
