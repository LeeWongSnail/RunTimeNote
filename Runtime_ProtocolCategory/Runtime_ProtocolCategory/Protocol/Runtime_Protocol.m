//
//  Protocol.m
//  Runtime_ProtocolCategory
//
//  Created by LeeWong on 2018/4/21.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

/*
 typedef struct objc_object Protocol;

 **/

#import "Runtime_Protocol.h"
#import <objc/runtime.h>

@interface Runtime_Protocol()
@end

@implementation Runtime_Protocol


/**
 返回指定的协议
 当前类必须遵守了这个协议才可以获取到这个协议 否则 获取不到
 */
- (void)getProtocol
{
    Protocol *prop = objc_getProtocol("RuntimeProtocol1");
    Protocol *prop1 = objc_getProtocol("RuntimeProtocol2");

    
    NSLog(@"%s",protocol_getName(prop));
    NSLog(@"%s",protocol_getName(prop1));

}


/**
 获取运行时所知道的所有协议的数组
 这里不止是这个类遵守的协议 而是运行时所有的协议
 */
- (void)getProtocolList
{
    unsigned int outCount = 0;
    Protocol * __unsafe_unretained *props = objc_copyProtocolList(&outCount);
    for (int i = 0; i < outCount; i++) {
        Protocol *p = props[i];
        NSLog(@"%s",protocol_getName(p));
    }
}


- (void)addProtocolDurRuntime
{
    Protocol *prop = objc_allocateProtocol("RuntimeProtocol3");
    
    // 为协议添加方法
    protocol_addMethodDescription(prop, @selector(addMethod), "v@:", NO, YES);
    
    //为协议添加属性
    objc_property_attribute_t attrs[] = { { "T", "@\"NSString\"" }, { "&", "N" }, { "V", "" } };
    protocol_addProperty(prop, "newAddProperty", attrs, 3, NO, YES);
    
    // 添加一个已注册的协议到协议中
    protocol_addProtocol(prop, objc_getProtocol("RuntimeProtocol1"));
    
    //在运行时注册新创建的协议  所有的添加操作都必须放在注册操作之前
    objc_registerProtocol(prop);
    
    NSLog(@"------------------create finish ------------------------");
    
    //获取协议中指定条件的方法的方法描述数组
    unsigned int outCount = 0;
   struct objc_method_description *desc = protocol_copyMethodDescriptionList(prop, NO, YES, &outCount);
    for (int i = 0; i < outCount; i++) {
        struct objc_method_description md = desc[i];
        NSLog(@"%s",md.types);
        NSLog(@"%s",sel_getName(md.name));
    }
    
    //获取某一个方法
    struct objc_method_description desc1 = protocol_getMethodDescription(prop, @selector(addMethod), NO, YES);
    NSLog(@"%s",desc1.types);
    NSLog(@"%s",sel_getName(desc1.name));
    
    
    //获取属性列表
    outCount = 0;
    objc_property_t *property = protocol_copyPropertyList(prop, &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t p = property[i];
        NSLog(@"%s",property_getName(p));
        NSLog(@"%s",property_getAttributes(p));
    }
    
    //获取指定的属性
    objc_property_t p = protocol_getProperty(prop, "newAddProperty", NO, YES);
    if (p) {
        NSLog(@"%s",property_getName(p));
        NSLog(@"%s",property_getAttributes(p));
    }
    
    outCount = 0;
    Protocol * __unsafe_unretained _Nonnull *prto = protocol_copyProtocolList(prop, &outCount);
    for (int i = 0; i < outCount; i++) {
        Protocol *p = prto[i];
        NSLog(@"%s",protocol_getName(p));
    }
    
}


/**
 获取协议的属性列表
 */
- (void)copyProtocolPropertyList
{
    Protocol *prop = objc_getProtocol("RuntimeProtocol1");
    unsigned int  outCount = 0;
    objc_property_t *property = protocol_copyPropertyList(prop, &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t p = property[i];
        NSLog(@"%s",property_getName(p));
        NSLog(@"%s",property_getAttributes(p));
    }
    
}


/**
 获取协议中某个属性的信息
 从下面可以看出 使用@property声明的属性默认是 required的
 */
- (void)getSpecificProperty
{
    Protocol *prop = objc_getProtocol("RuntimeProtocol1");
    //获取指定的属性
    objc_property_t p = protocol_getProperty(prop, "name", YES, YES);
    if (p) {
        NSLog(@"%s",property_getName(p));
        NSLog(@"%s",property_getAttributes(p));
    }
}


/**
 判断一个协议是否遵守了另一个协议
 如果没遵守那么获取不到这个协议
 */
- (void)protocolConformProtocol
{
    Protocol *prop = objc_getProtocol("RuntimeProtocol1");
    Protocol *prop1 = objc_getProtocol("RuntimeProtocol2");
    if (protocol_conformsToProtocol(prop1, prop)) {
        NSLog(@"RuntimeProtocol2 遵守了 RuntimeProtocol1");
    }
}

#pragma mark - RuntimeProtocol1
- (void)instanceMethod
{
    NSLog(@"%s",__func__);
}


+ (void)classMethod
{
    NSLog(@"%s",__func__);
}




@end
