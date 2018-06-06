//
//  DataBaseOpration.m
//  iHappySleep
//
//  Created by 诺之家 on 15/10/9.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "DataBaseOpration.h"

@implementation DataBaseOpration
{
    NSArray *arr;
}

//初始化对象
- (id)init
{
    if (self)
    {
        self = [super init];
    }
    [self dataBaseInitialize];
    
    return self;
}

//获得数据库文件的沙盒路径
- (NSString *)getDatabasePath
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"iHappySleep" ofType:@"db"];
    
    NSString *sandBoxPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dataBaseFileName = [sandBoxPath stringByAppendingString:@"/iHappySleep.db"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:dataBaseFileName] != YES)
    {
        [fileManager copyItemAtPath:path toPath:dataBaseFileName error:nil];
    }
    
    return dataBaseFileName;
}

//数据库初始化
- (void)dataBaseInitialize
{
    NSString *dbPath = [self getDatabasePath];
    _db = [FMDatabase databaseWithPath:dbPath];
    if ([_db open])
    {
        _isOpen = YES;
        NSLog(@"打开数据库成功！");
        [self createTreatmentTable];
        [self createFragmentTable];
        [self createMusicTable];
        [self updatePatientTable];
    }
}

//创建新表
- (void)createNewTable:(NSString *)sentence name:(NSString *)tableName
{
    if (_isOpen)
    {
        // 根据请求参数查询数据
        FMResultSet *resultSet = nil;
        
        _tableNameArray = [NSMutableArray array];
        resultSet = [_db executeQuery:@"SELECT * FROM sqlite_master where type='table';"];
        // 遍历table的查询结果
        while (resultSet.next)
        {
            NSString *str1 = [resultSet stringForColumnIndex:1];
            [_tableNameArray addObject:str1];
        }
        
        if ([_tableNameArray containsObject:tableName])
        {
            NSLog(@"表已存在！");
        }
        else
        {
            if ([_db executeUpdate:sentence])
            {
                NSLog(@"%@创建表成功",tableName);
            }
            else
            {
                NSLog(@"%@创建表失败",tableName);
            }
        }
    }
}

//创建tbl_Treatment表
- (void)createTreatmentTable
{
    NSString *sentenceStr = @"CREATE TABLE tbl_Treatment (ID integer primary key autoincrement not null, PatientID text not null, TreatmentID text not null, StartDate text not null, EndDate text not null, GetUpTime text not null, TreatTimeOne text not null, TreatTimeTwo text not null, GoToBedTime text not null);";
    [self createNewTable:sentenceStr name:@"tbl_Treatment"];
}

//创建tbl_Fragment表
- (void)createFragmentTable
{
    NSString *sentenceStr = @"CREATE TABLE tbl_Fragment (ID integer primary key autoincrement not null, PatientID text not null, CollectDate text not null, SleepDifficult text not null, EasyWakeUp text not null, NightUp text not null, BreathDifficult text not null, Snore text not null, Cold text not null, Hot text not null, BadDream text not null, Pain text not null, Other text not null);";
    [self createNewTable:sentenceStr name:@"tbl_Fragment"];
}

//创建tbl_Music表
- (void)createMusicTable
{
    NSString *sentenceStr = @"CREATE TABLE tbl_Music (ID integer primary key autoincrement not null, Num text, State text, Name text not null, MusicUrl text not null, BtnBgUrlGray text not null, BtnBgUrlColour text not null, BtnBgUrlWhite text not null, PlayBgBottom text not null, PlayBgTop text not null, UpdateDate text not null, Visible text not null);";
    [self createNewTable:sentenceStr name:@"tbl_Music"];
}

//更新tbl_Patient表（调价PhotoUrl字段）
- (void)updatePatientTable
{
    if (![_db columnExists:@"PhotoUrl" inTableWithName:@"tbl_Patient"])
    {
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text", @"tbl_Patient", @"PhotoUrl"];
        if([_db executeUpdate:alertStr])
        {
            NSLog(@"tbl_Patient表更新成功");
        }
        else
        {
            NSLog(@"tbl_Patient表更新失败");
        }
    }
    
    if (![_db columnExists:@"Point" inTableWithName:@"tbl_Patient"])
    {
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text", @"tbl_Patient", @"Point"];
        if([_db executeUpdate:alertStr])
        {
            NSLog(@"tbl_Patient表更新成功");
        }
        else
        {
            NSLog(@"tbl_Patient表更新失败");
        }
    }
}

