//
//  ClassMRC.m
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ClassMRC.h"
#import <objc/runtime.h>
#import "Father.h"

@implementation ClassMRC


/**
在指定的位置(bytes)创建类实例。
 */
- (id)createInstance
{
    size_t objSize = class_getInstanceSize([Father class]);
    size_t allocSize = 2 * objSize;
    uintptr_t ptr = (uintptr_t)calloc(allocSize, 1);
    id obj = objc_constructInstance([Father class], &ptr);
    NSLog(@"%@",[obj class]);
    return obj;
}


/**
 销毁一个类的实例，但不会释放并移除任何与其相关的引用。
 */
- (void)class_destoryInstance
{
    Father *tempPerson = [[Father alloc] init];
    tempPerson.name = @"Lee";
    // 释放后 无法取得name的值
    NSLog(@"before 销毁类实例---%@ destruct result %@",tempPerson,tempPerson.name);
    objc_destructInstance(tempPerson);
    NSLog(@"after 销毁类实例---%@ destruct result %@",tempPerson,tempPerson.name);
    
    //上面的destructInstance 并没有将对象也给释放
    [tempPerson release];
}

@end
