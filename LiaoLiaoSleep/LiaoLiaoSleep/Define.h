//
//  Define.h
//  LiaoLiaoSleep
//
//  Created by 甘伟 on 16/10/14.
//  Copyright © 2016年 nuozhijia. All rights reserved.
//

#ifndef Define_h
#define Define_h

#ifdef DEBUG
#define NSLog(format, ...) printf("[%s] %s [第%d行] %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define NSLog(format, ...)
#endif

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version)     ([UIDevice currentDevice].systemVersion.floatValue >= [version floatValue])?true:false

#define SCREENWIDTH            [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT           [UIScreen mainScreen].bounds.size.height

//除去状态栏的界面高度
#define VIEW_HEIGHT            (SCREENHEIGHT - 20)
//宽高倍率
#define Rate_W           SCREENWIDTH/375
#define Rate_H           SCREENHEIGHT/667

#define Rate_NAV_W       SCREENWIDTH/375
#define Rate_NAV_H       (SCREENHEIGHT - 64)/603


#define Ratio                  SCREENHEIGHT/667
#define CGRectRatio(X,Y,W,H)   CGRectMake(X*Ratio, Y*Ratio, W*Ratio, H*Ratio)


#define Ratio_W                SCREENWIDTH/375
#define Ratio_H                VIEW_HEIGHT/647

#define Ratio_NAV_W            SCREENWIDTH/375
#define Ratio_NAV_H            (SCREENHEIGHT-64)/603


/**
 *  返回一个RGBA格式的UIColor对象
 */
#define RGBA(r, g, b, a)      [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

/**
 *  字体大小的宏定义
 */
//tableBar的字体大小
#define TableBar_Font         [UIFont systemFontOfSize:15]
/**
 *  疗疗部分
 */
#define LiaoLiao_SelectFont   [UIFont systemFontOfSize:15] //界面选择框中图标字体的定义
/**
 *  环信部分
 */
#define Hyphenate_AppKey        @"12123131121#nuozhijiaimdemo"
#define Hyphenate_CertifyName   @"Certify"
#define Hyphenate_PassWord      @"123456"
/**
 *  客服部分
 */
#define Service_ID         @"nccCustomer"
//#define Service_ID         @"nzjservice"
#define Service_TitleFont  [UIFont systemFontOfSize:14*Ratio] //客服首页标题字体
#define Service_PhoneFont  [UIFont systemFontOfSize:16*Ratio] //客服首页热线电话字体
#define Service_TimeFont   [UIFont systemFontOfSize:12*Ratio] //客服首页客服时间字体

#define Attention_QuestionFont  [UIFont systemFontOfSize:18*Ratio] //注意事项中的问题字体
#define Attention_AnswerFont    [UIFont systemFontOfSize:14*Ratio] //注意事项中的答案字体

#define Question_QuestionFont   [UIFont systemFontOfSize:18*Ratio] //问答中的问题字体
#define Question_AnswerFont     [UIFont systemFontOfSize:14*Ratio] //问答中的答案字体

/**
 *  问医生部分
 */
#define HTTPPORTPREFIX   @"http://211.161.200.73:8098/"

/**
 *  微信支付
 */
//微信支付商户号
#define WX_MCH_ID      @"1413733802"
//开户邮件中的（公众账号APPID或者应用APPID）
#define WX_AppID       @"wxda493bb4790a315f"
//安全校验码（MD5）密钥，商户平台登录账户和密码登录http://pay.weixin.qq.com 平台设置的“API密钥”
#define WX_PartnerKey  @"nuozhijianuozhijianuozhijianuozh"
//获取用户openid，可使用APPID对应的公众平台登录http://mp.weixin.qq.com 的开发者中心获取AppSecret。
//#define WX_AppSecret @"YOUR_WX_AppSecret"

/**
 *  支付宝支付
 */
//合作身份者id，以2088开头的16位纯数字
#define PartnerID @"2088811895746586"
//收款支付宝账号
#define SellerID  @"nzjylqx@163.com"

//安全校验码（MD5）密钥，以数字和字母组成的32位字符
#define MD5_KEY   @"1g81z5tgu3o2yst4mqm6n838dxe5cw1a"