//关闭数据库
- (void)closeDataBase
{
    if ([_db close])
    {
        NSLog(@"关闭数据库成功！");
    }
}

//从数据库中读取用户信息表tbl_Patient的数据
- (NSMutableArray *)getPatientDataFromDataBase
{
    _dataArray = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from tbl_Patient"];
    FMResultSet * rs = [_db executeQuery:sql];
    while ([rs next])
    {
        PatientInfo *patientInfo = [PatientInfo shareInstance];
        patientInfo.PatientID = [rs stringForColumn:@"PatientID"];
        patientInfo.PatientPwd = [rs stringForColumn:@"PatientPwd"];
        patientInfo.PatientName = [rs stringForColumn:@"PatientName"];
        patientInfo.PatientSex = [rs stringForColumn:@"PatientSex"];
        patientInfo.CellPhone = [rs stringForColumn:@"CellPhone"];
        patientInfo.Birthday = [rs stringForColumn:@"Birthday"];
        patientInfo.Age = [rs intForColumn:@"Age"];;
        patientInfo.Marriage = [rs stringForColumn:@"Marriage"];
        patientInfo.NativePlace = [rs stringForColumn:@"NativePlace"];
        patientInfo.BloodModel = [rs stringForColumn:@"BloodModel"];
        patientInfo.PatientContactWay = [rs stringForColumn:@"PatientContactWay"];
        patientInfo.FamilyPhone = [rs stringForColumn:@"FamilyPhone"];
        patientInfo.Email = [rs stringForColumn:@"Email"];
        patientInfo.Vocation = [rs stringForColumn:@"Vocation"];
        patientInfo.Address = [rs stringForColumn:@"Address"];
        patientInfo.PatientHeight = [rs stringForColumn:@"PatientHeight"];
        patientInfo.PatientWeight = [rs stringForColumn:@"PatientWeight"];
        patientInfo.PatientRemarks = [rs stringForColumn:@"PatientRemarks"];
        patientInfo.Picture = [rs stringForColumn:@"Picture"];
        patientInfo.PhotoUrl = [rs stringForColumn:@"PhotoUrl"];
        
        [_dataArray addObject:patientInfo];
    }
    return _dataArray;
}

//从数据库中读取治疗数据表tbl_Treat的数据
- (NSMutableArray *)getTreatDataFromDataBase
{
    _dataArray = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from tbl_Treat"];
    FMResultSet * rs = [_db executeQuery:sql];
    while ([rs next])
    {
        TreatInfo *treatInfo = [TreatInfo new];
        
        treatInfo.PatientID = [rs stringForColumn:@"PatientID"];
        treatInfo.Date = [rs stringForColumn:@"Date"];
        treatInfo.Strength = [rs stringForColumn:@"Strength"];
        treatInfo.Frequency = [rs stringForColumn:@"Frequency"];
        treatInfo.Time = [rs stringForColumn:@"Time"];
        treatInfo.BeginTime = [rs stringForColumn:@"BeginTime"];
        treatInfo.EndTime = [rs stringForColumn:@"EndTime"];
        treatInfo.CureTime = [rs stringForColumn:@"CureTime"];
        
        [_dataArray addObject:treatInfo];
    }
    return _dataArray;
}

