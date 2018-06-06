//
//  MeViewController.m
//  Somnormal
//
//  Created by Justin on 2017/6/29.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import "MeViewController.h"

#import "AssessDataViewController.h"
#import "TreatDataViewController.h"
#import "MyInfoViewController.h"

@interface MeViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *meTableView;

@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _meTableView.scrollEnabled =NO; //设置tableview不能滚动
    _meTableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    _meTableView.delegate = self;
    _meTableView.dataSource = self;
}

#pragma loginTableView -- delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma loginTableView -- dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor colorWithRed:0xF4/255.0 green:0xF4/255.0 blue:0xF4/255.0 alpha:1.0];
    if (indexPath.row == 0)
    {
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 30, 30)];
        [headImageView setImage:[UIImage imageNamed:@"more_access"]];
        [cell.contentView addSubview:headImageView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 200, 40)];
        textLabel.text = @"Assessment Data";
        textLabel.font = [UIFont systemFontOfSize:20];
        [cell.contentView addSubview:textLabel];
    }
    else if (indexPath.row == 1)
    {
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 10, 34, 30)];
        [headImageView setImage:[UIImage imageNamed:@"more_cure"]];
        [cell.contentView addSubview:headImageView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 200, 40)];
        textLabel.text = @"Treatment Data";
        textLabel.font = [UIFont systemFontOfSize:20];
        [cell.contentView addSubview:textLabel];
    }
    else if (indexPath.row == 2)
    {
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 30, 30)];
        [headImageView setImage:[UIImage imageNamed:@"more_basic"]];
        [cell.contentView addSubview:headImageView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 200, 40)];
        textLabel.text = @"My Information";
        textLabel.font = [UIFont systemFontOfSize:20];
        [cell.contentView addSubview:textLabel];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0)
    {
        AssessDataViewController *assessDataVC = [[AssessDataViewController alloc] init];
        assessDataVC.patientInfo = _patientInfo;
        
        [self.navigationController pushViewController:assessDataVC animated:YES];
    }
    else if (indexPath.row == 1)
    {
        TreatDataViewController *treatDataVC = [[TreatDataViewController alloc] init];
        treatDataVC.patientInfo = _patientInfo;
        
        [self.navigationController pushViewController:treatDataVC animated:YES];
    }
    else if (indexPath.row == 2)
    {
        MyInfoViewController *myInfoVC = [[MyInfoViewController alloc] init];
        myInfoVC.patientInfo = _patientInfo;
        
        [self.navigationController pushViewController:myInfoVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
