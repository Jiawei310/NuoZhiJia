//
//  AppDelegate.m
//  Cervella
//
//  Created by Justin on 2017/6/26.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import "AppDelegate.h"

#import "LoginViewController.h"
#import "HomeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
      PatientInfo *patientInfo;
    BluetoothInfo *bluetoothInfo;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //从NSUserDefaults中获取存储的用户信息
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefault objectForKey:@"PatientID"];
    
    UIViewController *rootVC = nil;
    if (userName.length == 0 || userName == nil)
    {
        //登录 "Main"的storyboard
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *rootView = (LoginViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"loginView"];
        rootVC = rootView;
        
    } else {
        //从数据库读取数据传到主界面（读取NSUserDefaults中的该PatientID用户信息表信息、治疗数据、评估数据以及蓝牙外设，读完数据之后关闭数据库）
        DataBaseOpration *dataBaseOpration = [[DataBaseOpration alloc] init];
        NSArray *bluetoothInfoArray=[dataBaseOpration getBluetoothDataFromDataBase];
        NSArray *patientInfoArray = [dataBaseOpration getPatientDataFromDataBase];
        
        for (PatientInfo *tmp in patientInfoArray)
        {
            if ([tmp.PatientID isEqualToString:userName])
            {
                patientInfo = tmp;
            }
        }
        
        if (bluetoothInfoArray.count>0)
        {
            bluetoothInfo=[bluetoothInfoArray objectAtIndex:0];
        }
        [dataBaseOpration closeDataBase];
        
        //设置HomeViewController为根视图控制器
        HomeViewController *rootView = [[HomeViewController alloc] init];
        rootView.patientInfo = patientInfo;
        rootView.bluetoothInfo = bluetoothInfo;
        rootVC = rootView;
    }
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootVC];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