//从数据库中读取评估数据表tbl_Evaluate的数据
- (NSMutableArray *)getEvaluateDataFromDataBase
{
    _dataArray = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from tbl_Evaluate"];
    FMResultSet * rs = [_db executeQuery:sql];
    while ([rs next])
    {
        EvaluateInfo *evaluateInfo = [EvaluateInfo new];
        
        evaluateInfo.PatientID = [rs stringForColumn:@"PatientID"];
        evaluateInfo.ListFlag = [rs stringForColumn:@"ListFlag"];
        evaluateInfo.Date = [rs stringForColumn:@"Date"];
        evaluateInfo.Time = [rs stringForColumn:@"Time"];
        evaluateInfo.Score = [rs stringForColumn:@"Score"];
        evaluateInfo.Quality = [rs stringForColumn:@"Quality"];
        evaluateInfo.AdviceFreq = [rs stringForColumn:@"AdviceFreq"];
        evaluateInfo.AdviceTime = [rs stringForColumn:@"AdviceTime"];
        evaluateInfo.AdviceStrength = [rs stringForColumn:@"AdviceStrength"];
        evaluateInfo.AdviceNum = [rs stringForColumn:@"AdviceNum"];
        
        [_dataArray addObject:evaluateInfo];
    }
    return _dataArray;
}
//从数据库中读取蓝牙外射表tbl_Bluetooth的数据
- (NSMutableArray *)getBluetoothDataFromDataBase
{
    _dataArray = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from tbl_Bluetooth"];
    FMResultSet * rs = [_db executeQuery:sql];
    while ([rs next])
    {
        BluetoothInfo *bluetoothInfo = [[BluetoothInfo alloc] init];
        
        bluetoothInfo.saveId = [rs stringForColumn:@"saveId"];
        bluetoothInfo.peripheralIdentify = [rs stringForColumn:@"peripheralIdentify"];
        bluetoothInfo.deviceName = [rs stringForColumn:@"deviceName"];
        bluetoothInfo.deviceCode = [rs stringForColumn:@"deviceCode"];
        bluetoothInfo.deviceElectric = [rs stringForColumn:@"deviceElectric"];
        
        [_dataArray addObject:bluetoothInfo];
    }
    return _dataArray;
}

//从数据库中读取疗程表tbl_Treatment的数据
- (NSMutableArray *)getTreatmentDataFromDataBase
{
    _dataArray = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from tbl_Treatment"];
    FMResultSet * rs = [_db executeQuery:sql];
    while ([rs next])
    {
        TreatmentInfo *treatmentInfo = [[TreatmentInfo alloc] init];
        
        treatmentInfo.PatientID = [rs stringForColumn:@"PatientID"];
        treatmentInfo.TreatmentID = [rs stringForColumn:@"TreatmentID"];
        treatmentInfo.StartDate = [rs stringForColumn:@"StartDate"];
        treatmentInfo.EndDate = [rs stringForColumn:@"EndDate"];
        treatmentInfo.GetUpTime = [rs stringForColumn:@"GetUpTime"];
        treatmentInfo.TreatTimeOne = [rs stringForColumn:@"TreatTimeOne"];
        treatmentInfo.TreatTimeTwo = [rs stringForColumn:@"TreatTimeTwo"];
        treatmentInfo.GoToBedTime = [rs stringForColumn:@"GoToBedTime"];
        
        [_dataArray addObject:treatmentInfo];
    }
    return _dataArray;
}

//从数据库中读取碎片化表tbl_Fragment的数据
- (NSMutableArray *)getFragmentDataFromDataBase
{
    _dataArray = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from tbl_Fragment"];
    FMResultSet * rs = [_db executeQuery:sql];
    while ([rs next])
    {
        FragmentInfo *fragmentInfo = [[FragmentInfo alloc] init];
        
        fragmentInfo.PatientID = [rs stringForColumn:@"PatientID"];
        fragmentInfo.CollectDate = [rs stringForColumn:@"CollectDate"];
        fragmentInfo.SleepDifficult = [rs stringForColumn:@"SleepDifficult"];
        fragmentInfo.EasyWakeUp = [rs stringForColumn:@"EasyWakeUp"];
        fragmentInfo.NightUp = [rs stringForColumn:@"NightUp"];
        fragmentInfo.BreathDifficult = [rs stringForColumn:@"BreathDifficult"];
        fragmentInfo.Snore = [rs stringForColumn:@"Snore"];
        fragmentInfo.Cold = [rs stringForColumn:@"Cold"];
        fragmentInfo.Hot = [rs stringForColumn:@"Hot"];
        fragmentInfo.BadDream = [rs stringForColumn:@"BadDream"];
        fragmentInfo.Pain = [rs stringForColumn:@"Pain"];
        fragmentInfo.Other = [rs stringForColumn:@"Other"];
        
        [_dataArray addObject:fragmentInfo];
    }
    return _dataArray;
}

