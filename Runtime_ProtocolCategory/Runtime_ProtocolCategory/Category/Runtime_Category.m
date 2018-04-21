//
//  Category.m
//  Runtime_ProtocolCategory
//
//  Created by LeeWong on 2018/4/21.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

/*
 typedef struct objc_category *Category;
 struct objc_category {
 char *category_name                          OBJC2_UNAVAILABLE;    // 分类名
 char *class_name                             OBJC2_UNAVAILABLE;    // 分类所属的类名
 struct objc_method_list *instance_methods    OBJC2_UNAVAILABLE;    // 实例方法列表
 struct objc_method_list *class_methods       OBJC2_UNAVAILABLE;    // 类方法列表
 struct objc_protocol_list *protocols         OBJC2_UNAVAILABLE;    // 分类所实现的协议列表
 }
 **/


#import "Runtime_Category.h"
#import <objc/runtime.h>

@implementation Runtime_Category


/**
 可以通过获取类的所有实例方法来 判断 分类的方法是否注册的本类中
 */
- (void)getInstanceMethods
{
    unsigned int outCount = 0;
    Method *methodList = class_copyMethodList(self.class, &outCount);
    for (int i = 0; i < outCount; i++) {
        Method method = methodList[i];
        const char *name = sel_getName(method_getName(method));
        NSLog(@"RuntimeCategoryClass's method: %s", name);
    }
    
}


/**
 获取一个类的类方法
 必须是声明且实现才可以获取到
 同样 分类中声明和实现的方法也可以获取到
 */
- (void)getClassMethods
{
    unsigned int outCount = 0;
    Class metaCls = objc_getMetaClass(class_getName([self class]));
    Method *methodList = class_copyMethodList(metaCls, &outCount);
    for (int i = 0; i < outCount; i++) {
        Method method = methodList[i];
        const char *name = sel_getName(method_getName(method));
        NSLog(@"RuntimeCategoryClass's method: %s", name);
    }
}

- (void)method
{
    NSLog(@"%s",__func__);
}


+ (void)method3
{
    NSLog(@"%s",__func__);
}


@end
