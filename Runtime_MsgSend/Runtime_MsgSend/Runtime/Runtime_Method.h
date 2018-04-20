//
//  Runtime_Method.h
//  Runtime_MsgSend
//
//  Created by LeeWong on 2018/4/20.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Runtime_Method : NSObject
- (void)invoke_test;
- (void)getMethodName;
- (void)getMethodIMP;
- (void)getTypeEncoding;
- (void)getReturnType;
- (void)copyReturnType;
- (void)copyArguType;
- (void)setIMP;
- (void)exchangeMethod;

@end