//从数据库中读取碎片化表tbl_Music的数据
- (NSMutableArray *)getMusicDataFromDataBase
{
    _dataArray = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from tbl_Music"];
    FMResultSet * rs = [_db executeQuery:sql];
    while ([rs next])
    {
        MusicModel *musicInfo = [[MusicModel alloc] init];
        
        musicInfo.musicID = [rs stringForColumn:@"Num"];
        musicInfo.state = [rs stringForColumn:@"State"];
        musicInfo.musicName = [rs stringForColumn:@"Name"];
        musicInfo.musicUrl = [rs stringForColumn:@"MusicUrl"];
        musicInfo.btnBgUrl_Gray = [rs stringForColumn:@"BtnBgUrlGray"];
        musicInfo.btnBgUrl_Colour = [rs stringForColumn:@"BtnBgUrlColour"];
        musicInfo.btnBgUrl_White = [rs stringForColumn:@"BtnBgUrlWhite"];
        musicInfo.playBgBottom = [rs stringForColumn:@"PlayBgBottom"];
        musicInfo.playBgTop = [rs stringForColumn:@"PlayBgTop"];
        musicInfo.updateDate = [rs stringForColumn:@"UpdateDate"];
        musicInfo.visible = [rs stringForColumn:@"Visible"];
        
        [_dataArray addObject:musicInfo];
    }
    return _dataArray;
}

/**********(对表tbl_Patient进行操作)**********/
//数据库插入数据，添加数据 insert into tbl_Patient ('PatientID','PatientPwd','PatientName','PatientSex','CellPhone','Birthday','PatientContactWay','FamilyPhone','Email','PatientRemarks','Picture','PhotoUrl') VALUES('qq_DE1560E75615F04224672EC890B133CD','123456','Trouble Maker','男','','(null)','(null)','(null)','(null)','(null)','(null)','(null)')
- (void)insertUserInfo:(PatientInfo *)patientInfo
{
    if (patientInfo.PatientSex == nil)
    {
        patientInfo.PatientSex = @"";
    }
    if (patientInfo.CellPhone == nil)
    {
        patientInfo.CellPhone = @"";
    }
    if (patientInfo.Birthday == nil)
    {
        patientInfo.Birthday = @"";
    }
    if (patientInfo.PatientContactWay == nil)
    {
        patientInfo.PatientContactWay = @"";
    }
    if (patientInfo.FamilyPhone == nil)
    {
        patientInfo.FamilyPhone = @"";
    }
    if (patientInfo.Email == nil)
    {
        patientInfo.Email = @"";
    }
    if (patientInfo.PatientRemarks == nil)
    {
        patientInfo.PatientRemarks = @"";
    }
    if (patientInfo.Picture == nil)
    {
        patientInfo.Picture = @"";
    }
    if (patientInfo.PhotoUrl == nil)
    {
        patientInfo.PhotoUrl = @"";
    }
    NSString *sql = [NSString stringWithFormat:@"insert into tbl_Patient ('PatientID','PatientPwd','PatientName','PatientSex','CellPhone','Birthday','PatientContactWay','FamilyPhone','Email','Address','PatientRemarks','Picture','PhotoUrl','Point') VALUES('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','')",patientInfo.PatientID,patientInfo.PatientPwd,patientInfo.PatientName,patientInfo.PatientSex,patientInfo.CellPhone,patientInfo.Birthday,patientInfo.PatientContactWay,patientInfo.FamilyPhone,patientInfo.Email,patientInfo.Address,patientInfo.PatientRemarks,patientInfo.Picture,patientInfo.PhotoUrl];
    NSLog(@"%@",sql);
    if ([_db executeUpdate:sql])
    {
        NSLog(@"插入成功！");
    }
    else
    {
        NSLog(@"插入失败！");
    }
}
//更新数据操作
-(void)updataUserInfo:(PatientInfo *)patientInfo
{
    NSString *sql = [NSString stringWithFormat:@"delete from tbl_Patient"];
    if ([_db executeUpdate:sql])
    {
        NSLog(@"删除成功！");
        [self insertUserInfo:patientInfo];
    }
    else
    {
        NSLog(@"删除失败！");
    }

//     NSString *sql = [NSString stringWithFormat:@"update tbl_Patient set 'PatientPwd'='%@','PatientName'='%@','PatientSex'='%@','CellPhone'='%@','Birthday'='%@','PatientContactWay'='%@','FamilyPhone'='%@','Email'='%@','Address'='%@','PatientRemarks'='%@','Picture'='%@','PhotoUrl'='%@' where PatientID='%@'",patientInfo.PatientPwd,patientInfo.PatientName,patientInfo.PatientSex,patientInfo.CellPhone,patientInfo.Birthday,patientInfo.PatientContactWay,patientInfo.FamilyPhone,patientInfo.Email,patientInfo.Address,patientInfo.PatientRemarks,patientInfo.Picture,patientInfo.PhotoUrl,patientInfo.PatientID];
//    NSLog(@"%@",sql);
//    if ([_db executeUpdate:sql])
//    {
//        NSLog(@"更新成功！");
//    }
//    else
//    {
//        NSLog(@"更新失败！");
//    }
}

