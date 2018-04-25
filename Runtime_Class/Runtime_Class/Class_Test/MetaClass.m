//
//  ISA_Pointer.m
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/16.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "MetaClass.h"
#import <objc/runtime.h>
#import "Father.h"
#import "Son.h"


@implementation MetaClass

//获取Father和Son的元类

/**
 这端代码 可以发现 每一个类都有一个自己的元类 存放着这个类对应的所有类方法。 非根类的元类的元类指向着根类的元类
 根类的元类指向类本身
 */
- (void)getMetaClass
{
    Class fatherMeta = objc_getMetaClass(class_getName([Father class]));
    NSLog(@"%s's meta-class is %s", class_getName([Father class]), class_getName(fatherMeta));
    
    
    Class sonMeta = objc_getMetaClass(class_getName([Son class]));
    NSLog(@"%s's meta-class is %s", class_getName([Son class]), class_getName(sonMeta));

    Class objMeta = objc_getMetaClass(class_getName([NSObject class]));
    NSLog(@"%s's meta class : %s",class_getName([NSObject class]), class_getName(objMeta));

    Class fatherSuperMeta = objc_getMetaClass(class_getName([Father superclass]));
    NSLog(@"%s's meta class : %s",class_getName([Father superclass]), class_getName(fatherSuperMeta));
}

- (void)classIsMetaClass
{
    Class cls = [Father class];
    Class fatherMeta = objc_getMetaClass(class_getName([Father class]));
    NSLog(@"%@ is %@ a meta class",[Father class],class_isMetaClass(cls)?@"":@"not");
    NSLog(@"%@ is %@ a meta class",[fatherMeta class],class_isMetaClass(fatherMeta)?@"":@"not");
}

/**
 这个方法是获取Son类 的metaClass 树
 */
- (void)getSonMetaClassTree
{
    Class currentClass = [Son class];
    for (int i = 0; i < 4; i++) {
        NSLog(@"Following the isa pointer %d times gives %p", i, currentClass);
        currentClass = objc_getClass((__bridge void *)currentClass);
        
    }
}

@end
