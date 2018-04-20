//
//  ForwardTarget.h
//  Runtime_MsgForward
//
//  Created by LeeWong on 2018/4/20.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForwardTarget : NSObject
//一个只有声明没有实现的方法
- (void)noIMPInstanceMethod;
+ (void)noIMPClassMethod;
@end