/**********(对表tbl_TREAT进行操作)**********/
//数据库插入数据，添加数据
-(void)insertTreatInfo:(TreatInfo *)treatInfo
{
    NSString *sql = [NSString stringWithFormat:@"insert into tbl_Treat ('PatientID','Date','Strength','Frequency','Time','BeginTime','EndTime','CureTime') VALUES('%@','%@','%@','%@','%@','%@','%@',%@)",treatInfo.PatientID,treatInfo.Date,treatInfo.Strength,treatInfo.Frequency,treatInfo.Time,treatInfo.BeginTime,treatInfo.EndTime,treatInfo.CureTime];
    NSLog(@"%@",sql);
    if ([_db executeUpdate:sql])
    {
        NSLog(@"插入成功！");
    }
    else
    {
        NSLog(@"插入失败！");
    }
}
//数据库插入数据，添加数据
-(void)insertTreatInfoAll:(NSMutableArray *)treatInfoArray
{
    [_db beginTransaction];
    @try {
        TreatInfo *treatInfo;
        for (int i = 0; i < treatInfoArray.count; i++)
        {
            treatInfo = [treatInfoArray objectAtIndex:i];
            NSString *sql=[NSString stringWithFormat:@"insert into tbl_Treat ('PatientID','Date','Strength','Frequency','Time','BeginTime','EndTime','CureTime') VALUES('%@','%@','%@','%@','%@','%@','%@',%@)",treatInfo.PatientID,treatInfo.Date,treatInfo.Strength,treatInfo.Frequency,treatInfo.Time,treatInfo.BeginTime,treatInfo.EndTime,treatInfo.CureTime];
            if ([_db executeUpdate:sql])
            {
                NSLog(@"插入成功！");
            }
            else
            {
                NSLog(@"插入失败！");
            }
        }
    }
    @catch (NSException *exception) {
        [_db rollback];
    }
    @finally {
        [_db commit];
    }
}

//更新数据操作
-(void)updateTreatInfo:(TreatInfo *)treatInfo
{
    NSString *sql = [NSString stringWithFormat:@"update tbl_Treat set 'Strength'='%@','Frequency'='%@','Time'='%@','EndTime'='%@','CureTime'='%@' where PatientID='%@' and BeginTime='%@'",treatInfo.Strength,treatInfo.Frequency,treatInfo.Time,treatInfo.EndTime,treatInfo.CureTime,treatInfo.PatientID,treatInfo.BeginTime];
     NSLog(@"%@",sql);
    if ([_db executeUpdate:sql])
    {
        NSLog(@"更新成功！");
    }
    else
    {
        NSLog(@"更新失败！");
    }
}

/**********(对表tbl_Evaluate进行操作)**********/
//数据库插入数据，添加数据
-(void)insertEvaluateInfo:(EvaluateInfo *)evaluateInfo
{
    NSString *sql = [NSString stringWithFormat:@"insert into tbl_Evaluate ('PatientID','ListFlag','Date','Time','Score','Quality') VALUES('%@','%@','%@','%@','%@','%@')",evaluateInfo.PatientID,evaluateInfo.ListFlag,evaluateInfo.Date,evaluateInfo.Time,evaluateInfo.Score,evaluateInfo.Quality];
    if ([_db executeUpdate:sql])
    {
        NSLog(@"插入成功！");
    }
    else
    {
        NSLog(@"插入失败！");
    }
}
//更新数据操作
-(void)updateEvaluateInfo:(EvaluateInfo *)evaluateInfo
{
    NSString *sql = [NSString stringWithFormat:@"update tbl_Evaluate set 'Time'='%@','Score'='%@','Quality'='%@' where ListFlag='%@' and Date='%@' and PatientID='%@'",evaluateInfo.Time,evaluateInfo.Score,evaluateInfo.Quality,evaluateInfo.ListFlag,evaluateInfo.Date,evaluateInfo.PatientID];
    NSLog(@"%@",sql);
    if ([_db executeUpdate:sql])
    {
        NSLog(@"更新成功！");
        arr=[self getEvaluateDataFromDataBase];
    }
    else
    {
        NSLog(@"更新失败！");
    }
}

