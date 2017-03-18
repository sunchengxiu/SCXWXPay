//
//  ViewController.m
//  WXPayAndAirPay
//
//  Created by 孙承秀 on 16/11/15.
//  Copyright © 2016年 孙先森丶. All rights reserved.
//

#import "ViewController.h"
#import "WXApi.h"
#define WXSignID @"wxb4ba3c02aa476ea1"
#define WXMchID @"1230000109"
@interface ViewController ()
@property (nonatomic , strong) UIButton *button;
@property (nonatomic , strong) UIButton *signButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view addSubview:self.button];
    //[self.view addSubview:self.signButton];
    
}
#pragma mark - 微信支付有本地签名
-(UIButton *)signButton{
    
    if (_signButton==nil) {
        _signButton = [[UIButton alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 200)/2, 300, 200, 80)];
        [_signButton setTitle:@"微信支付(本地签名)" forState:UIControlStateNormal];
        [_signButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_signButton setBackgroundColor:[UIColor greenColor]];
        [_signButton addTarget:self action:@selector(WXPayHasSign) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signButton;
}
- (void)WXPayHasSign {
    NSString *urlString   = @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php?plat=ios";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self beginSendWXPay:request];
    
}
- (void)beginSendWXPay :(NSURLRequest *)request {
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSLog(@"%@",error);
    if (data != nil) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        //dict=[NSDictionary dictionaryWithXMLData:data];
        if (dict != nil) {
            NSMutableString *stamp = [dict objectForKey:@"timestamp"];
            PayReq *req = [[PayReq alloc]init];
            
            req.partnerId           = [dict objectForKey:@"partnerid"];
            req.prepayId            = [dict objectForKey:@"prepayid"];
            req.nonceStr            = [dict objectForKey:@"noncestr"];
            req.timeStamp           = stamp.intValue;
            req.package             = [dict objectForKey:@"package"];
           
            //生成签名
            NSMutableDictionary *mutiDict = [NSMutableDictionary dictionary];
            [mutiDict setObject:req.partnerId forKey:@"partnerId"];
            [mutiDict setObject:req.prepayId forKey:@"prepayid"];
            [mutiDict setObject:req.nonceStr forKey:@"noncestr"];
            [mutiDict setObject:[NSString stringWithFormat:@"%u",(unsigned int)req.timeStamp] forKey:@"timestamp"];
            [mutiDict setObject:req.package forKey:@"package"];
            NSDictionary *signDic = [AppMethod partnerSignOrder:mutiDict];
            req.sign = [dict objectForKey:@"sign"];
            [WXApi sendReq:req];
        }
    }

}
#pragma mark - 微信支付无本地签名
-(UIButton *)button {

    if (_button == nil) {
        _button = [[UIButton alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 200)/2, 200, 200, 80)];
        [_button setTitle:@"微信支付(无本地签名)" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button setBackgroundColor:[UIColor blueColor]];
        [_button addTarget:self action:@selector(WXPay) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _button;
}
- (void)WXPay {

    NSLog(@"点击微信支付了");
    //============================================================
    //
    // 调起微信支付
    //
    //============================================================
    NSString *urlString   = @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php?plat=ios";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (data != nil) {
        NSError *error;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (dict != nil) {
            NSMutableString *code = dict[@"retcode"];
            if (code.integerValue == 0) {
                NSMutableString *stamp = [dict objectForKey:@"timestamp"];
                //===================================================
                /*
                * 商家向财付通申请的商家id 
                @property (nonatomic, retain) NSString *partnerId;
                * 预支付订单 
                @property (nonatomic, retain) NSString *prepayId;
                * 随机串，防重发 
                @property (nonatomic, retain) NSString *nonceStr;
                * 时间戳，防重发 
                @property (nonatomic, assign) UInt32 timeStamp;
                * 商家根据财付通文档填写的数据和签名 
                @property (nonatomic, retain) NSString *package;
                * 商家根据微信开放平台文档对数据做的签名 
                @property (nonatomic, retain) NSString *sign;
                */
                //===================================================
                //第三方向微信发起支付的结构体
                PayReq *req = [[PayReq alloc]init];
                req.partnerId           = [dict objectForKey:@"partnerid"];
                req.prepayId            = [dict objectForKey:@"prepayid"];
                req.nonceStr            = [dict objectForKey:@"noncestr"];
                req.timeStamp           = stamp.intValue;
                req.package             = [dict objectForKey:@"package"];
                req.sign                = [dict objectForKey:@"sign"];
                [WXApi sendReq:req];
            }
        }
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
