//
//  Objc_Ivar.m
//  Runtime_IvarAndProperty
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "Objc_Ivar.h"
#import <objc/runtime.h>

//Ivar是表示实例变量的类型，其实际是一个指向objc_ivar结构体的指针，其定义如下：
/*
 typedef struct objc_ivar *Ivar;
 struct objc_ivar {
 char *ivar_name                   OBJC2_UNAVAILABLE;    // 变量名
 char *ivar_type                 OBJC2_UNAVAILABLE;    // 变量类型
 int ivar_offset                    OBJC2_UNAVAILABLE;    // 基地址偏移字节
 #ifdef __LP64__
 int space                         OBJC2_UNAVAILABLE;
 #endif
 }
 **/

@implementation Objc_Ivar


/**
 获取成员变量的个数类型以及偏移量
 ivar_getOffset函数，对于类型id或其它对象类型的实例变量，可以调用object_getIvar和object_setIvar来直接访问成员变量，而不使用偏移量。
 */
- (void)getIvarName
{
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    NSLog(@"成员变量个数: %d",outCount);
    for (int i = 0; i<outCount; i++) {
        Ivar ivar = ivars[i];
        NSLog(@"变量名称: %s,类型: %s,偏移量: %td",ivar_getName(ivar),ivar_getTypeEncoding(ivar),ivar_getOffset(ivar));
    }
    free(ivars);
}


@end
