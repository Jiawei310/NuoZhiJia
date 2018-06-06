//
//  DataBaseOpration.h
//  iHappySleep
//
//  Created by 诺之家 on 15/10/9.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDB.h"

#import "TreatInfo.h"
#import "EvaluateInfo.h"
#import "BluetoothInfo.h"
#import "TreatmentInfo.h"
#import "FragmentInfo.h"
#import "MusicModel.h"

@interface DataBaseOpration : NSObject

@property (nonatomic, strong)   FMDatabase *db;
@property (nonatomic, assign)         BOOL  isOpen;
@property (nonatomic, copy) NSMutableArray *tableNameArray;

@property NSMutableArray *dataArray;//存储从数据库中取出的数据

- (id)init;
//用户信息的插入以及更新
- (void)insertUserInfo:(PatientInfo *)patientInfo;
- (void)updataUserInfo:(PatientInfo *)patientInfo;
//治疗数据的插入以及更新
- (void)insertTreatInfo:(TreatInfo *)treatInfo;
- (void)insertTreatInfoAll:(NSMutableArray *)treatInfoArray;
- (void)updateTreatInfo:(TreatInfo *)treatInfo;
//评估数据的插入以及更新
- (void)insertEvaluateInfo:(EvaluateInfo *)evaluateInfo;
- (void)updateEvaluateInfo:(EvaluateInfo *)evaluateInfo;
- (void)deleteEvaluateInfo;
//蓝牙外设的插入、更新以及删除
- (void)insertPeripheralInfo:(BluetoothInfo *)bluetoothInfo;
- (void)updatePeripheralInfo:(BluetoothInfo *)bluetoothInfo;
- (void)deletePeripheralInfo;
//疗程的插入、更新
- (void)insertTreatmentInfo:(TreatmentInfo *)treatmentInfo;
- (void)updateTreatmentInfo:(TreatmentInfo *)treatmentInfo;
//碎片化的插入
- (void)insertFragmentInfo:(FragmentInfo *)fragmentInfo;
//音乐的插入、修改、删除
- (void)insertMusicInfo:(MusicModel *)musicInfo;
- (void)updateMusicInfo:(MusicModel *)musicInfo;
- (void)deleteMusicInfo:(MusicModel *)musicInfo;

//取得用户信息表中的全部数据
- (NSMutableArray *)getPatientDataFromDataBase;
//取得治疗数据表中的全部数据
- (NSMutableArray *)getTreatDataFromDataBase;
//取得评估数据表中的全部数据
- (NSMutableArray *)getEvaluateDataFromDataBase;
//取得蓝牙外设表中的全部数据
- (NSMutableArray *)getBluetoothDataFromDataBase;
//取得疗程表中的全部数据
- (NSMutableArray *)getTreatmentDataFromDataBase;
//取得碎片化表中的全部数据
- (NSMutableArray *)getFragmentDataFromDataBase;
//取得阴雨人表中的全部数据
- (NSMutableArray *)getMusicDataFromDataBase;

-(void)closeDataBase;

@end