//商户私钥，自助生成
#define PartnerRSAPrivKey @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMFwYFZeSvhjZ1T0PwcpvKLN70guWrdkqO9k8bkVFnWsD1SzRGLiZvMKLRpWaH4rROtZzUhk1xwh8Hdah1EnmPGLrBfvBpQ6ykm6VTSllOmyLiH6M+mW+HTE+0qJGW95PE7KQ3WupDLd3iH1VTgQojv2TpnMMRPDhBv52Cdxbm+pAgMBAAECgYBjZGR7vFN1MU5E3oMMISvl0z6hrf+6v6P17b4uRWGW8OOnt7zpuj7/njjykXd7bKwq6aeLDRViRSYTjZZ94oS4occQOYr2cJssRs9oA3Nqk2bgIyippRjp1IVAQwEw8sqaiqs7iUh8/rdzzCX2qJA85EM7IPRnwiSWufpuh0thSQJBAPl/75zYPdxUeo5QaJjkRqZvdTBt7rZvHl6XzeGyN352R9evRMgMg0ol6cmDkWiL0h1ZuIAEw532O5PNsr1FCrcCQQDGeomI4M8oXXmlaizV6YB+qlmSth2PhaajlDY1gnc3Nxvf6Mm0AbC1TZ2yBELRshzgwW6rKOrCGSToAEPSsXifAkEAtNBRz2IrWqzicJa3Zu4wgVfPHvzcfdwDr1vmecVVUFHZ+OZtO2lOEINvbXnq/FAwQtMN0cEiHy0euhvdiCsr+wJAPDmGbiA4+7iRZt32yNnXgZfTIi9cfOZDEDOy1z3FSt3P+Xs7aQFySzFH/nJIjDSNiq1nFUyPH2Jdzn/2FIKBZQJBAMQx29mbWWFDAReDtd8b7+PvPQxA/ghNs5QSXF2VGlzM/Mn0rNDM+59aQKgDioHcBEpW4auDQCA4QykqsauNOhE="
#define PartnerPrivKey @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAKxvbZwK6eJxDvfmsjjoNN4F9veLUFPwFbV0VF0WkWXmjbF6EkDSuar27Me2lFZyS5usUBz4S/2UGcKAFzawpN6JH3TRw5fcuEZ4tUxDkn8ft7zoeOSatPVwjPjbcJkl3f95+6I/6VY2btR8k1V5//30FVPbVh7fz/Tdm2sBW+QvAgMBAAECgYEAkfi2Kk2W1qlsyXES2FfCQV19Rus5cgUg633x2Oe86C13L5GuGBALOu5TXXFzO4b/+GWzYALVmXGhKOT0Qcjhl1kYtyUFDsqEcp1qfnJkCWSmMWAZwf2o5wH+sCBBZDhvFYKP6iUbR3zkKdTREurtmtBqLFMXvZDLZfB/EaSbeckCQQDb1xtoQikISxWJrv4YnDb3/NaktYl7KsF/MawCoNFvkxdK69qorJEpBovhEBcY3DHAOFR8CWEqJzNoKxt9/BPNAkEAyMw4zux0YgDQJxtnH3AQpCwIwXP4WKgpLY/Dz1mNrsY/wIznaUpONqEIQ9OSV6HAnHm3WaIOuK+3IwyfEPOT6wJANd2dD4y2dRvAqT3BcNJF/blr9musxgsR4lKPbQ1ug8IswOTNbOrrnnvGJl1E64h4gDrNKJ87uZJlXC7Dy7jKOQJBALZkmy2Kp2TmLC15vMBXwSX/QazHtMyDY3QZZNoSFJqvRfWXiBSiBE2nFKTXp9Sl/xmjjiKDDDBCnG3f5xU0zCUCQGGMGh2ZHniHm62t1vxPMV9+oVkC8P7T4tZwdSQzEmFUgqsVRLNc30bEyf4cUC95M7tE1CNYU9TkNpNxpRgT/wI="


//支付宝公钥
#define AlipayPubKey   @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCsb22cCunicQ735rI46DTeBfb3i1BT8BW1dFRdFpFl5o2xehJA0rmq9uzHtpRWckubrFAc+Ev9lBnCgBc2sKTeiR900cOX3LhGeLVMQ5J/H7e86HjkmrT1cIz423CZJd3/efuiP+lWNm7UfJNVef/99BVT21Ye38/03ZtrAVvkLwIDAQAB"
#define AliRSAPubKey @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDDI6d306Q8fIfCOaTXyiUeJHkrIvYISRcc73s3vF1ZT7XN8RNPwJxo8pWaJMmvyTn9N4HQ632qJBVHf8sxHi/fEsraprwCtzvzQETrNRwVxLO5jVmRGi60j8Ue1efIlzPXV9je9mkjzOmdssymZkh2QhUrCmZYI/FCEa3/cNMW0QIDAQAB"

//服务器URL
#define ADDRESS    @"http://211.161.200.73:8098"
#define JHADDRESS  @"http://211.161.200.73:8098/MeetingOnlinePatient.asmx"

#define APPID      @"1060524805"

#endif /* Define_h */
