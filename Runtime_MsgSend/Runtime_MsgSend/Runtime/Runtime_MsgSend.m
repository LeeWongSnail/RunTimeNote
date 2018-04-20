//
//  Runtime_MsgSend.m
//  Runtime_MsgSend
//
//  Created by LeeWong on 2018/4/20.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

/*
 objc_msgSend(receiver, selector)
 objc_msgSend(receiver, selector, arg1, arg2, ...)
 方法调用流程
 **/


#import "Runtime_MsgSend.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation Runtime_MsgSend

/**
 Xcode中使用method_invoke或者objc_msgSend()报错Too many arguments to function call ,expected 0,have3
 在工程-Build Settings  中将Enable Strict Checking of objc_msgSend Calls 设置为NO即可
 */
//- (void)msgSend_test
//{
//    objc_msgSend(self,@selector(method));
//}


/**
 适合于在类似于for循环这种情况下频繁调用同一方法，以提高性能的情况。另外，methodForSelector:是由Cocoa运行时提供的；它不是Objective-C语言的特性。
 NSObject类提供了methodForSelector:方法，让我们可以获取到方法的指针，然后通过这个指针来调用实现代码
 */
- (void)getMethodAddress
{
    void (*setter)(id, SEL, BOOL);
    int i;
    //快速执行多次同一个方法
    setter = (void (*)(id, SEL, BOOL))[self methodForSelector:@selector(method)];
    for (i = 0 ; i < 1000 ; i++)
        setter(self, @selector(method), YES);
}


- (void)method
{
    NSLog(@"%s",__func__);
}

@end
