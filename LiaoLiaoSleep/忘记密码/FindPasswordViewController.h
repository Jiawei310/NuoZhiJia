//
//  FindPasswordViewController.h
//  SleepExpert
//
//  Created by 诺之家 on 16/6/21.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindPasswordViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property NSString *PatientID;

@property (strong,nonatomic)   NSMutableData *webData;
@property (strong,nonatomic) NSMutableString *soapResults;
@property (strong,nonatomic)     NSXMLParser *xmlParser;
@property (nonatomic)                   BOOL elementFound;
@property (strong,nonatomic)        NSString *matchingElement;
@property (strong,nonatomic) NSURLConnection *conn;

@end
