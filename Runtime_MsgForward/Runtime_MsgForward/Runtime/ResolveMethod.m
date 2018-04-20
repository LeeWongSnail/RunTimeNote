//
//  ResolveMethod.m
//  Runtime_MsgForward
//
//  Created by LeeWong on 2018/4/20.
//  Copyright © 2018年 LeeWong. All rights reserved.
//

#import "ResolveMethod.h"
#import <objc/runtime.h>

@implementation ResolveMethod

void functionForInstanceMethod(id self,SEL cmd)
{
    NSLog(@"实例方法的替代方法");
}

void functionForClassMethod(id self,SEL cmd)
{
    NSLog(@"类方法的替代方法");
}


/**
 动态方法解析 可以动态添加一个方法来顶替这个未实现的方法

 @param sel 当前无法解析的方法
 @return 是否可以动态解析
 
 如果是类方法 那么要往元类中添加方法
 */
+ (BOOL)resolveClassMethod:(SEL)sel
{
    NSString *selectorStr = NSStringFromSelector(sel);
    if ([selectorStr isEqualToString:@"noIMPClassMethod"]) {
        Class cls = objc_getMetaClass(class_getName([self class]));
        BOOL addSuc = class_addMethod(cls, @selector(noIMPClassMethod), (IMP)functionForClassMethod, "@:");
        if (addSuc) {
            NSLog(@"add suc");
        } else {
            NSLog(@"add failed");
        }
    }
    
    return [super resolveClassMethod:sel];
}



/**
 方法动态解析

 @param sel 未找到的方法的名称
 @return 是否可以动态解析
 */
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    NSString *selectorStr = NSStringFromSelector(sel);
    if ([selectorStr isEqualToString:@"noIMPInstanceMethod"]) {
        class_addMethod([self class], @selector(noIMPInstanceMethod), (IMP)functionForInstanceMethod, "@:");
    }
    
    return [super resolveClassMethod:sel];
}


@end
