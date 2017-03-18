//
//  WXApiManager.m
//  WXPayAndAirPay
//
//  Created by 孙承秀 on 16/11/15.
//  Copyright © 2016年 孙先森丶. All rights reserved.
//

#import "WXApiManager.h"

@implementation WXApiManager
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}
/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
-(void)onResp:(BaseResp *)resp {
    /*! @brief 微信终端向第三方程序返回的SendMessageToWXReq处理结果。
     *
     * 第三方程序向微信终端发送SendMessageToWXReq后，微信发送回来的处理结果，该结果用SendMessageToWXResp表示。
     */
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveGetMessageReq:)]) {
            SendMessageToWXResp *messageresp = (SendMessageToWXResp *)resp;
            [self.delegate didReceiveGetMessageReq:messageresp];
        }
    }
    /*! @brief 微信处理完第三方程序的认证和权限申请后向第三方程序回送的处理结果。
     *
     * 第三方程序要向微信申请认证，并请求某些权限，需要调用WXApi的sendReq成员函数，向微信终端发送一个SendAuthReq消息结构。
     * 微信终端处理完后会向第三方程序发送一个SendAuthResp。
     * @see onResp
     */
    else if ([resp isKindOfClass:[SendAuthResp class]]){
    
        if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveAuthResponse:)]) {
            SendAuthResp *authResp = (SendAuthResp *)resp;
            [self.delegate didReceiveAuthResponse:authResp];
        }
    }
    /** ! @brief 微信返回第三方添加卡券结果
     *
     */

    else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]]){
    
        if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveAddCardResponse:)]) {
            AddCardToWXCardPackageResp *cardResp = (AddCardToWXCardPackageResp *)resp;
            [self.delegate didReceiveAddCardResponse:cardResp];
        }
    }
    /*! @brief 微信终端返回给第三方的关于支付结果的结构体
     *
     *  微信终端返回给第三方的关于支付结果的结构体
     */
    else if ([resp isKindOfClass:[PayResp class]]){
        NSString *strMsg,*strTitle = [NSString stringWithFormat:@"支付结果"];
        switch (resp.errCode) {
            case WXSuccess:
                strMsg = @"支付成功";
                break;
                
            default:
                strMsg = [NSString stringWithFormat:@"支付失败 ：错误码:%d 错误信息:%@",resp.errCode,resp.errStr];
                break;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    
    }

}
@end
