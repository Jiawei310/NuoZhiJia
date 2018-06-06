//
//  ResultView.h
//  Assessment
//
//  Created by 诺之家 on 16/10/20.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultView : UIView

@property (nonatomic, strong) UIScrollView *resultScrollView;

- (instancetype)initWithScaleData:(NSArray *)resultArray andType:(NSString *)typeStr andPatientInfo:(PatientInfo *)patientInfo andFlag:(NSString *)flagString;

@end
