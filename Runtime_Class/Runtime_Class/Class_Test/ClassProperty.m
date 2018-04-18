//
//  ClassProperty.m
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/16.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ClassProperty.h"
#import <objc/runtime.h>

@implementation ClassProperty

@synthesize name = myName;

/**
 获取指定类的指定的属性
 注意：与ivar不同的是 这里直接用变量名
 使用@property 声明的变量 属性名为name 对应的实例变量名为_name
 */
- (void)getProperty
{
    objc_property_t property = class_getProperty([self class], "name");
   NSLog(@"%s",property_getName(property));
    
    Ivar var = class_getInstanceVariable([self class], "myName");
    NSLog(@"ivar name = %s  ivar type = %s",ivar_getName(var),ivar_getTypeEncoding(var));
}


/**
 获取类的属性列表 注意这里面 属性的描述信息
 T@"NSString",C,N,VmyName
理解不同字段代表的意义 具体参考官网
 https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
 */
- (void)copyPropertyList
{
    unsigned int outCount = 0;
    objc_property_t *props = class_copyPropertyList([self class], &outCount);
    for (int i = 0 ; i < outCount; i ++) {
        objc_property_t prop = props[i];
        NSLog(@"ivar name = %s  ivar type = %s",property_getName(prop),property_getAttributes(prop));
    }
    free(props);
}


/**
 为当前类添加一个属性 注意 虽然 不能对已存在的类添加实例变量ivar但是可以添加属性
 */
- (void)addPropertyDynamic
{
    objc_property_attribute_t type = {"T", "@\"NSString\""};
    objc_property_attribute_t ownership = { "C", "" };
    objc_property_attribute_t backingivar = { "V", "_ivar1"};
    objc_property_attribute_t attrs[] = {type, ownership, backingivar};
    class_addProperty([self class], "nickName", attrs, 3);
    
    [self copyPropertyList];
}


/**
 这里只是替换某一个属性的类型 而不是将某个属性替换为另一个属性
 */
- (void)replaceClassProperty
{
    objc_property_attribute_t type = {"T", "@\"NSArray\""};
    objc_property_attribute_t ownership = { "&N", "" };
    objc_property_attribute_t backingivar = { "V", "_nickName"};
    objc_property_attribute_t attrs[] = {type, ownership, backingivar};
    class_replaceProperty([self class], "nickName", attrs, 3);
    NSLog(@"--------- after replace -----------------");
     [self copyPropertyList];
}
@end
