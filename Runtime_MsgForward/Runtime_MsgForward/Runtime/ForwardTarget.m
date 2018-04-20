//
//  ForwardTarget.m
//  Runtime_MsgForward
//
//  Created by LeeWong on 2018/4/20.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ForwardTarget.h"
#import "ResolveMethod.h"
#import <objc/runtime.h>
#import <objc/message.h>

/*
 这里有一个问题 如果调用的是一个类方法 结果根本不会走到forwardingTargetForSelector这个方法 这时候如何处理？？？？？？？
 **/

@interface ForwardTarget()
@property (nonatomic, strong) ResolveMethod *resMethod;
@end

@implementation ForwardTarget


- (instancetype)init
{
    if (self = [super init]) {
        self.resMethod = [[ResolveMethod alloc] init];
    }
    return self;
}

/**
 如果一个对象实现了这个方法，并返回一个非nil的结果，则这个对象会作为消息的新接收者，且消息会被分发到这个对象
 当然这个对象不能是self自身，否则就是出现无限循环
 
 @param aSelector 需要被转发的方法的名称(获取不到方法参数)
 @return 转发给那个对象
 */

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSString *selectorStr = NSStringFromSelector(aSelector);
    if ([selectorStr isEqualToString:@"noIMPInstanceMethod"]) {
        return self.resMethod;
    }
    

    return [super forwardingTargetForSelector:aSelector];
}

/**
 与对象方法对应的一个类方法

 @param aSelector 方法名称
 @return 返回的处理类
 */
+ (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSString *selectorStr = NSStringFromSelector(aSelector);
    if ([selectorStr isEqualToString:@"noIMPClassMethod"]) {
        return [ResolveMethod class];
    }
    return [super forwardingTargetForSelector:aSelector];
}


@end
