//
//  TypeDefine.h
//  Cervella
//
//  Created by Justin on 2017/6/27.
//  Copyright © 2017年 Justin. All rights reserved.
//

#ifndef TypeDefine_h
#define TypeDefine_h

#define UIColorWithRGBA(r,g,b,a)        [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

#define SCREENWIDTH            [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT           [UIScreen mainScreen].bounds.size.height

#define Rate_NAV_W       SCREENWIDTH/375
#define Rate_NAV_H       (SCREENHEIGHT - 64)/603

#define NAVIGATION_BAR_HEIGHT           44.0f
//CES界面高度
#define NAVIGATIONCONTROLLERHEIGHT 65.0f
#define CES_SCREENH_HEIGHT  (SCREENHEIGHT-NAVIGATIONCONTROLLERHEIGHT-NAVIGATION_BAR_HEIGHT)

//服务器URL
#define ADDRESS    @"http://211.161.200.73:8098"
#define JHADDRESS  @"http://211.161.200.73:8098/MeetingOnlinePatient.asmx"

#endif /* TypeDefine_h */
