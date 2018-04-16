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

@end