-(void)deleteEvaluateInfo
{
    NSString *sql = [NSString stringWithFormat:@"delete from tbl_Evaluate where PatientID='13122359761'"];
    if ([_db executeUpdate:sql])
    {
        NSLog(@"删除成功！");
    }
    else
    {
        NSLog(@"删除失败！");
    }
}

/**********(对表tbl_Bluetooth进行操作)**********/
//数据库插入数据，添加数据
-(void)insertPeripheralInfo:(BluetoothInfo *)bluetoothInfo
{
    NSString *sql = [NSString stringWithFormat:@"insert into tbl_Bluetooth ('saveId','peripheralIdentify','deviceName','deviceCode','deviceElectric') VALUES('1','%@','%@','%@','%@')",bluetoothInfo.peripheralIdentify,bluetoothInfo.deviceName,bluetoothInfo.deviceCode,bluetoothInfo.deviceElectric];
    NSLog(@"%@",sql);
    if ([_db executeUpdate:sql])
    {
        NSLog(@"插入成功！");
    }
    else
    {
        NSLog(@"插入失败！");
    }
}
//更新数据操作
-(void)updatePeripheralInfo:(BluetoothInfo *)bluetoothInfo
{
    NSString *sql = [NSString stringWithFormat:@"update tbl_Bluetooth set 'peripheralIdentify'='%@','deviceName'='%@','deviceCode'='%@','deviceElectric'='%@' where saveId='1'",bluetoothInfo.peripheralIdentify,bluetoothInfo.deviceName,bluetoothInfo.deviceCode,bluetoothInfo.deviceElectric];
    NSLog(@"%@",sql);
    if ([_db executeUpdate:sql])
    {
        NSLog(@"更新成功！");
    }
    else
    {
        NSLog(@"更新失败！");
    }
}
//删除数据操作
-(void)deletePeripheralInfo
{
    NSString *sql = [NSString stringWithFormat:@"delete from tbl_Bluetooth where saveId='1'"];
    if ([_db executeUpdate:sql])
    {
        NSLog(@"删除成功！");
    }
    else
    {
        NSLog(@"删除失败！");
    }
}

/**********(对表tbl_Treatment进行操作)**********/
//数据库插入数据，添加数据
-(void)insertTreatmentInfo:(TreatmentInfo *)treatmentInfo
{
    NSString *sql = [NSString stringWithFormat:@"insert into tbl_Treatment ('PatientID','TreatmentID','StartDate','EndDate','GetUpTime','TreatTimeOne','TreatTimeTwo','GoToBedTime') VALUES('%@','%@','%@','%@','%@','%@','%@','%@')",treatmentInfo.PatientID,treatmentInfo.TreatmentID,treatmentInfo.StartDate,treatmentInfo.EndDate,treatmentInfo.GetUpTime,treatmentInfo.TreatTimeOne,treatmentInfo.TreatTimeTwo,treatmentInfo.GoToBedTime];
    NSLog(@"%@",sql);
    if ([_db executeUpdate:sql])
    {
        NSLog(@"插入成功！");
    }
    else
    {
        NSLog(@"插入失败！");
    }
}
//更新数据操作
-(void)updateTreatmentInfo:(TreatmentInfo *)treatmentInfo
{
    NSString *sql = [NSString stringWithFormat:@"update tbl_Treatment set 'StartDate'='%@','EndDate'='%@','GetUpTime'='%@','TreatTimeOne'='%@','TreatTimeTwo'='%@','GoToBedTime'='%@' where PatientID='%@' and TreatmentID='%@'",treatmentInfo.StartDate,treatmentInfo.EndDate,treatmentInfo.GetUpTime,treatmentInfo.TreatTimeOne,treatmentInfo.TreatTimeTwo,treatmentInfo.GoToBedTime,treatmentInfo.PatientID,treatmentInfo.TreatmentID];
    NSLog(@"%@",sql);
    if ([_db executeUpdate:sql])
    {
        NSLog(@"更新成功！");
    }
    else
    {
        NSLog(@"更新失败！");
    }
}
//删除数据操作
-(void)deleteTreatmentInfo
{
    NSString *sql = [NSString stringWithFormat:@"delete from tbl_Treatment"];
    if ([_db executeUpdate:sql])
    {
        NSLog(@"删除成功！");
    }
    else
    {
        NSLog(@"删除失败！");
    }
}

