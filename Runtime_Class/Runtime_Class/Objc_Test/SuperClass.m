//
//  SuperClass.m
//  Runtime_Class
//
//  Created by LeeWong on 2018/4/16.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "SuperClass.h"
#import <objc/runtime.h>
#import "Son.h"

@implementation SuperClass

/**
 获取一个类的父类 然后递归去获取
 */
- (void)getSuperClassTree
{
    Class currentClass = [Son class];
    for (int i = 0; i < 5; i++) {
        NSLog(@"Following the isa pointer %d times gives %p class type %@", i, currentClass,NSStringFromClass(currentClass));
        currentClass = class_getSuperclass(currentClass);
    }
    
    NSLog(@"NSObject's SuperClass is %@",class_getSuperclass([NSObject class]));
}

@end
