//
//  Objc_Property.m
//  Runtime_IvarAndProperty
//
//  Created by LeeWong on 2018/4/18.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "Objc_Property.h"
#import <objc/runtime.h>
#import "Father.h"

@implementation Objc_Property


/**
 获取属性的相关信息
 运行时添加的属性没有生成成员变量(_开头的属性)?
 */
- (void)getProperty
{
    Father *father = [[Father alloc] init];
    NSLog(@"=========动态添加属性==========");
    objc_property_attribute_t type= {"T","@\"NSString\""}; // type
    objc_property_attribute_t refType = {"C",""}; // copy
    objc_property_attribute_t backValue = {"V","_sex"}; // 返回值
    objc_property_attribute_t attrs[] = {type, refType, backValue};
    BOOL flag = class_addProperty([father class], "sex",attrs, 3);
    if(flag){
        NSLog(@"属性添加成功");
    }else{
        NSLog(@"属性添加失败");
    }
    NSLog(@"=========获得属性列表==========");
    unsigned int outCount = 0;
    objc_property_t *props = class_copyPropertyList([father class], &outCount);
    for(int i=0; i<outCount; i++){
        objc_property_t p = props[i];
        NSLog(@"属性: %s,描述信息:%s",property_getName(p),property_getAttributes(p));
    }
    free(props);
    
    NSLog(@"=============获取成员变量列表============");
    unsigned int outIvarCount = 0;
    Ivar *ivars = class_copyIvarList([father class], &outIvarCount);
    NSLog(@"成员变量个数: %d",outIvarCount);
    for (int i = 0; i<outIvarCount; i++) {
        Ivar ivar = ivars[i];
        NSLog(@"变量名称: %s",ivar_getName(ivar));
    }
    free(ivars);
}

- (void)copyAttributeValue
{
    objc_property_t p = class_getProperty([Father class], "name");
    NSLog(@"property name : %s",property_copyAttributeValue(p, "V"));
    NSLog(@"property type : %s",property_copyAttributeValue(p, "T"));

}

- (void)copyAttributeList
{
    objc_property_t p = class_getProperty([Father class], "name");
    unsigned int outCount = 0;
    objc_property_attribute_t *attrs = property_copyAttributeList(p, &outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        objc_property_attribute_t t = attrs[i];
        NSLog(@"property name is %s --- property value is %s",t.name,t.value);
    }
}

@end
