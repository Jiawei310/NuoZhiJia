//
//  TreatDataViewController.h
//  Cervella
//
//  Created by Justin on 2017/7/7.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TreatDataViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) PatientInfo *patientInfo;
@property (nonatomic, strong) TreatInfo *treatInfo;

//用来存开始日期年月的数组
@property NSMutableArray *begainDateYearArray;
@property NSMutableArray *begainDateMonthArray;
@property NSMutableArray *begainDateDayArray;
//用来存结束日期年月的数组
@property NSMutableArray *endDateYearArray;
@property NSMutableArray *endDateMonthArray;
@property NSMutableArray *endDateDayArray;
//服务器请求数据
@property (strong,nonatomic) NSMutableData *webData;
@property (strong,nonatomic) NSMutableString *soapResults;
@property (strong,nonatomic) NSXMLParser *xmlParser;
@property (nonatomic) BOOL elementFound;
@property (strong,nonatomic) NSString *matchingElement;
@property (strong,nonatomic) NSURLConnection *conn;

@end
