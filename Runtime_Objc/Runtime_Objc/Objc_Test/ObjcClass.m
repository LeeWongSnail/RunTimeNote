//
//  ObjcClass.m
//  Runtime_Objc
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ObjcClass.h"
#import <objc/runtime.h>
#import "Father.h"

@implementation ObjcClass

/**
 获取对象的类名。
 */
- (void)getClassName
{
    Father *father = [[Father alloc] init];
    NSLog(@"father的类名是：%s",object_getClassName(father));
}


/**
 获取对象的类
 其内部实现就是获取object的类，也就是isa指针，然后传给class_getName(Class cls)函数
 */
- (void)getClass
{
    Father *father = [[Father alloc] init];
    Class cls = object_getClass(father);
    NSLog(@"%s",class_getName(cls));
}



/**
 设置对象的类
 object不能是nil，nil是“万物之源”，连NSObject的父类都是nil，
 所以你不能给nil指定一个类。在object_setClass的实现中，第一行代码就是if (!obj) return nil;
 */
- (void)setObjClass
{
    NSObject *obj = [[NSObject alloc] init];
    //object 需要设置类的对象。 cls 需要设置的类
    object_setClass(obj, [Father class]);
    NSLog(@"%@",obj);
}

@end
