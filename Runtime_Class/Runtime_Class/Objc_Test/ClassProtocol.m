//
//  ClassProtocol.m
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/17.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ClassProtocol.h"
#import <objc/runtime.h>

@implementation ClassProtocol


/**
 获取遵守的协议的列表
 获取类 cls 遵守的所有协议，而 cls 的父类所遵守的协议不会获取到
 */
- (void)copyProtocolList
{
    unsigned int  outCount = 0;
    Protocol * __unsafe_unretained * protocols = class_copyProtocolList([self class], &outCount);
    Protocol * protocol;
    for (int i = 0; i < outCount; i++) {
        protocol = protocols[i];
        NSLog(@"protocol name : %s",protocol_getName(protocol));
    }
    free(protocols);
}



/**
 判断一个类是否遵守了某个协议
 class_conformsToProtocol函数可以使用NSObject类的conformsToProtocol:方法来替代。
 */
- (void)classConformsProtocol
{
    Protocol *p = objc_getProtocol("Protocol1");
    if (class_conformsToProtocol([self class], p)) {
        NSLog(@"%s implementation %s",class_getName([self class]),protocol_getName(p));
    } else {
        NSLog(@"%s not implementation %s",class_getName([self class]),protocol_getName(p));
    }
    
    Protocol *p1 = objc_getProtocol("Protocol2");
    if (class_conformsToProtocol([self class], p1)) {
        NSLog(@"%s implementation %s",class_getName([self class]),protocol_getName(p1));
    } else {
        NSLog(@"%s not implementation %s",class_getName([self class]),protocol_getName(p1));
    }
    
}


/**
 添加一个已注册的协议到协议中
 需要注意的是如果仅仅是声明了一个协议，而未在任何类中实现这个协议，则该函数返回的是nil
 https://stackoverflow.com/questions/11813030/what-does-class-addprotocol-actually-do-in-objective-c
 */
- (void)addProtocol
{
    Protocol *p = objc_getProtocol("Protocol2");
    if (class_addProtocol([self class], p)) {
        NSLog(@"add protoccol2 success");
    } else {
        NSLog(@"add protocol2 failed");
    }
    
}


#pragma mark -

- (void)method1InProtocol1
{
    NSLog(@"%s",__func__);
}

void method2InProtocol2(id self,SEL cmd) {
    NSLog(@"%s",__func__);
}


@end
