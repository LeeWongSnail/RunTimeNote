//
//  ClassProperty.m
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/16.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ClassProperty.h"
#import <objc/runtime.h>
#import "Son.h"

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
    objc_property_t *props = class_copyPropertyList([Son class], &outCount);
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
    if (class_addProperty([self class], "nickName", attrs, 3)) {
        NSLog(@"添加成功");
    }
  
    [self copyPropertyList];
}


/**
 这里只是替换某一个属性的类型 而不是将某个属性替换为另一个属性
 */
- (void)replaceClassProperty
{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        if (strcmp(property_getName(property), "name") == 0) {
            NSLog(@"name = %s,atttrs = %s", property_getName(property), property_getAttributes(property));
        }
    }
    free(properties);
    
    
    objc_property_attribute_t type;
    type.name = "T";
    type.value = "@\"NSString\"";
    
    objc_property_attribute_t des;
    des.name = "R";
    des.value = "";
    
    objc_property_attribute_t namic;
    namic.name = "N";
    namic.value = "";
    
    objc_property_attribute_t name;
    name.name = "V";
    name.value = "xxname";
    
    objc_property_attribute_t atts[] = {type,des,namic,name};
    class_replaceProperty([self class], "name", atts, 4);
    
    unsigned int count2;
    objc_property_t *properties2 = class_copyPropertyList([self class], &count2);
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties2[i];
        if (strcmp(property_getName(property), "name") == 0) {
            NSLog(@"name = %s,atttrs = %s", property_getName(property), property_getAttributes(property));
        }
    }
    free(properties2);
}
@end
