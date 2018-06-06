//
//  HomeViewController.h
//  Somnormal
//
//  Created by Justin on 2017/6/28.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PatientInfo.h"

@interface HomeViewController : UIViewController<NSXMLParserDelegate,NSURLConnectionDelegate>

@property (nonatomic, strong)   PatientInfo *patientInfo;
@property (nonatomic, strong) BluetoothInfo *bluetoothInfo;

@property (strong,nonatomic) NSMutableData *webData;
@property (strong,nonatomic) NSMutableString *soapResults;
@property (strong,nonatomic) NSXMLParser *xmlParser;
@property (nonatomic) BOOL elementFound;
@property (strong,nonatomic) NSString *matchingElement;
@property (strong,nonatomic) NSURLConnection *conn;

@end
