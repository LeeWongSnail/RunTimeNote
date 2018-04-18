//
//  ClassCreate.m
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/17.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ClassCreate.h"
#import <objc/runtime.h>


@implementation ClassCreate

void imp_submethod1(id self,SEL cmd) {
    NSLog(@"%s",__func__);
}



/**
 动态的去创建一个类 并且 为这个类添加方法 添加实例变量 添加属性
 */
- (void)createNewClassInRuntime
{
    //新建一个类
    //如果我们要创建一个根类，则superclass指定为Nil。extraBytes通常指定为0，该参数是分配给类和元类对象尾部的索引ivars的字节数。
    Class cls = objc_allocateClassPair(NSObject.class, "MyClass", 0);
    
    //添加类的对象方法
    class_addMethod(cls, @selector(submethod1), (IMP)imp_submethod1, "v@:");
    class_replaceMethod(cls, @selector(method1), (IMP)imp_submethod1, "v@:");
    
    //添加类的实例变量
    class_addIvar(cls, "_ivar1", sizeof(NSString *), log(sizeof(NSString *)), "i");

    //添加属性
    objc_property_attribute_t type = {"T", "@\"NSString\""};
    objc_property_attribute_t ownership = { "C", "" };
    objc_property_attribute_t backingivar = { "V", "_ivar1"};
    objc_property_attribute_t attrs[] = {type, ownership, backingivar};
    class_addProperty(cls, "property2", attrs, 3);
    
    //注册类
    objc_registerClassPair(cls);

    NSLog(@"-------------vertify-----------------");
    [NSString stringWithFormat:@"current class name : %s",class_getName(NSClassFromString(@"MyClass"))];
    
    NSLog(@"-----------method list -----------------");
    unsigned int outCount = 0;
    Method *list = class_copyMethodList(NSClassFromString(@"MyClass"), &outCount);
    for (int i = 0; i < outCount; i++) {
        Method m = list[i];
        if (m != NULL) {
            NSLog(@"method %s", method_getName(m));
        }
    }
    free(list);
    
    
    NSLog(@"-------------ivar---------------");
    outCount = 0;
    Ivar *vars = class_copyIvarList(NSClassFromString(@"MyClass"), &outCount);
    for (int i = 0 ; i < outCount; i++) {
        Ivar var = vars[i];
        NSLog(@"ivar name = %s  ivar type = %s",ivar_getName(var),ivar_getTypeEncoding(var));
    }
    free(vars);
    
    
    NSLog(@"-----------property-----------------");
    outCount = 0;
    objc_property_t *props = class_copyPropertyList(NSClassFromString(@"MyClass"), &outCount);
    for (int i = 0 ; i < outCount; i ++) {
        objc_property_t prop = props[i];
        NSLog(@"ivar name = %s  ivar type = %s",property_getName(prop),property_getAttributes(prop));
    }
    free(props);
}

@end
