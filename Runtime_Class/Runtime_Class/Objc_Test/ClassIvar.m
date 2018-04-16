//
//  Ivar.m
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/16.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ClassIvar.h"
#import <objc/runtime.h>

@implementation ClassIvar


/**
 它返回一个指向包含name指定的成员变量信息的objc_ivar结构体的指针(Ivar)。
 */
- (void)getInstanceVariable
{
    Ivar var = class_getInstanceVariable([self class], "_name");
    NSLog(@"ivar name = %s  ivar type = %s",ivar_getName(var),ivar_getTypeEncoding(var));
}


/**
 啥是类变量
 目前没有找到关于Objective-C中类变量的信息，一般认为Objective-C不支持类变量。注意，返回的列表不包含父类的成员变量和属性
 */
- (void)getClassVariable
{

}


/**
 获取实例变量的列表
 */
- (void)getIvarList
{
    unsigned int count = 0;
    Ivar *vars = class_copyIvarList([self class], &count);
    for (int i = 0 ; i <count; i++) {
        Ivar var = vars[i];
        NSLog(@"ivar name = %s  ivar type = %s",ivar_getName(var),ivar_getTypeEncoding(var));
    }
}

- (void)addIvarDynamic
{
    Class cls = objc_allocateClassPair(NSObject.class, "Person", 0);
    class_addIvar(cls, "_nickname", sizeof(NSString *), log(sizeof(NSString *)), "i");
    objc_property_attribute_t type = {"T", "@\"NSString\""};
    objc_property_attribute_t ownership = { "C", "" };
    objc_property_attribute_t backingivar = { "V", "_ivar1"};
    objc_property_attribute_t attrs[] = {type, ownership, backingivar};
    class_addProperty(cls, "property2", attrs, 3);
    objc_registerClassPair(cls);
    id instance = [[cls alloc] init];
    
    unsigned int count = 0;
    Ivar *vars = class_copyIvarList([instance class], &count);
    for (int i = 0 ; i <count; i++) {
        Ivar var = vars[i];
        NSLog(@"ivar name = %s  ivar type = %s",ivar_getName(var),ivar_getTypeEncoding(var));
    }
}

@end
