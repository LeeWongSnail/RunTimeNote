//
//  ClassCreateInstance.m
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/17.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ClassCreateInstance.h"
#import <objc/runtime.h>
#import "Father.h"

@implementation ClassCreateInstance


/**
 创建实例时，会在默认的内存区域为类分配内存。extraBytes参数表示分配的额外字节数。
 这些额外的字节可用于存储在类定义中所定义的实例变量之外的实例变量。该函数在ARC环境下无法使用。
 调用class_createInstance的效果与+alloc方法类似
 */
- (void)createInstance
{
    //创建的是对象类型而不是字符串常量类型
    id instance = class_createInstance([NSString class], sizeof(unsigned));
    NSLog(@"新创建了一个%s",class_getName([instance class]));
    
    
    id str1 = [instance init];
    NSLog(@"%@", [str1 class]);
    id str2 = [[NSString alloc] initWithString:@"test"];
    NSLog(@"%@", [str2 class]);
}


/**
 ARC下不可用
在指定的位置(bytes)创建类实例。详情参考ClassMRC类
 */
- (void)createInstanceAtLocation
{
//    id instance = objc_constructInstance([Father class],0);
}

/**
 ARC下不可用
 销毁一个类的实例，但不会释放并移除任何与其相关的引用。
 详情参考ClassMRC类
 */
- (void)destoryInstance
{
    id instance = class_createInstance([NSString class], sizeof(unsigned));
    NSLog(@"新创建了一个%s",class_getName([instance class]));
//    ARC下不可用
//    objc_destructInstance(instance);
}

@end
