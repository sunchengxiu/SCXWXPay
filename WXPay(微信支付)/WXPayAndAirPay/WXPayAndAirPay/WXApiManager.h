//
//  WXApiManager.h
//  WXPayAndAirPay
//
//  Created by 孙承秀 on 16/11/15.
//  Copyright © 2016年 孙先森丶. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
@protocol WXApiManagerDelegate;
@interface WXApiManager : NSObject<WXApiDelegate>
/******  代理 *****/
@property(nonatomic,assign)id <WXApiManagerDelegate> delegate;

+(instancetype)sharedManager;
@end

@protocol WXApiManagerDelegate <NSObject>

@optional

- (void)didReceiveGetMessageReq:(GetMessageFromWXReq *)req;

- (void)didReceiveShowMessageReq:(ShowMessageFromWXReq *)req;

- (void)didReceiveLaunchFromWXReq:(LaunchFromWXReq *)req;

- (void)didReceiveMessageResponse:(SendMessageToWXReq *)req;

- (void)didReceiveAuthResponse:(SendAuthResp *)resp;

- (void)didReceiveAddCardResponse:(AddCardToWXCardPackageResp *)resp;

@end