/**********(对表tbl_Fragment进行操作)**********/
//数据库插入数据，添加数据
-(void)insertFragmentInfo:(FragmentInfo *)fragmentInfo
{
    NSString *sql = [NSString stringWithFormat:@"insert into tbl_Fragment ('PatientID','CollectDate','SleepDifficult','EasyWakeUp','NightUp','BreathDifficult','Snore','Cold','Hot','BadDream','Pain','Other') VALUES('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",fragmentInfo.PatientID,fragmentInfo.CollectDate,fragmentInfo.SleepDifficult,fragmentInfo.EasyWakeUp,fragmentInfo.NightUp,fragmentInfo.BreathDifficult,fragmentInfo.Snore,fragmentInfo.Cold,fragmentInfo.Hot,fragmentInfo.BadDream,fragmentInfo.Pain,fragmentInfo.Other];
    NSLog(@"%@",sql);
    if ([_db executeUpdate:sql])
    {
        NSLog(@"插入成功！");
    }
    else
    {
        NSLog(@"插入失败！");
    }
}
//删除数据操作
-(void)deleteFragmentInfo
{
    NSString *sql = [NSString stringWithFormat:@"delete from tbl_Fragment"];
    if ([_db executeUpdate:sql])
    {
        NSLog(@"删除成功！");
    }
    else
    {
        NSLog(@"删除失败！");
    }
}

/**********(对表tbl_Music进行操作)**********/
//数据库插入数据，添加数据
-(void)insertMusicInfo:(MusicModel *)musicInfo
{
    NSString *sql = [NSString stringWithFormat:@"insert into tbl_Music ('Num','State','Name','MusicUrl','BtnBgUrlGray','BtnBgUrlColour','BtnBgUrlWhite','PlayBgBottom','PlayBgTop','UpdateDate','Visible') VALUES('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",musicInfo.musicID, musicInfo.state, musicInfo.musicName, musicInfo.musicUrl, musicInfo.btnBgUrl_Gray, musicInfo.btnBgUrl_Colour, musicInfo.btnBgUrl_White, musicInfo.playBgBottom, musicInfo.playBgTop, musicInfo.updateDate, musicInfo.visible];
    NSLog(@"%@",sql);
    if ([_db executeUpdate:sql])
    {
        NSLog(@"插入成功！");
    }
    else
    {
        NSLog(@"插入失败！");
    }
}
//修改数据操作
- (void)updateMusicInfo:(MusicModel *)musicInfo
{
    NSString *sql = [NSString stringWithFormat:@"update tbl_Music set 'State'='%@','Name'='%@','MusicUrl'='%@','BtnBgUrlGray'='%@','BtnBgUrlColour'='%@','BtnBgUrlWhite'='%@','PlayBgBottom'='%@','PlayBgTop'='%@','UpdateDate'='%@','Visible'='%@' where Num ='%@'", musicInfo.state, musicInfo.musicName, musicInfo.musicUrl, musicInfo.btnBgUrl_Gray, musicInfo.btnBgUrl_Colour, musicInfo.btnBgUrl_White, musicInfo.playBgBottom, musicInfo.playBgTop, musicInfo.updateDate,musicInfo.visible,musicInfo.musicID];
    NSLog(@"%@",sql);
    if ([_db executeUpdate:sql])
    {
        NSLog(@"更新成功！");
    }
    else
    {
        NSLog(@"更新失败！");
    }
}
//删除数据操作
-(void)deleteMusicInfo:(MusicModel *)musicInfo
{
    NSString *sql = [NSString stringWithFormat:@"delete from tbl_Fragment where Name = '%@'",musicInfo.musicName];
    if ([_db executeUpdate:sql])
    {
        NSLog(@"删除成功！");
    }
    else
    {
        NSLog(@"删除失败！");
    }
}

@end
